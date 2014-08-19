#!/usr/bin/perl

use strict;
use warnings;

use feature qw(switch);

use FindBin qw($Bin);

use lib("$Bin/../lib");

use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;
use MonkeyMan::CloudStack::Elements::Domain;

use Getopt::Long;
use Config::General qw(ParseConfig);
use Text::Glob qw(match_glob); $Text::Glob::strict_wildcard_slash = 0;
use Time::Period;
use File::Basename;
use POSIX qw(strftime);



my %opts;

eval { GetOptions(
    'h|help'        => \$opts{'help'},
      'version'     => \$opts{'version'},
    'c|config'      => \$opts{'config'},
    'v|verbose+'    => \$opts{'verbose'},
    'q|quiet'       => \$opts{'quiet'},
    's|schedule=s'  => \$opts{'schedule'},
    'no-snapshots'  => \$opts{'no-snapshots'},
    'no-cleanup'    => \$opts{'no-cleanup'},
    'dump-crap'     => \$opts{'dump-crap'}
); };
die(mm_sprintify("Can't GetOptions(): %s", $@))
    if($@);

if($opts{'help'})       { MonkeyMan::Show::help('makesnapshots');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;                 exit; };
die("The schedule hasn't been defined, see --help for more information")
    unless(defined($opts{'schedule'}));

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die(mm_sprintify("Can't MonkeyMan->new(): %s", $@))
    if($@);

my $log = eval { Log::Log4perl::get_logger("MonkeyMan") };
die(mm_sprintify("The logger hasn't been initialized: %s", $@))
    if($@);

my $cs = $mm->init_cloudstack;
die($mm->error_message)
    unless(defined($cs));

my $api = $cs->api;
die($cs->error_message)
    unless(defined($api));



my $schedule = {};
my $configs = {};
my $objects = {
    rebuilt         => 0
};
my $objects_relations = {
    domain          => {
        volume          => {
            snapshot        => {},
            storagepool     => {},
            virtualmachine  => {
                host            => {}
            }
        }
    }
};
my $queue = {};



