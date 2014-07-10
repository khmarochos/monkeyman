#!/usr/bin/perl

use strict;
use warnings;

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
use File::Basename;
use POSIX qw(strftime);



my %opts;

eval { GetOptions(
    'h|help'        => \$opts{'help'},
      'version'     => \$opts{'version'},
    'c|config'      => \$opts{'config'},
    'v|verbose+'    => \$opts{'verbose'},
    'q|quiet'       => \$opts{'quiet'},
    's|schedule=s'  => \$opts{'schedule'}
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

my $api = $mm->cloudstack_api;
$log->logdie($mm->error_message)
    unless(defined($api));



my $schedule = {};
my $configs = {};
my $objects = {};
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

    # Load everything If the schedule hasn't been loaded or has been reset
 
    # I'm reloading the schedule every time I get SIGHUP!
 
    unless(%{ $schedule }) {

        %{ $schedule } = eval {
            ParseConfig(
                -ConfigFile         => $opts{'schedule'},
                -UseApacheInclude   => 1
            );
        };
        $log->logdie(mm_sprintify("Can't Config::General->ParseConfig(): ", $@))
            if($@);

        $log->debug("The schedule has been loaded");

        # We shall forget all configuration elements as we obviously need
        # to reload them all

        $configs = {};
        $queue = {};

    }

    # Dealing with all configuration sections (reloading them if needed)

    foreach my $type (qw/timeperiod storagepool host domain/) {
        unless(keys(%{ $configs->{$type} })) {
            $log->trace(mm_sprintify("Some %s definitely need to be defined", $type));
            my $elements_loaded = eval {
                load_elements(
                    $schedule,
                    $type,
                    $configs->{$type}
                );
            };
            $log->die(mm_sprintify("Can't load_element(): %s", $@))
                if($@);
            $log->trace(mm_sprintify("%d %ss have been loaded", $elements_loaded, $type));
        }
    }



    # Loading information about objects if needed

    # It shall be allowed to reload the information without reloading
    # the queue by the timer or by SIGUSR1!

    foreach my $domain_path (grep(!/\*/, keys(%{ $configs->{'domain'} }))) {

        # Reload the information about the domain only if it's needed

        unless(defined($objects->{'domain'}->{'by_name'}->{$domain_path}->{'object'})) {

            $log->debug(mm_sprintify("Loading the information about the %s domain", $domain_path));

            my $domain = eval { MonkeyMan::CloudStack::Elements::Domain->new(
                mm          => $mm,
                load_dom    => {
                    conditions  => {
                        path        => $domain_path
                    }
                }
            )};
            if($@) { $log->warn(mm_sprintify("Can't MonkeyMan::CloudStack::Elements::Domain->new(): %s", $@)); next; }

            my $domain_id = $domain->get_parameter('id');
            if($domain->has_error) { $log->warn($domain->error_message); next; }
            unless(defined($domain_id)) { $log->warn("Can't get the id parameter of the domain"); next; }

            $objects->{'domain'}->{'by_name'}->{$domain_path} =
            $objects->{'domain'}->{'by_id'}->{$domain_id} = {
                object  => $domain,
                used    => {}
            };

            $log->info(mm_sprintify("The %s (%s) domain has been refreshed", $domain_id, $domain_path));

        }

        # Do we need to scan for any downlinks?

        my $results = find_related_and_refresh_if_needed(
            $objects->{'domain'}->{'by_name'}->{$domain_path}->{'object'},
            $objects_relations->{'domain'}
        );
        unless(defined($results)) {
            $log->warn(mm_sprintify("An error has occuried while refreshing %ss", $_));
            next;
        }

    }



    # Adding new volumes to the queue and adding references to related objects

    while(my($volume_id, $volume) = each(%{ $objects->{'volume'}->{'by_id'} })) {

=pod
        while(my($element_type, $element_features) = each({
            domain      => {
                required        => 1,
                parameter       => 'domainid',
                parameter_type  => 'id',
                config          => \%conf_domains
            }
        }) {

            my $element_id = $volume->{'object'}->get_parameter($element_features->{'parameter'});
            if($volume->has_error) {
                $log->warn($volume->{'object'}->error_message);
                next;
            } elsif($element_features->{'required'} && !defined($domain)) {
                $log->warn(mm_sprintify("The %s volume doesn't have the %s parameter", %volume, $element_features->{'parameter'}));
                next;
            } else {

                $element = $objects->{$element_type}->{"by_$element_features->{'parameter_type'}"}->{$domain};
                unless(ref($domain->{'object'}) eq 'MonkeyMan::CloudStack::Elements::' . ${&MMElementsModule}{$element_type}) {
                    $log->warn(mm_sprintify("The %s domain looks unhealthy", $domain));
                    next;
                }

            }
        }
=cut

        # Adding the volume to the queue

        unless(defined($queue->{$volume_id})) {
            $queue->{$volume_id} = {
                object      => $volume,
                queued      => time,
                postponed   => undef,
                started     => undef,
                done        => undef,
                jobid       => undef,
                related     => {}
            };
            $log->debug(mm_sprintify("Added the %s volume to the queue", $volume_id));
        }

        # Updating the related objects' list

=podV
        $queue->{$volume_id}->{'related'} = {
            domain          => $volume_domain,
            storagepool     => $volume_storagepool,
            virtualmachine  => $volume_virtualmachine,
            host            => $virtualmachine_host
        };
=cut

    }



    # Asking MM whats up, updating information about finished jobs

    foreach my $volume_id (keys(%{ $queue })) {

        unless(
             defined($queue->{$volume_id}->{'started'}) &&
            !defined($queue->{$volume_id}->{'done'})
        ) {
            next;
        }

        unless(defined($queue->{$volume_id}->{'jobid'})) {
            $log->warn(mm_sprintify("The %s volume seems to be busy, but the jobid isn't defined", $volume_id));
            next;
        }

    }


    # Starting new snapshot processes

    foreach my $volume_id (keys(%{ $queue })) {

        $log->debug(mm_sprintify("Checking the %s volume in the queue", $volume_id));

        if(
            defined($queue->{$volume_id}->{'started'}) &&       # the job has been started,
           !defined($queue->{$volume_id}->{'done'})             # but hasn't finished yet
        ) {
            $log->debug(mm_sprintify(
                "The %s volume is busy since %s, skipping it",
                    $volume_id,
                    strftime(MMDateTimeFormat, localtime($queue->{$volume_id}->{'started'}))
            ));
            next;
        }

        if(
            defined($queue->{$volume_id}->{'postponed'}) &&     # has been postponed
                    $queue->{$volume_id}->{'postponed'} > time  # and it's too early for a new job
        ) {
            $log->debug(mm_sprintify(
                "The %s volume is postponed till %s, skipping it",
                    $volume_id,
                    strftime(MMDateTimeFormat, localtime($queue->{$volume_id}->{'started'}))
            ));
            next;
        }

        $queue->{$volume_id}->{'started'} = time;

        $log->info(mm_sprintify("The %s volume has been started to make a snapshot", $volume_id));

    }



    # Gathering and storing some usage statistics



    # Counting stats



    # Saving the queue and objects, MonkeyMan should be able to do that:
    #   $dump_id = $mm->dump_state();
    #   $restore = $mm->restore_state($dump_id);



    sleep 2; # shall be configured and/or calculated /!\

}



exit;



sub load_elements {
    
    my($schedule, $elements_type, $elements_set) = @_;

    unless(
        ref($schedule) eq 'HASH' &&
        defined($elements_type) &&
        ref($elements_set) eq 'HASH'
    ) {
        $log->logdie("Required parameters haven't been defined");
    }

    # Loading templates

    foreach my $template_name (grep( /\*/, keys(%{ $schedule->{$elements_type} }))) {
        $elements_set->{$template_name} = $schedule->{$elements_type}->{$template_name};
        $log->trace(mm_sprintify("The %s %s's template has been loaded", $template_name, $elements_type));
    }

    # Loading elements

    my $elements_loaded = 0;

    foreach my $element_name (grep(!/\*/, keys(%{ $schedule->{$elements_type} }))) {

        $log->trace(mm_sprintify("Configuring the %s %s", $element_name, $elements_type));

        # Getting the configuration of the new element from the schedule
        $elements_set->{$element_name} = $schedule->{$elements_type}->{$element_name};

        # Configuring the new element, adding configuration templates
 
        my $element_configured = {};
        my $layers_loaded = eval {
            configure_element(
                $elements_set,
                $element_name,
                $element_configured
            );
        };
        $log->logdie(mm_sprintify("Can't configure_element(): %s", $@))
            if($@);
        $elements_set->{$element_name} = $element_configured;
        $elements_loaded++;

        $log->debug(mm_sprintify(
            "The %s %s with %s configuration layers has been loaded",
                $element_name,
                $elements_type,
                $layers_loaded
        ));
        foreach my $parameter (keys(%{ $elements_set->{$element_name} })) {
            $log->trace(mm_sprintify(
                "The %s %s has %s = %s",
                    $element_name,
                    $elements_type,
                    $parameter,
                    $elements_set->{$element_name}->{$parameter}
            ));
        }

    }

    return($elements_loaded);

};



sub configure_element {

    my($elements_set, $element_name, $element_configured) = @_;

    unless(
        ref($elements_set) eq 'HASH' &&
        defined($element_name) &&
        ref($element_configured) eq 'HASH'
    ) {
        $log->logdie("Required parameters haven't been defined");
    }

    # Will try to compare every pattern to the given name,
    # will return the exact number of patterns matched,
    # so, yes, 0 means nothing has matched.

    my $matched_patterns = 0;

    foreach my $pattern (sort(keys(%{ $elements_set }))) {
        if(match_glob($pattern, $element_name)) {
            $log->trace(mm_sprintify("The %s pattern matched the %s element", $pattern, $element_name));
            foreach (keys(%{ $elements_set->{$pattern} })) {
                $element_configured->{$_} = $elements_set->{$pattern}->{$_};
                $log->trace(mm_sprintify(
                    "The %s element has %s = %s",
                        $element_name,
                        $_,
                        $element_configured->{$_}
                ));
            }
            $matched_patterns++;
        }
    }

    return($matched_patterns);


}



sub find_related_and_refresh_if_needed {

    my $uplink      = shift;
    my $uplink_node = shift;

    unless(defined($uplink_node)) {
        $log->warn("The uplink's node isn't defined");
        return;
    }
    my $uplink_id   = $uplink->get_parameter('id');
    if($uplink->has_error) {
        $log->warn($uplink->error_message);
        return;
    }
    my $uplink_name = $uplink->get_parameter('name');
    if($uplink->has_error) {
        $log->warn($uplink->error_message);
        return;
    }
    my $uplink_type = $uplink->element_type;
    if($uplink->has_error) {
        $log->warn($uplink->error_message);
        return;
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
                        mm          => $mm,
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
                if($downlink->has_error) {
                    $log->warn($downlink->error_message);
                    next;
                }
                unless(defined($downlink_id)) {
                    $log->warn(mm_sprintify("Can't get the ID of %s", $downlink));
                    next;
                }

                my $downlink_name = $downlink->get_parameter('name');
                if($downlink->has_error) {
                    $log->warn($downlink->error_message);
                    next;
                }
                unless(defined($downlink_name)) {
                    $log->warn(mm_sprintify("Can't get the name of %s", $downlink));
                    next;
                }

                # Storing information about the downlink

                $objects->{$downlink_type}->{'by_name'}->{$downlink_name} =
                $objects->{$downlink_type}->{'by_id'}->{$downlink_id} = {
                    object  => $downlink,
                    config  => $configs->{$downlink_type}->{$downlink_name},
                    used    => {}
                };

                $log->info(mm_sprintify(
                    "The %s (%s) %s has been refreshed",
                        $downlink_id,
                        $downlink_name,
                        $downlink_type
                ));

            }

            # Loading more downlinks it there are any

            my $results = find_related_and_refresh_if_needed(
                $objects->{$downlink_type}->{'by_id'}->{$downlink_id}->{'object'},
                $uplink_node->{$downlink_type}
            );
            unless(defined($results)) {
                $log->warn(mm_sprintify("No %ss refreshed due to an error occuried", $downlink_type));
                next;
            }

        }

    }

    return($found);

}
