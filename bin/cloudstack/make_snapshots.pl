#! /usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use constant DEFAULT_TIMING_REFRESH => 3600;
use constant DEFAULT_TIMING_SLEEP   => 60;

# Use my own modules
use MonkeyMan;

# Use 3rd-party libraries
use Method::Signatures;
use Config::General qw(ParseConfig);
use Lingua::EN::Inflect qw(PL);
use String::CamelCase qw(decamelize);
use Text::Glob qw(match_glob); $Text::Glob::strict_wildcard_slash = 0;
use YAML::XS;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'make_snapshots.pl',
    app_description     => 'Create and removes snapshots',
    app_version         => $MonkeyMan::VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    -s, --schedule <filename>
        [req]       Points to the file containing the schedule
    -d, --dry-run
        [opt]       Makes the application emulating work
    -m, --max-volumes <number>
        [opt]       Limits the volume's quantity

__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
s|schedule=s:
  schedule:
    requires_each:
      - schedule
d|dry-run:
  dry_run:
m|max-volumes=s:
  max_volumes:
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);

my $parameters              = $monkeyman->get_parameters;
my $logger                  = $monkeyman->get_logger;
my $cloudstack              = $monkeyman->get_cloudstack;
my $api                     = $cloudstack->get_api;

my $configuration;
my $queue;
my $elements;
my $elements_relations = Load(<<__END_OF_ELEMENTS_RELATIONS__);
Volume:
  Snapshot:
  StoragePool:
  Domain         < by-path = /path >:
  VirtualMachine < by-instancename = /instancename >:
    Host:
__END_OF_ELEMENTS_RELATIONS__



LOOP: while(1) {

    my $time_now = time;

    # Loading the main configuration file if it isn't loaded
    unless(
        defined($configuration) &&
            ref($configuration) eq 'HASH'
    ) {
        $logger->tracef("The configuration needs to be loaded from the %s file", $parameters->get_schedule);
        %{ $configuration } = ParseConfig(
            -ConfigFile         => $parameters->get_schedule,
            -UseApacheInclude   => 1
        );
        $logger->tracef("The configuration is loaded: %s", $configuration);
        $queue = {};
    }

    # Do we need to refresh the information about all the elements?
    if(
        (
            defined($elements->{'rebuilt'}) ?
                    $elements->{'rebuilt'} :
                    0
        ) + (
            defined($configuration->{'timings'}->{'refresh'}) ?
                    $configuration->{'timings'}->{'refresh'} :
                    DEFAULT_TIMING_REFRESH
        ) < $time_now
    ) {

        my $volumes_got = 0;

        foreach my $volume ($api->perform_action(
            type        => 'Volume',
            action      => 'list',
            parameters  => { 'all'      => 1 },
            requested   => { 'element'  => 'element' }
        )) {

            configure_element(
                $volume,
                $volume,
                $elements, {
                    'by-name' => ($volume->qxp(query => '/name',   return_as => 'value'))[0],
                    'by-id'   => ($volume->qxp(query => '/id',     return_as => 'value'))[0]
                }
            );
            fetch_related(
                $volume,
                $volume,
                $elements,
                $elements_relations
            );

            last if(
                $parameters->has_max_volumes &&
                $parameters->get_max_volumes <= ++$volumes_got
            );

        }

        $elements->{'rebuilt'} = $time_now;

        $logger->debugf("All the elements are loaded: %s", $elements);

    }



    # Examine all the volumes to determine when the last snapshot had been created

    foreach my $volume_id (keys(%{ $elements->{'Volume'}->{'by-id'} })) {
        my $volume_bookmark = $elements->{'Volume'}->{'by-id'}->{ $volume_id };
        my $snapshot_bookmark_latest;
        foreach my $snapshot_id (keys(%{ $volume_bookmark->{'related'}->{'Snapshot'}->{'by-id'} })) {
            my $snapshot_bookmark = $elements->{'Snapshot'}->{'by-id'}->{ $snapshot_id };
            $snapshot_bookmark->{'state'}   =                        $snapshot_bookmark->{'element'}->get_value('/state');
            $snapshot_bookmark->{'created'} = $monkeyman->parse_time($snapshot_bookmark->{'element'}->get_value('/created'));
            # Who is the latest one?
            unless(
                (defined($snapshot_bookmark_latest)) &&
                ($snapshot_bookmark_latest->{'created'} > $snapshot_bookmark->{'created'})
            ) {
                $snapshot_bookmark_latest = $snapshot_bookmark;
            }
        }
        if(defined($snapshot_bookmark_latest)) {
            $volume_bookmark->{'next_time'} = $snapshot_bookmark_latest->{'created'} + $volume_bookmark->{'configuration'}->{'frequency'};
            $logger->debugf(
                "The latest snapshot of the %s volume (%s) is %s (%s), " .
                "its state is %s, it had been created at %s, " .
                "the next snapshot should be created at %s",
                $volume_bookmark->{'element'},
                $volume_bookmark->{'element'}->get_id,
                $snapshot_bookmark_latest->{'element'},
                $snapshot_bookmark_latest->{'element'}->get_id,
                $snapshot_bookmark_latest->{'state'},
                $monkeyman->format_time($snapshot_bookmark_latest->{'created'}),
                $monkeyman->format_time($volume_bookmark->{'next_time'})
            );
        } else {
            $volume_bookmark->{'next_time'} = $time_now;
            $logger->debugf(
                "The the %s volume (%s) doesn't have any snapshots yet, " .
                "the next snapshot should be created at %s",
                $volume_bookmark->{'element'},
                $volume_bookmark->{'element'}->get_id,
                $monkeyman->format_time($volume_bookmark->{'next_time'})
            );
        }
    }



    sleep(
        defined($configuration->{'timings'}->{'rest'}) ?
                $configuration->{'timings'}->{'rest'} :
                DEFAULT_TIMING_SLEEP
    );

}