THE_LOOP: while (1) {

    my $now = time;

    # Load everything If the schedule hasn't been loaded or has been reset
 
    # TODO: I shall reload the schedule every time I get SIGHUP!
 
    unless(%{ $schedule }) {

        %{ $schedule } = eval {
            ParseConfig(
                -ConfigFile         => $opts{'schedule'},
                -UseApacheInclude   => 1
            );
        };
        $log->logdie(mm_sprintify("Can't Config::General->ParseConfig(): %s", $@))
            if($@);

        $log->debug("The schedule has been loaded");

        # We shall forget all configuration entities as we obviously need
        # to reload them all

        $configs = {};
        $queue = {};

    }

    # Dealing with all configuration sections (reloading them if needed)

    foreach my $entity_type (qw/timeperiod storagepool host domain/) {

        unless(keys(%{ $configs->{$entity_type} })) {
            $log->trace(mm_sprintify("Some %s definitely needs to be defined", $entity_type));

            # Loading templates

            foreach my $template_name (grep( /\*/, keys(%{ $schedule->{$entity_type} }))) {
                $configs->{$entity_type}->{$template_name} = $schedule->{$entity_type}->{$template_name};
                $log->trace(mm_sprintify("The %s %s's template has been loaded", $template_name, $entity_type));
            }

            # Loading entities

            my $entities_loaded = 0;

            foreach my $entity_name (grep(!/\*/, keys(%{ $schedule->{$entity_type} }))) {

                $log->trace(mm_sprintify("Configuring the %s %s", $entity_name, $entity_type));

                # Configuring the new entity, adding configuration templates
         
                my $layers_loaded = eval {
                    configure_entity(
                        $entity_type,
                        $entity_name
                    );
                };
                $log->logdie(mm_sprintify("Can't configure_entity(): %s", $@))
                    if($@);
                $entities_loaded++;

            }

            $log->trace(mm_sprintify("%d %ss have been loaded", $entities_loaded, $entity_type));
        }

    }



    # Loading information about objects if needed

    # It shall be allowed to reload the information without reloading
    # the queue by the timer or by SIGUSR1!

    if($objects->{'rebuilt'} + $schedule->{'timings'}->{'keep_objects'} < $now) {

        foreach my $domain_path (grep(!/\*/, keys(%{ $configs->{'domain'} }))) {

            # Reload the information about the domain only if it's needed

            unless(defined($objects->{'domain'}->{'by_name'}->{$domain_path}->{'element'})) {

                $log->debug(mm_sprintify("Loading the information about the %s domain", $domain_path));

                my $domain = eval { MonkeyMan::CloudStack::Elements::Domain->new(
                    cs          => $cs,
                    load_dom    => {
                        conditions  => {
                            path        => $domain_path
                        }
                    }
                )};
                if($@) { $log->warn(mm_sprintify("Can't MonkeyMan::CloudStack::Elements::Domain->new(): %s", $@)); next; }

                my $domain_id = $domain->get_parameter('id');
                if($domain->has_errors) { $log->warn($domain->error_message); next; }
                unless(defined($domain_id)) { $log->warn("Can't get the id parameter of the domain"); next; }

                $objects->{'domain'}->{'by_name'}->{$domain_path} =
                $objects->{'domain'}->{'by_id'}->{$domain_id} = {
                    element => $domain,
                    config  => $configs->{'domain'}->{$domain_path}
                };

                $log->info(mm_sprintify("The %s (%s) domain has been refreshed", $domain_id, $domain_path));

            }

            # Do we need to scan for any downlinks?

            my $results = find_related_and_refresh_if_needed(
                $objects->{'domain'}->{'by_name'}->{$domain_path}->{'element'},
                $objects_relations->{'domain'},
                {
                    entity_type    => 'volume'
                }
            );
            unless(defined($results)) {
                $log->warn("An error has occuried while refreshing volumes");
                next;
            }

        }

        $objects->{'rebuilt'} = time; # Not $now, as it takes some time()

    }



    # Adding new volumes to the queue and adding references to related objects

    while(my($volume_id, $volume) = each(%{ $objects->{'volume'}->{'by_id'} })) {

        my $frequency = $objects->{'volume'}->{'by_id'}->{$volume_id}->{'config'}->{'frequency'};
        my $latest = 0;
        foreach my $snapshot_id (keys( %{ $objects->{'volume'}->{'by_id'}->{$volume_id}->{'occupied'}->{'snapshot'} } )) {

            my $snapshot_element = $objects->{'snapshot'}->{'by_id'}->{$snapshot_id}->{'element'};
            unless(defined($snapshot_element)) {
                $log->warn(mm_sprintify("The %s snapshot isn't initialized", $snapshot_id));
                next;
            }

            my $created = $snapshot_element->get_parameter('created');
            unless(defined($created)) {
                $log->warn($snapshot_element->error_message);
                next;
            }

            $created = mm_string_to_time($created);

            $latest = $created if($latest < $created);
        }
        my $postponed = $latest + $frequency if(defined($frequency));

        # Adding the volume to the queue

        unless(defined($queue->{$volume_id})) {
            $queue->{$volume_id} = {
                object      => $volume, # the corresponding object
                queued      => $now,    # when it has been added to the queue
                postponed   => $postponed, # next check time, if it's postponed
                started     => undef,   # started at, if the job is started
                done        => undef,   # done at, if done
                job         => undef    # the name is pretty descriptive :)
            };
            $log->debug(mm_sprintify("Added the %s volume to the queue", $volume_id));
        }

    }


    # Asking MM whussap, updating information about finished jobs

    foreach my $volume_id (keys(%{ $queue })) {

        unless(
             defined($queue->{$volume_id}->{'started'}) &&
            !defined($queue->{$volume_id}->{'done'})
        ) {
            next;
        }

        my $job = $queue->{$volume_id}->{'job'};
        unless(defined($job) || $opts{'no-snapshots'}) {
            $log->warn(mm_sprintify("The %s volume seems to be busy, but the job isn't defined", $volume_id));
            next;
        }

        my $job_result = $opts{'no-snapshots'} ? { jobstatus => 1 } : $job->result;
        unless(defined($job_result)) {
            $log->warn($job->error_message);
            next;
        }

        given($job_result->{'jobstatus'}) {
            when(0) {

                $log->debug(mm_sprintify(
                    "The %s volume is still busy, the %s job is running",
                        $volume_id,
                        $job_result->{'jobid'}
                ));
                next;

            } when(1) {

                unless($opts{'no-snapshots'}) {

                    my $snapshot_id = $api->query_xpath($job_result->{'jobresult'}, '//snapshot/id/text()');
                    unless(defined($snapshot_id)) {
                        $log->warn($api->error_message);
                        next;
                    }

                    $log->info(mm_sprintify(
                        "The %s volume's snapshot has been backed up, the %s snapshot has been stored",
                            $volume_id,
                            ${ $snapshot_id }[0]
                    ));

                }

                $queue->{$volume_id}->{'started'}       = undef;
                $queue->{$volume_id}->{'done'}          = $now;
                $queue->{$volume_id}->{'postponed'}     = $now + $objects->{'volume'}->{'by_id'}->{$volume_id}->{'config'}->{'frequency'};

                # We don't need to call cleanup_snapshots for each volume, let's do it only when the snapshot is done

                my $snapshots_deleted = 
                    $opts{'no-cleanup'} ?
                        0 :
                        $objects->{'volume'}->{'by_id'}->{$volume_id}->{'element'}->cleanup_snapshots(
                            $objects->{'volume'}->{'by_id'}->{$volume_id}->{'config'}->{'keep'});
                unless(defined($snapshots_deleted)) {
                    $log->warn($objects->{'volume'}->{'by_id'}->{$volume_id}->{'element'}->error_message);
                    next;
                }

                $log->trace(mm_sprintify("%d snapshot(s) have been deleted", $snapshots_deleted));

            } when(2) {

                $log->warn(mm_sprintify(
                    "The %s volume hasn't been backed up, the %s job has been failed: %s - %s",
                        $volume_id,
                        $job_result->{'jobid'},
                        $job_result->{'jobresultcode'},
                        $job_result->{'jobresult'}
                ));

                $queue->{$volume_id}->{'started'}       = undef;
                $queue->{$volume_id}->{'done'}          = $now;
                $queue->{$volume_id}->{'postponed'}     = $now + $objects->{'volume'}->{'by_id'}->{$volume_id}->{'config'}->{'frequency'};

            } default {

                $log->warn(mm_sprintify(
                    "The %s job has an odd jobstatus: %s",
                        $job_result->{'jobid'},
                        $_
                ));

            }
        }

    }


    # Starting new snapshot processes if it's time for some of volumes to get backed up

    VOLUME: foreach my $volume_id (keys(%{ $queue })) {

        $log->debug(mm_sprintify("Checking the %s volume in the queue", $volume_id));

        # Shall we skip this volume due to certain conditions?

        if(
            defined($queue->{$volume_id}->{'started'}) &&       # the job has been started,
           !defined($queue->{$volume_id}->{'done'})             # but hasn't finished yet
        ) {
            $log->debug(mm_sprintify(
                "The %s volume is busy since %s, skipping it",
                    $volume_id,
                    strftime(MMDateTimeFormat, localtime($queue->{$volume_id}->{'started'}))
            ));
            next VOLUME;
        }

        if(
            defined($queue->{$volume_id}->{'postponed'}) &&     # the job has been postponed
                    $queue->{$volume_id}->{'postponed'} > time  # and it's too early for a new job
        ) {
            $log->debug(mm_sprintify(
                "The %s volume is postponed till %s, skipping it",
                    $volume_id,
                    strftime(MMDateTimeFormat, localtime($queue->{$volume_id}->{'postponed'}))
            ));
            next VOLUME;
        }

        if(defined($objects->{'volume'}->{'by_id'}->{$volume_id}->{'config'}->{'available'})) {
            my $timeperiod1 = $objects->{'volume'}->{'by_id'}->{$volume_id}->{'config'}->{'available'};
            my $timeperiod2 = $configs->{'timeperiod'}->{$timeperiod1}->{'period'};
            if(inPeriod($now, $timeperiod2) != 1) {
                $log->debug(mm_sprintify(
                    "The %s volume is available only at this timeperiod: %s (which means %s), skipping it",
                    $volume_id,
                    $timeperiod1,
                    $timeperiod2
                ));
                next VOLUME;
            }
        }

        # Determining business/idleness and availability of entities occupied by the volume

        foreach my $entity_type qw(virtualmachine storagepool host) {

            foreach my $entity_id_occupied (
                keys(%{ $objects->{'volume'}->{'by_id'}->{$volume_id}->{'occupied'}->{$entity_type} })
            ) {
                my $occupiers_busy = 0;
                foreach my $entity_id_occupier (
                    keys(%{ $objects->{$entity_type}->{'by_id'}->{$entity_id_occupied}->{'occupier'}->{'volume'} })
                ) {
                    if(
                        defined($queue->{$entity_id_occupier}->{'started'}) &&
                       !defined($queue->{$entity_id_occupier}->{'done'})
                    ) {
                        $occupiers_busy++;
                        $log->trace(mm_sprintify(
                            "The %s %s is occupied by %s volume which is busy now",
                            $entity_id_occupied,
                            $entity_type,
                            $entity_id_occupier
                        ));

                    }
                }

                $log->trace(mm_sprintify("%d volume(s) uses the %s %s", $occupiers_busy, $entity_id_occupied, $entity_type));

                if(
                    defined($objects->{$entity_type}->{'by_id'}->{$entity_id_occupied}->{'config'}->{'flows'}) &&
                            $objects->{$entity_type}->{'by_id'}->{$entity_id_occupied}->{'config'}->{'flows'} <= $occupiers_busy
                ) {
                    $log->debug(mm_sprintify(
                        "The %s %s is occupied by %d volume(s) which is/are busy now, " .
                        "it's greater or equal than %d, so the %s is threated as busy, skipping the volume",
                        $entity_id_occupied,
                        $entity_type,
                        $occupiers_busy,
                        $objects->{$entity_type}->{'by_id'}->{$entity_id_occupied}->{'config'}->{'flows'},
                        $entity_type
                    ));
                    next VOLUME;

                }

                if(defined($objects->{$entity_type}->{'by_id'}->{$entity_id_occupied}->{'config'}->{'available'})) {
                    my $timeperiod1 = $objects->{$entity_type}->{'by_id'}->{$entity_id_occupied}->{'config'}->{'available'};
                    my $timeperiod2 = $configs->{'timeperiod'}->{$timeperiod1}->{'period'};

                    if(inPeriod($now, $timeperiod2) != 1) {
                        $log->debug(mm_sprintify(
                            "The %s %s is available only at this timeperiod: %s (which means %s), skipping it",
                            $entity_id_occupied,
                            $entity_type,
                            $timeperiod1,
                            $timeperiod2
                        ));
                        next VOLUME;
                    }
                }

            }

        }

        my $volume_element = $objects->{'volume'}->{'by_id'}->{$volume_id}->{'element'};
        unless(defined($volume_element)) {
            $log->warn("The %s volume's element hasn't been initialized");
            next VOLUME;
        }

        if($opts{'no-snapshots'}) {

            $log->info(mm_sprintify(
                "The %s volume needs to have a snapshot, but it's not allowed to do it",
                $volume_id
            ));

            $queue->{$volume_id}->{'started'} = time;
            $queue->{$volume_id}->{'done'}    = undef;

        } else {

            my $job = $volume_element->create_snapshot(wait => 0);
            unless(defined($job)) {
                $log->warn($volume_element->error_message);
                next VOLUME;
            }
            $log->trace(mm_sprintify("The %s job has been started", $job));

            $queue->{$volume_id}->{'job'}     = $job;
            $queue->{$volume_id}->{'started'} = time;
            $queue->{$volume_id}->{'done'}    = undef;

            $log->info(mm_sprintify(
                "The %s volume has been started to make a snapshot, the job id is %s",
                $volume_id,
                $job->get_parameter('jobid')
            ));

        }

        #last VOLUME; # Don't create more than one snapshots in the same LOOP

    }



    if($opts{'dump-crap'}) {
        eval { mm_dump_object($configs, undef, "configs", 5); };
        $log->warn(mm_sprintify("Can't mm_dump_object(): %s", $@))
            if($@);
        eval { mm_dump_object($queue, undef, "queue", 5); };
        $log->warn(mm_sprintify("Can't mm_dump_object(): %s", $@))
            if($@);
        eval { mm_dump_object($objects, undef, "objects", 5); };
        $log->warn(mm_sprintify("Can't mm_dump_object(): %s", $@))
            if($@);
    }



    # TODO: Gathering and storing some usage statistics



    # Getting rest

    sleep(defined($schedule->{'timings'}->{'sleep_between_loops'}) ? $schedule->{'timings'}->{'sleep_between_loops'} : 60);

}



