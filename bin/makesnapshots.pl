#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);

use lib("$Bin/../lib");

use MonkeyMan;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;

use Getopt::Long;
use Config::General qw(ParseConfig);
#use Text::Glob qw(match_glob); $Text::Glob::strict_wildcard_slash = 0;
#use File::Basename;



my %opts;

my $res = GetOptions(
    'h|help'        => \$opts{'help'},
      'version'     => \$opts{'version'},
    'c|config'      => \$opts{'config'},
    'v|verbose+'    => \$opts{'verbose'},
    'q|quiet'       => \$opts{'quiet'},
    'schedule=s'    => \$opts{'schedule'}
);
unless($res) {
    die("Can't GetOptions()");
}

if($opts{'help'})       { MonkeyMan::Show::help('makesnapshots');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;                 exit; };
unless(defined($opts{'schedule'})) {
    $log->logdie("The schedule hasn't been defined, see --help for more information");
}

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die("Can't MonkeyMan::new(): $@") if($@);

my $log = $mm->logger;
die($mm->error_message) unless(defined($log));

my $api = $mm->init_cloudstack_api;
die($mm->error_message) unless(defined($api));



my %schedule;
my %conf_timeperiods;
my %conf_storages;
my %conf_hosts;
my %conf_domains;
my %info_storages;
my %info_hosts;
my %info_domains;
my %info_instances;
my %info_volumes;
my %info_snapshots;
my %queue;

THE_LOOP: while (1) {

    # Reload everything If the schedule hasn't been loaded or has been reset

    unless(defined(%schedule)) {
        %schedule = eval {
            ParseConfig(
                -ConfigFile         => $opts{'schedule'},
                -UseApacheInclude   => 1
            );
        };
        if($@) {
            $log->logdie("Can't Config::General::ParseConfig(): $@");
        }
        $log->debug("The schedule has been loaded");
        undef(%conf_timeperiods);
        undef(%conf_storages);
        undef(%conf_hosts);
        undef(%conf_domains);
        undef(%queue);
    }

    # Dealing with all configuration sections (reloading them if needed)

    foreach my $section (
        { hash => \%conf_timeperiods,   type => 'timeperiod' },
        { hash => \%conf_storages,      type => 'storage' },
        { hash => \%conf_hosts,         type => 'host' },
        { hash => \%conf_domains,       type => 'domain' }
    ) {
        unless(defined(%{ $section->{'hash'}})) {
            $log->trace("Some $section->{'type'}s definitely need to be defined");
            my $elements_loaded = eval {
                load_element(
                    \%schedule,
                    $section->{'type'},
                    $section->{'hash'}
                );
            };
            if($@) { $log->die("Can't load_element(): $@"); };
            $log->trace("$elements_loaded $section->{'type'}s loaded");
        }
    }



    # Checking if there's anything in the queue and does it need to be set up.
    # I want to be able to reload the configuration without reloading the queue,
    # by SIGHUP or some shit like that. And SIGUSR1 shall rebuild the queue.
    # So that's why there's a separate condition for this task.

    unless(defined(%queue)) {

        # For every configured domain...

        foreach my $domain_path (grep(!/\*/, keys(%conf_domains))) {

            # Getting the information about the domain

            my $domain = $cloudstack->runcmd(
                parameters  => {
                    command     => 'listDomains',
                    keyword     => basename($domain_path)
                },
                options     => {
                    xpath       => "/listdomainsresponse/domain[path='$domain_path']",
                    result      => 'node'
                }
            )->pop();
            unless(defined($domain)) {
                $log->logdie("Can't MonkeyMan::CloudStack::API->runcmd(): $cloudstack->{'errstr'}");
            }
            $info_domains{$domain->findvalue('id')} = $domain;
            $log->debug("The domain $domain_path has been identified as " . $domain->findvalue('id'));

            # Getting the list of instances in the domain

            my $instances_list = $cloudstack->runcmd(
                parameters  => {
                    command     => 'listVirtualMachines',
                    listall     => 'true',
                    domainid    => $domain->findvalue('id')
                },
                options     => {
                    xpath       => '//listvirtualmachinesresponse/virtualmachine',
                    result      => 'node'
                }
            );
            unless(defined($instances_list)) {
                $log->logdie("Can't MonkeyMan::CloudStack::API->runcmd(): $cloudstack->{'errstr'}");
            }

            # For every instance...

            foreach my $instance ($instances_list->get_nodelist) {

                $info_instances{$instance->findvalue('id')} = $instance;
                $log->debug("The instance " . $instance->findvalue('id') . " has been identified");

                # Getting the list of volumes

                my $volumes_list = $cloudstack->runcmd(
                    parameters  => {
                        command             => 'listVolumes',
                        listall             => 'true',
                        virtualmachineid    => $instance->findvalue('id')
                    },
                    options     => {
                        xpath       => '//listvolumesresponse/volume',
                        result      => 'node'
                    }
                );
                unless(defined($instances_list)) {
                    $log->logdie("Can't MonkeyMan::CloudStack::API->runcmd(): $cloudstack->{'errstr'}");
                }

                # Getting the information about the host (if needed)

                unless(defined($info_hosts{$instance->findvalue('hostid')})) {

                    my $host = $cloudstack->runcmd(
                        parameters  => {
                            command     => 'listHosts',
                            id          => $instance->findvalue('hostid')
                        },
                        options     => {
                            xpath       => '//listhostsresponse/host',
                            result      => 'node'
                        }
                    )->pop();
                    unless(defined($host)) {
                        $log->logdie("Can't MonkeyMan::CloudStack::API->runcmd(): $cloudstack->{'errstr'}");
                    }

                    $info_hosts{$host->findvalue('id')} = $host;

                    $log->debug("The host " . $host->findvalue('id') . " has been identified");

                }

                # For every volume...

                foreach my $volume ($volumes_list->get_nodelist) {

                    $info_volumes{$volume->findvalue('id')} = $volume;
                    $log->debug("The volume " . $volume->findvalue('id') . " has been identified");

                    # Getting the information about the storage (if needed)

                    unless(eval {
                        foreach my $storage (valuess(%info_storages)) {
                            return 1 if($storage->findvalue('name') eq $volume->findvalue('storage'));
                        }
                    }) {

                        my $storage = $cloudstack->runcmd(
                            parameters  => {
                                command     => 'listStoragePools',
                                name        => $volume->findvalue('storage')
                            },
                            options     => {
                                xpath       => '//liststoragepoolsresponse/storagepool',
                                result      => 'node'
                            }
                        )->pop();
                        unless(defined($storage)) {
                            $log->logdie("Can't MonkeyMan::CloudStack::API->runcmd(): $cloudstack->{'errstr'}");
                        }

                        $info_storages{$storage->findvalue('id')} = $storage;

                        $log->debug("The storage " . $storage->findvalue('id') . " has been identified");

                    }

                    $queue{$volume->findvalue('id')} = {
                        volume      => $volume,
                        instance    => $instance,
                        domain      => $domain
                    }

               }
            }

        }
    }



    last(THE_LOOP);

}