func configure_element (
    MonkeyMan::CloudStack::API::Roles::Element  $master_element!,
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $elements!,
    HashRef                                     $indices!
) {
    my $element_type = $element->get_type;
    my $element_configured = {
        element         => $element,
        configuration   => {}
    };
    # Fetch the element's configuration
    while(my ($index_type, $index_value) = each(%{ $indices })) {
        # Are there any pattern-defined settings to be applied?
        foreach my $pattern (grep(/\*/, keys(%{ $configuration->{ $element_type } }))) {
            if(match_glob($pattern, "$index_type:$index_value")) {
                $element_configured->{'configuration'} = {
                    %{ $element_configured->{'configuration'} },
                    %{ $configuration->{ $element_type }->{ $pattern } }
                };
            }
        }
        # Are there any configuration settings for this exact element to be applied?
        if(defined($configuration->{ $element_type }->{ "$index_type:$index_value" })) {
            $element_configured->{'configuration'} = {
                %{ $element_configured->{'configuration'} },
                %{ $configuration->{ $element_type }->{ "$index_type:$index_value" } }
            };
        }
    }
    while(my ($index_type, $index_value) = each(%{ $indices })) {
        # OK, the element is configured, add it to the global element's catalog...
        $elements
            ->{ $element_type }
                ->{ $index_type }
                    ->{ $index_value }
                        = $element_configured;
        # ...as well as to the master element's related elements' list!
        $elements
            ->{ $master_element->get_type }
                ->{ 'by-id' }
                    ->{$master_element->get_id }
                        ->{'related'}
                            ->{ $element_type }
                                ->{ $index_type }
                                    ->{ $index_value }
                                        = $element_configured
                                            unless($master_element->get_type eq $element_type);
    }
    # Shall we inherit any configuration parameters to this master element?
    my $inherited_parameters;
    if(
        defined($inherited_parameters =
            $elements
                ->{ $master_element->get_type }
                    ->{ 'by-id' }
                        ->{ $master_element->get_id }
                            ->{'configuration'}
                                ->{'inherit'}
                                    ->{ $element_type }
        ) && ref($inherited_parameters) eq 'HASH'
    ) {
        foreach my $inherited_parameter (keys(%{ $inherited_parameters })) {
            my $inheritance_mode;
            my $master_element_configuration = 
                $elements
                    ->{ $master_element->get_type }
                        ->{ 'by-id' }
                            ->{ $master_element->get_id }
                                ->{'configuration'};
            if($inherited_parameters->{ $inherited_parameter } =~ /^(careful|forced)$/i) {
                $inheritance_mode = lc($1);
            } else {
                MonkeyMan::Exception->throwf(
                    "Invalid inheritance mode for the %s parameter of %s: %s",
                    $inherited_parameter,
                    $element_type,
                    $1
                );
            }
            if(
                defined(my $inherited_value = $element_configured->{'configuration'}->{ $inherited_parameter }) &&
                (
                    ($inheritance_mode eq 'forced') ||
                    ($inheritance_mode eq 'careful' && (! defined($master_element_configuration->{ $inherited_parameter })))
                )
            ) {
                $master_element_configuration->{ $inherited_parameter } = $inherited_value;
            }
        }
    }
}



func fetch_related (
    MonkeyMan::CloudStack::API::Roles::Element  $master_element!,
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $elements!,
    HashRef                                     $elements_relations!
) {

    my $element_type = $element->get_type;

    foreach (keys(%{ $elements_relations->{ $element_type } })) {
        my $related_type;
        my $related_extra_indices;
        # We're going to separate the element type from the extra indices (if there are any)
        if(/^
            (\S+)               # the element type is here
            (?:\s+              # the optional part
                <\s*(.+)\s*>    # the extra indices are bracketed
            )?
        $/x) {
            $related_type           = $1;
            $related_extra_indices  = $2;
        }
        my $what_to_find = 'our_' . PL(decamelize($related_type));
        foreach my $related_element ($element->get_related(related => $what_to_find, fatal => 0)) {
            my %extra_indices;
            if(defined($related_extra_indices)) {
                foreach my $extra_index (split(/\s*,\s*/, $related_extra_indices)) {
                    if($extra_index =~
                        /^
                            \s* (\S+) \s*
                            =
                            \s* (\S+) \s*
                        $/x
                    ) {
                        $extra_indices{$1} = $related_element->get_value($2)
                    }
                }
            }
            configure_element(
                $master_element,
                $related_element,
                $elements, {
                    'by-name'   => $related_element->get_value('/name'),
                    'by-id'     => $related_element->get_value('/id'),
                    %extra_indices
                }
            );
            fetch_related(
                $master_element,
                $related_element,
                $elements,
                $elements_relations->{ $element_type }
            );
        }
    }

}