exit;



sub configure_entity {

    my($entity_type, $entity_name) = @_;

    unless(
        defined($entity_type) &&
        defined($entity_name)
    ) {
        $log->logdie("Required parameters haven't been defined");
    }

    # Will try to compare every pattern to the given name,
    # will return the exact number of patterns matched,
    # so, yes, 0 means nothing has matched.

    my $matched_patterns = 0;

    $log->trace(mm_sprintify("entity_type = %s, entity_name = %s", $entity_type, $entity_name));

    foreach my $pattern (sort(keys(%{ $schedule->{$entity_type} }))) {

        if(match_glob($pattern, $entity_name)) {

            # If there are matching pattern or the exact name configured,
            # attach the configuration hash to the main data structure
 
            $log->trace(mm_sprintify("The %s pattern matched the %s entity", $pattern, $entity_name));
            foreach my $parameter (keys(%{ $schedule->{$entity_type}->{$pattern} })) {
                $configs->{$entity_type}->{$entity_name}->{$parameter} = $schedule->{$entity_type}->{$pattern}->{$parameter};
            }
            $matched_patterns++;
        }

    }

    if($matched_patterns) {
        $log->debug(mm_sprintify(
            "The %s %s with %d configuration layer(s) has been loaded: %s",
                $entity_name,
                $entity_type,
                $matched_patterns,
                $configs->{$entity_type}->{$entity_name}
        ));
    }

    return($matched_patterns);


}