sub load_element {
    
    my($schedule, $name, $set) = @_;
    unless(
        ref($schedule) eq 'HASH' &&
        defined($name) &&
        ref($set) eq 'HASH'
    ) {
        die("Required parameters haven't been defined");
    }

    # Loding templates

    foreach my $element (grep( /\*/, keys(%{ $schedule{$name} }))) {
        $set->{$element} = $schedule->{$name}->{$element};
        $log->trace("The $name template $element has been loaded");
    }

    my $elements_loaded = 0;

    # Loading elements

    foreach my $element (grep(!/\*/, keys(%{ $schedule{$name} }))) {

        $log->trace("Configuring the $name $element");

        # Getting the new element from the schedule
        $set->{$element} = $schedule->{$name}->{$element};

        # Configuring the new element, implementing templates
        my %element_configured;
        my $layers_loaded = eval{
            configure_element(
                $set,
                $element,
                \%element_configured
            );
        };
        if($@) { $log->logdie("Can't configure_element(): $@"); };
        $set->{$element} = \%element_configured;
        $elements_loaded++;
        $log->debug("The $name $element with $layers_loaded configuration layers loaded");
        foreach my $parameter (keys(%{ $set->{$element} })) {
            $log->debug("The $name has $parameter = $set->{$element}->{$parameter}");
        }
    }

    return($elements_loaded);

};

sub configure_element {

    my($set, $name, $element) = @_;
    unless(
        ref($set) eq 'HASH' &&
        defined($name) &&
        ref($element) eq 'HASH'
    ) {
        die("Required parameters haven't been defined");
    }

    # Will try to compare every pattern to the given name,
    # will return the exact number of patterns matched,
    # so, yes, 0 means nothing has matched.

    my $matched_patterns = 0;

    foreach my $pattern (sort(keys(%{ $set }))) {
        if(match_glob($pattern, $name)) {
            $log->trace("The pattern $pattern matched the name $name");
            foreach (keys(%{ $set->{$pattern} })) {
                $element->{$_} = $set->{$pattern}->{$_};
                $log->trace("$_ = $element->{$_}");
            }
            $matched_patterns++;
        }
    }

    return($matched_patterns);


}
