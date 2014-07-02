#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);

use lib("$Bin/../lib");

use MonkeyMan;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;
use MonkeyMan::CloudStack::Elements::Domain;
use MonkeyMan::CloudStack::Elements::Volume;

use Getopt::Long;
use Config::General qw(ParseConfig);
use Text::Glob qw(match_glob); $Text::Glob::strict_wildcard_slash = 0;
use File::Basename;
use Data::Dumper;



my %opts;

my $res = GetOptions(
    'h|help'        => \$opts{'help'},
      'version'     => \$opts{'version'},
    'c|config'      => \$opts{'config'},
    'v|verbose+'    => \$opts{'verbose'},
    'q|quiet'       => \$opts{'quiet'},
    's|schedule=s'  => \$opts{'schedule'}
);
unless($res) {
    die("Can't GetOptions()");
}

if($opts{'help'})       { MonkeyMan::Show::help('makesnapshots');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;                 exit; };
unless(defined($opts{'schedule'})) {
    die("The schedule hasn't been defined, see --help for more information");
}

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die("Can't MonkeyMan->new(): $@") if($@);

my $log = eval { Log::Log4perl::get_logger("MonkeyMan") };
die("The logger hasn't been initialized: $@") if($@);

my $api = $mm->init_cloudstack_api;
$log->logdie($mm->error_message) unless(defined($api));



my %schedule;               # the key is the variable's name
my %conf_timeperiods;       # the key is its name
my %conf_storagepools;      # the key is its name
my %conf_hosts;             # the key is its name
my %conf_domains;           # the key is its full path
my %conf_volumes;           # the key is its id
my %info_storagepools;      # the key is its name
my %info_hosts;             # the key is its name
my %info_domains;           # the key is its id
my %info_domains_by_path;   # the key is its full path
my %info_volumes;           # the key is its id
my %info_virtualmachines;   # the key is its id
my %info_snapshots;         # the key is its id
my %queue;                  # oh, fuck it :)