sub find_related_and_refresh_if_needed {

    my $uplink      = shift;
    my $uplink_node = shift;
    my $key_entity  = shift;

    unless(defined($uplink_node)) {
        $log->warn("The uplink's node isn't defined");
        return;
    }
    my $uplink_id   = $uplink->get_parameter('id');
    if($uplink->has_errors) {
        $log->warn($uplink->error_message);
        return;
    }
    my $uplink_type = $uplink->element_type;
    if($uplink->has_errors) {
        $log->warn($uplink->error_message);
        return;
    }
    my $uplink_name = $uplink_type eq 'domain' ? $uplink->get_parameter('path') : $uplink->get_parameter('name');
    if($uplink->has_errors) {
        $log->warn($uplink->error_message);
        return;
    }

    # If the uplink is the key_entity, we need to store the link to it

    if(
        (defined($key_entity->{'entity_type'}) &&
                ($key_entity->{'entity_type'} eq $uplink_type))) {

        $log->trace(mm_sprintify("Processing the the key entity: %s", $key_entity->{'entity_type'}));

        $key_entity->{'current_entity_id'} = $uplink_id;
    }

    # Do we need to scan for any downlinks?

    my @downlinks_types_to_scan = keys(%{ $uplink_node });
    my $found = 0;

    foreach my $downlink_type (@downlinks_types_to_scan) {

        $log->debug(mm_sprintify(
            "Looking for %s related to the %s (%s) %s",
                $downlink_type,
                $uplink_id,
                $uplink_name,
                $uplink_type
        ));

        # Looking for related downlinks

        my $downlinks = $uplink->find_related_to_me($downlink_type);
        unless(defined($downlinks)) {
            $log->warn($uplink->error_message);
            return;
        }
        unless(scalar(@{ $downlinks })) {
            $log->debug(mm_sprintify(
                "The %s (%s) %s doesn't have any related %ss",
                    $uplink_id,
                    $uplink_name,
                    $uplink_type,
                    $downlink_type
            ));
        }

        foreach my $downlink_dom (@{ $downlinks }) {

            $found++;

            my $downlink_id = eval { $downlink_dom->findvalue("/$downlink_type/id") };
            if($@) { $log->warn(mm_sprintify("Can't %s->findvalue(): %s", $downlink_dom, $@)); next; }

            # Indeed, only if we need it

            unless(defined($objects->{$downlink_type}->{'by_id'}->{$downlink_id})) {

                $log->trace(mm_sprintify(
                    "Loading the information about the %s %s",
                        $downlink_id,
                        $downlink_type
                ));

                my $module_name = ${&MMElementsModule}{$downlink_type};
                unless(defined($module_name)) {
                    $log->warn(mm_sprintify("I'm not able to manipulate %ss yet", $downlink_type));
                    return;
                }

                my $downlink = eval {
                    require("MonkeyMan/CloudStack/Elements/$module_name.pm");
                    return("MonkeyMan::CloudStack::Elements::$module_name"->new(
                        cs          => $cs,
                        load_dom    => {
                             dom        => $downlink_dom
                        }
                    ));
                };
                if($@) { $log->warn(mm_sprintify(
                    "Can't MonkeyMan::CloudStack::Elements::%s->new(): %s",
                        $module_name,
                        $@
                    ));
                    next;
                }

                $downlink_id = $downlink->get_parameter('id');
                if($downlink->has_errors) {
                    $log->warn($downlink->error_message);
                    next;
                }
                unless(defined($downlink_id)) {
                    $log->warn(mm_sprintify("Can't get the ID of %s", $downlink));
                    next;
                }

                my $downlink_name = $downlink->get_parameter('name');
                if($downlink->has_errors) {
                    $log->warn($downlink->error_message);
                    next;
                }
                unless(defined($downlink_name)) {
                    $log->warn(mm_sprintify("Can't get the name of %s", $downlink));
                    next;
                }

                # Config/reconfig

                unless(defined($configs->{$downlink_type}->{$downlink_name})) {

                    $log->trace(mm_sprintify("Updating the %s %s's configuration", $downlink_id, $downlink_type));

                    my $layers_loaded = eval {
                        configure_entity(
                            $downlink_type,
                            $downlink_name
                        );
                    };
                    $log->logdie(mm_sprintify("Can't configure_entity(): %s", $@))
                        if($@);

                    my @inherited_parameters = keys(%{ $configs->{$downlink_type}->{$downlink_name}->{'inherit'}->{$uplink_type} });
                    if(scalar(@inherited_parameters)) {
                        $log->trace(mm_sprintify("Inheriting %s parameter(s) from our %s",
                            join(", ", @inherited_parameters),
                            $uplink_type
                        ));
                        foreach my $parameter (@inherited_parameters) {
                            if(
                                (       # If we have to force parameter's inheritance
                             defined($configs->{$downlink_type}->{$downlink_name}->{'inherit'}->{$uplink_type}->{$parameter}) &&
                                    ($configs->{$downlink_type}->{$downlink_name}->{'inherit'}->{$uplink_type}->{$parameter} eq 'force')
                                ) || (  # If the downlink shall inherit the parameter only if it doesn't have it defined
                             defined($configs->{$downlink_type}->{$downlink_name}->{'inherit'}->{$uplink_type}->{$parameter}) &&
                                    ($configs->{$downlink_type}->{$downlink_name}->{'inherit'}->{$uplink_type}->{$parameter} eq 'careful') &&
                            !defined($configs->{$downlink_type}->{$downlink_name}->{$parameter})
                                )
                            ) {         # Inheriting the parameter...
                                $configs->{$downlink_type}->{$downlink_name}->{$parameter} =
                                    $configs->{$uplink_type}->{$uplink_name}->{$parameter};
                            }
                        }
                    }

                }

                # Storing information about the downlink

                $objects->{$downlink_type}->{'by_name'}->{$downlink_name} =
                $objects->{$downlink_type}->{'by_id'}->{$downlink_id} = {
                    element => $downlink,
                    config  => $configs->{$downlink_type}->{$downlink_name},
                };

                $log->info(mm_sprintify(
                    "The %s (%s) %s has been refreshed",
                        $downlink_id,
                        $downlink_name,
                        $downlink_type
                ));

            }

            # Do we know who occupied this entity?

            if(
                defined($key_entity->{'entity_type'}) &&
                defined($key_entity->{'current_entity_id'})
            ) {

                $log->trace(mm_sprintify("Okay, we've got the key entity, it's a %s", $key_entity->{'entity_type'}));

                # ...

                $objects->{$downlink_type}->{'by_id'}->{$downlink_id}->{'occupier'}->{ $key_entity->{'entity_type'} }->{ $key_entity->{'current_entity_id'} } = 1;
                $objects->{ $key_entity->{'entity_type'} }->{'by_id'}->{ $key_entity->{'current_entity_id'} }->{'occupied'}->{$downlink_type}->{$downlink_id} = 1;

            }


            # Loading more downlinks it there are any

            my $results = find_related_and_refresh_if_needed(
                $objects->{$downlink_type}->{'by_id'}->{$downlink_id}->{'element'},
                $uplink_node->{$downlink_type},
                $key_entity
            );
            unless(defined($results)) {
                $log->warn(mm_sprintify("No %ss refreshed due to an error occuried", $downlink_type));
                next;
            }

        }

    }

    # If the uplink was the key_entity, we must drop the link to it!

    if(
        (defined($key_entity->{'entity_type'}) &&
                ($key_entity->{'entity_type'} eq $uplink_type))) {
        $key_entity->{'current_entity_id'} = undef;
    }

    return($found);

}