THE_LOOP: while (1) {

    # ----------------------------------------------------------------------
    # Reload everything If the schedule hasn't been loaded or has been reset

    # I'm reloading the schedule every time I get SIGHUP
 
    unless(%schedule) {

        %schedule = eval {
            ParseConfig(
                -ConfigFile         => $opts{'schedule'},
                -UseApacheInclude   => 1
            );
        };
        if($@) {
            $log->logdie("Can't Config::General->ParseConfig(): $@");
        }

        $log->debug("The schedule has been loaded");

        # We shall forget all configuration elements as we obviously need
        # to reload them all

        undef(%conf_timeperiods);
        undef(%conf_storagepools);
        undef(%conf_hosts);
        undef(%conf_domains);
        undef(%queue);

    }

    # Dealing with all configuration sections (reloading them if needed)

    foreach my $section (
        { hash => \%conf_timeperiods,   type => 'timeperiod' },
        { hash => \%conf_storagepools,  type => 'storagepool' },
        { hash => \%conf_hosts,         type => 'host' },
        { hash => \%conf_domains,       type => 'domain' }
    ) {
        unless(defined(%{ $section->{'hash'}})) {
            $log->trace("Some $section->{'type'}s definitely need to be defined");
            my $elements_loaded = eval {
                load_elements(
                    \%schedule,
                    $section->{'type'},
                    $section->{'hash'}
                );
            };
            if($@) { $log->die("Can't load_element(): $@"); };
            $log->trace("$elements_loaded $section->{'type'}s have been loaded");
        }
    }


    # -------------------------------------------
    # Loading information about objects if needed

    # It shall be able to reload the information without reloading the queue,
    # by the timer or by SIGUSR1!

    foreach my $domain_path (grep(!/\*/, keys(%conf_domains))) {

        # Reload the information about the domain only if it's needed

        unless(defined($info_domains_by_path{$domain_path})) {

            $log->debug("Loading the information about the $domain_path domain");

            my $domain = eval { MonkeyMan::CloudStack::Elements::Domain->new(
                mm          => $mm,
                load_dom    => {
                    conditions  => {
                        path        => $domain_path
                    }
                }
            )};
            if($@) { $log->warn("Can't MonkeyMan::CloudStack::Elements::Domain->new(): $@"); next; }

            my $domain_id = $domain->get_parameter('id');
            if($domain->has_error) { $log->warn($domain->error_message); next; }
            unless(defined($domain_id)) { $log->warn("Can't get the id parameter of the domain"); next; }

            $info_domains_by_path{$domain_path} =
                    $info_domains{$domain_id}   = $domain;

            $log->info("The $domain_id ($domain_path) domain has been loaded");

        }

    }

    # Get a fresh list of volumes in every domain on every pass

    foreach my $domain_id (keys(%info_domains)) {

        my $domain = $info_domains{$domain_id};

        $log->debug("Gathering information about volumes in the $domain_id ($domain) domain");

        my $volumes = $domain->find_related_to_me("volume");
        unless(defined($volumes)) { $log->warn("Skipping the domain: " . $domain->error_message); next; }
        unless(scalar(@$volumes)) { $log->warn("Skipping the domain as it doesn't have any volumes"); next; }

        foreach my $volume_dom (@{$volumes}) {

            my $volume_id = eval { $volume_dom->findvalue('/volume/id') };
            if($@) { $log->warn("Can't $volume_dom->findvalue(): $@"); next; }

            unless(defined($info_volumes{$volume_id})) {

                $log->trace("Loading the information about the $volume_id volume");

                my $volume = eval { MonkeyMan::CloudStack::Elements::Volume->new(
                    mm          => $mm,
                    load_dom    => {
                         dom        => $volume_dom
                    }
                ); };
                if($@) { $log->warn("Can't MonkeyMan::CloudStack::Elements::Volume->new(): $@"); next; }

                my $volume_id = $volume->get_parameter('id');
                if($volume->has_error) { $log->warn($volume->error_message); next; }
                unless(defined($volume_id)) { $log->warn("Can't get the id parameter of the volume"); next; }

                my $volume_name = $volume->get_parameter('name');
                if($volume->has_error) { $log->warn($volume->error_message); next; }
                unless(defined($volume_name)) { $log->warn("Can't get the name parameter of the volume"); next; }

                $info_volumes{$volume_id} = $volume;

                $log->info("The $volume_id ($volume_name) volume has been loaded");

            }

        }

    }

    foreach my $volume_id (keys(%info_volumes)) {

        $log->debug("Updating the information about the $volume_id volume");

        my $volume = $info_volumes{$volume_id};

        my $virtualmachines = $volume->find_related_to_me("virtualmachine");
        unless(defined($virtualmachines)) { $log->warn("Skipping the volume: " . $volume->error_message); next; }
        unless(scalar(@$virtualmachines)) {
            $log->debug("The volume doesn't seem to be attached, skipping host information loading");
            next;
        }

        foreach my $virtualmachine_dom (@{$virtualmachines}) {

            my $virtualmachine_id = eval { $virtualmachine_dom->findvalue('/virtualmachine/id') };
            if($@) { $log->warn("Can't $virtualmachine_dom->findvalue(): $@"); next; }

            unless(defined($info_virtualmachines{$virtualmachine_id})) {

                $log->trace("Loading the information about the $virtualmachine_id virtualmachine");

                my $virtualmachine = eval { MonkeyMan::CloudStack::Elements::VirtualMachine->new(
                    mm          => $mm,
                    load_dom    => {
                         dom        => $virtualmachine_dom
                    }
                ); };
                if($@) { $log->warn("Can't MonkeyMan::CloudStack::Elements::VirtualMachine->new(): $@"); next; }

                my $virtualmachine_id = $virtualmachine->get_parameter('id');
                if($virtualmachine->has_error) { $log->warn($virtualmachine->error_message); next; }
                unless(defined($virtualmachine_id)) { $log->warn("Can't get the ID of the virtualmachine"); next; }

                # Storing information about the virtualmachine

                $info_virtualmachines{$virtualmachine_id} = $virtualmachine;

                $log->info("The $virtualmachine_id virtualmachine has been loaded");

            }

        }

        my $storagepools = $volume->find_related_to_me("storagepool");
        unless(defined($storagepools)) { $log->warn("Skipping the volume: " . $volume->error_message); next; }
        unless(scalar(@$storagepools)) {
            $log->debug("The volume doesn't seem to be attached, skipping host information loading");
            next;
        }

        foreach my $storagepool_dom (@{$storagepools}) {

            my $storagepool_id = eval { $storagepool_dom->findvalue('/storagepool/id') };
            if($@) { $log->warn("Can't $storagepool_dom->findvalue(): $@"); next; }

            unless(defined($info_storagepools{$storagepool_id})) {

                $log->trace("Loading the information about the $storagepool_id storagepool");

                my $storagepool = eval { MonkeyMan::CloudStack::Elements::StoragePool->new(
                    mm          => $mm,
                    load_dom    => {
                         dom        => $storagepool_dom
                    }
                ); };
                if($@) { $log->warn("Can't MonkeyMan::CloudStack::Elements::StoragePool->new(): $@"); next; }

                my $storagepool_id = $storagepool->get_parameter('id');
                if($storagepool->has_error) { $log->warn($storagepool->error_message); next; }
                unless(defined($storagepool_id)) { $log->warn("Can't get the ID of the storagepool"); next; }

                # Storing information about the storagepool

                $info_storagepools{$storagepool_id} = $storagepool;

                $log->info("The $storagepool_id storagepool has been loaded");

            }

        }
    }

#    foreach my $virtualmachine_id (keys(%info_virtualmachines)) {
#
#        $log->debug("Updating the information about the $virtualmachine_id")
#
#        my $virtualmachine = $info_virtualmachines{$virtualmachine_id};
#
#        my $virtualmachine_hostid = $virtualmachine->get_parameter('hostid');
#        if($virtualmachine->has_error) { $log->warn($virtualmachine->error_message); next; }
#        unless(defined($virtualmachine_hostid)) { $log->debug("The virtual machine dosn't seem to be running"); next; }
#
#    }





    # ----------------------------------------------------------
    # Asking MM whats up, updating information about queued jobs



    # -------------------------------
    # Starting new snapshot processes



    # -------------------------------------------
    # Gathering and storing some usage statistics

    # Counting stats

    # Saving the queue and objects, MonkeyMan should be able to do that:
    #   $dump_id = $mm->dump_state();
    #   $restore = $mm->restore_state($dump_id);





    sleep 10; # shall be configured and/or calculated /!\
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

    foreach my $template_name (grep( /\*/, keys(%{ $schedule{$elements_type} }))) {
        $elements_set->{$template_name} = $schedule->{$elements_type}->{$template_name};
        $log->trace("The $template_name ${elements_type}'s template has been loaded");
    }

    # Loading elements

    my $elements_loaded = 0;

    foreach my $element_name (grep(!/\*/, keys(%{ $schedule{$elements_type} }))) {

        $log->trace("Configuring the $element_name $elements_type");

        # Getting the configuration of the new element from the schedule
        $elements_set->{$element_name} = $schedule->{$elements_type}->{$element_name};

        # Configuring the new element, adding configuration templates
 
        my %element_configured;
        my $layers_loaded = eval {
            configure_element(
                $elements_set,
                $element_name,
               \%element_configured
            );
        };
        $log->logdie("Can't configure_element(): $@") if($@);
        $elements_set->{$element_name} = \%element_configured;
        $elements_loaded++;

        $log->debug("The $element_name $elements_type with $layers_loaded configuration layers has been loaded");
        foreach my $parameter (keys(%{ $elements_set->{$element_name} })) {
            $log->debug(
                "The $element_name $elements_type has $parameter = " .
                $elements_set->{$element_name}->{$parameter}
            );
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
            $log->trace("The $pattern pattern matched the $element_name element");
            foreach (keys(%{ $elements_set->{$pattern} })) {
                $element_configured->{$_} = $elements_set->{$pattern}->{$_};
                $log->trace("The $element_name element has $_ = $element_configured->{$_}");
            }
            $matched_patterns++;
        }
    }

    return($matched_patterns);


}
