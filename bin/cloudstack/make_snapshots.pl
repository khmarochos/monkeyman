#! /usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use constant DEFAULT_TIMING_REFRESH => 600;
use constant DEFAULT_TIMING_SLEEP   => 10;

# Use my own modules
use MonkeyMan;

# Use 3rd-party libraries
use Switch;
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
my $components;
my $components_relations = Load(<<__END_OF_COMPONENTS_RELATIONS__);
Volume:
  Snapshot:
  StoragePool:
  Domain:
  VirtualMachine:
    Host:
__END_OF_COMPONENTS_RELATIONS__
my $components_indices = Load(<<__END_OF_COMPONENTS_INDICES__);
Volume:         { by-id: /id, by-name: /name }
Snapshot:       { by-id: /id, by-name: /name }
StoragePool:    { by-id: /id, by-name: /name }
Domain:         { by-id: /id, by-name: /name, by-path: /path }
VirtualMachine: { by-id: /id, by-name: /name, by-instancename: /instancename }
Host:           { by-id: /id, by-name: /name }
__END_OF_COMPONENTS_INDICES__



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

    # Do we need to refresh the information about all the components?
    if(
        (
            defined($components->{'rebuilt'}) ?
                    $components->{'rebuilt'} :
                   ($components->{'rebuilt'} = 0)
        ) + (
            defined($configuration->{'timings'}->{'refresh'}) ?
                    $configuration->{'timings'}->{'refresh'} :
                    DEFAULT_TIMING_REFRESH
        ) <= $time_now
    ) {

        $logger->tracef(
            "Time to refresh the infrastructure view, the last time was at %s",
            $monkeyman->format_time($components->{'rebuilt'})
        );

        my $volumes_got = 0;

        foreach my $volume ($api->perform_action(
            type        => 'Volume',
            action      => 'list',
            parameters  => { 'all'      => 1 },
            requested   => { 'element'  => 'element' }
        )) {

            refresh_component(
                $volume,
                $volume,
                $components,
                $components_relations,
                $components_indices,
                1
            );

            last if(
                $parameters->has_max_volumes &&
                $parameters->get_max_volumes <= ++$volumes_got
            );

        }

        $components->{'rebuilt'} = $time_now;

        $logger->debugf("All the components are loaded: %s", $components);

    } else {

        foreach my $snapshot ($api->perform_action(
            type        => 'Snapshot',
            action      => 'list',
            parameters  => { 'all'      => 1 },
            requested   => { 'element'  => 'element' },
            best_before => 0
        )) {

            my $snapshot_id         = $snapshot->get_id;
            my $snapshot_component  = $components->{'Snapshot'}->{'by-id'}->{ $snapshot_id };
            my $volume_id           = $snapshot->get_value('/volumeid');
            my $volume_component    = $components->{'Volume'}->{'by-id'}->{ $volume_id };

            unless(defined($volume_component)) {
                $logger->tracef(
                    "The %s snapshot (%s) has been found, but the %s volume isn't present in the components' map, skipping it",
                    $snapshot,
                    $snapshot_id,
                    $volume_id
                );
                next;
            }

            my $volume = $volume_component->{'element'};

            configure_component(
                $volume,
                $snapshot,
                $components,
                $components_indices
            );
            $logger->tracef(
                "The %s snapshot (%s) of the %s volume (%s) has been refreshed",
                $snapshot,
                $snapshot_id,
                $volume,
                $volume_id,
            );

        }

    }



    # Examine all the volumes' snapshots

    foreach my $volume_id (keys(%{ $components->{'Volume'}->{'by-id'} })) {

        my $volume_component = $components->{'Volume'}->{'by-id'}->{ $volume_id };

        my $snapshot_component_latest;

        # Examine each snapshot that is related to this volume

        foreach my $snapshot_id (keys(%{ $volume_component->{'related'}->{'Snapshot'}->{'by-id'} })) {

            my $snapshot_component              = $components->{'Snapshot'}->{'by-id'}->{ $snapshot_id };
            $snapshot_component->{'created'}    = $monkeyman->parse_time($snapshot_component->{'element'}->get_value('/created'));
            $snapshot_component->{'state'}      =                        $snapshot_component->{'element'}->get_value('/state');

            switch($snapshot_component->{'state'}) {

                case 'Creating' {
                    $logger->infof(
                        "The %s snapshot (%s) of the (%s) volume (%s) is being created",
                        $snapshot_component->{'element'},
                        $snapshot_component->{'element'}->get_id,
                        $volume_component->{'element'},
                        $volume_component->{'element'}->get_id
                    )
                        if(snapshot_state_changed($snapshot_component, $volume_component, 1, $time_now, $logger));
                }

                case [ qw(BackingUp CreatedOnPrimary) ] {
                    $logger->infof(
                        "The %s snapshot (%s) of the (%s) volume (%s) is being backed up",
                        $snapshot_component->{'element'},
                        $snapshot_component->{'element'}->get_id,
                        $volume_component->{'element'},
                        $volume_component->{'element'}->get_id
                    )
                        if(snapshot_state_changed($snapshot_component, $volume_component, 1, $time_now, $logger));
                }

                case 'BackedUp' {
                    $logger->infof(
                        "The %s snapshot (%s) of the (%s) volume (%s) has been made!",
                        $snapshot_component->{'element'},
                        $snapshot_component->{'element'}->get_id,
                        $volume_component->{'element'},
                        $volume_component->{'element'}->get_id
                    )
                        if(snapshot_state_changed($snapshot_component, $volume_component, 1, $time_now, $logger));
                }
                
                case 'Error' {
                    $logger->warnf(
                        "The %s snapshot (%s) of the (%s) volume (%s) hasn't been made!",
                        $snapshot_component->{'element'},
                        $snapshot_component->{'element'}->get_id,
                        $volume_component->{'element'},
                        $volume_component->{'element'}->get_id
                    )
                        if(snapshot_state_changed($snapshot_component, $volume_component, 1, $time_now, $logger));
                }

                else {
                    $logger->warnf(
                        "The %s snapshot (%s) of the (%s) volume (%s) has an unusual state: %s",
                        $snapshot_component->{'element'},
                        $snapshot_component->{'element'}->get_id,
                        $volume_component->{'element'},
                        $volume_component->{'element'}->get_id,
                        $snapshot_component->{'state'}
                    );
                }

            }

            # What snapshot is the latest one?

            unless(
               (defined($snapshot_component_latest)) &&
               ($snapshot_component_latest->{'created'} > $snapshot_component->{'created'})
            ) {
                $snapshot_component_latest = $snapshot_component;
            }

        }

        # Determine when it's time to create the next snapshot

        if(defined($snapshot_component_latest)) {

            $volume_component->{'next_time'} =
                $snapshot_component_latest->{'created'} + $volume_component->{'configuration'}->{'frequency'};

            $logger->tracef(
                "The latest snapshot of the %s volume (%s) is %s (%s), " .
                "its state is %s, it had been created at %s, " .
                "the next snapshot should be created at %s",
                $volume_component->{'element'},
                $volume_component->{'element'}->get_id,
                $snapshot_component_latest->{'element'},
                $snapshot_component_latest->{'element'}->get_id,
                $snapshot_component_latest->{'state'},
                $monkeyman->format_time($snapshot_component_latest->{'created'}),
                $monkeyman->format_time($volume_component->{'next_time'})
            );

        } else {

            $volume_component->{'next_time'} = $time_now;

            $logger->tracef(
                "The %s volume (%s) doesn't have any snapshots yet, " .
                "the next snapshot should be created at %s",
                $volume_component->{'element'},
                $volume_component->{'element'}->get_id,
                $monkeyman->format_time($volume_component->{'next_time'})
            );

        }
    }



    sleep(
        defined($configuration->{'timings'}->{'rest'}) ?
                $configuration->{'timings'}->{'rest'} :
                DEFAULT_TIMING_SLEEP
    );

}



func refresh_component (
    MonkeyMan::CloudStack::API::Roles::Element  $master_element!,
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $components!,
    HashRef                                     $components_relations!,
    HashRef                                     $components_indices!,
    Bool                                        $recursive!
) {

    my $element_type = $element->get_type;

    configure_component(
        $master_element,
        $element,
        $components,
        $components_indices
    );

    foreach my $related_type (keys(%{ $components_relations->{ $element_type } })) {
        my $what_to_find = 'our_' . PL(decamelize($related_type));
        foreach my $related_element ($element->get_related(related => $what_to_find, fatal => 0)) {
            refresh_component(
                $master_element,
                $related_element,
                $components,
                $components_relations->{ $element_type },
                $components_indices,
                1
            );
        }
    }

}



func configure_component (
    MonkeyMan::CloudStack::API::Roles::Element  $master_element!,
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $components!,
    HashRef                                     $components_indices!
) {
    my $element_type            = $element->get_type;
    my $component_configured    = {
        element         => $element,
        configuration   => {},
        master          => {}
    };
    # Fetch the component's configuration
    while(my($index_type, $index_value_query) = each(%{ $components_indices->{ $element_type } })) {
        my $index_value = $element->get_value($index_value_query);
        # Are there any pattern-defined settings to be applied?
        foreach my $pattern (grep(/\*/, keys(%{ $configuration->{ $element_type } }))) {
            if(match_glob($pattern, "$index_type:$index_value")) {
                $component_configured->{'configuration'} = {
                    %{ $component_configured->{'configuration'} },
                    %{ $configuration->{ $element_type }->{ $pattern } }
                };
            }
        }
        # Are there any configuration settings for this exact component to be applied?
        if(defined($configuration->{ $element_type }->{ "$index_type:$index_value" })) {
            $component_configured->{'configuration'} = {
                %{ $component_configured->{'configuration'} },
                %{ $configuration->{ $element_type }->{ "$index_type:$index_value" } }
            };
        }
        # OK, the component is configured, add it to the global element's catalog...
        $components
            ->{ $element_type }
                ->{ $index_type }
                    ->{ $index_value }
                        = $component_configured;
        # ...as well as to the master component's related elements' list!
        $components
            ->{ $master_element->get_type }
                ->{ 'by-id' }
                    ->{ $master_element->get_id }
                        ->{'related'}
                            ->{ $element_type }
                                ->{ $index_type }
                                    ->{ $index_value }
                                        = $component_configured
                                            unless($master_element->get_type eq $element_type);
    }
    # Shall we inherit any configuration parameters to the component of the master element?
    my $inherited_parameters;
    if(
        defined($inherited_parameters =
            $components
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
                $components
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
                defined(my $inherited_value = $component_configured->{'configuration'}->{ $inherited_parameter }) &&
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



func snapshot_state_changed (
    HashRef             $snapshot_component!,
    HashRef             $volume_component!,
    Bool                $change!,
    Int                 $time_now!,
    MonkeyMan::Logger   $logger!
) {
    my $state_changed;
    my $snapshots_active    = $volume_component->{'snapshots_active'};
    my $snapshot_id         = $snapshot_component->{'element'}->get_id;

    unless(defined($snapshots_active)) {
                   $snapshots_active = $volume_component->{'snapshots_active'} = {};
    }
    unless(defined($snapshots_active->{'by-id'}->{ $snapshot_id })) {
                   $snapshots_active->{'by-id'}->{ $snapshot_id } = { state => 'Unknown', added => $time_now };
    }

    my $snapshot_state_previous = $snapshots_active->{'by-id'}->{ $snapshot_id }->{'state'};
    my $snapshot_state_current  = $snapshot_component->{'state'};

    my $sequence = {
        Unknown             => 0,
        Creating            => 1,
        CreatedOnPrimary    => 2,
        BackingUp           => 3,
        BackedUp            => 4,
        Error               => 5
    };

    $logger->debugf(
        "Checking the %s snapshot (%s): it's current state is %s, " .
        "it's previous state is %s, " .
        "(more information could be found in %s and %s)",
        $snapshot_component->{'element'},
        $snapshot_id,
        $snapshot_state_current,
        $snapshot_state_previous,
        $snapshot_component,
        $snapshots_active
    );

    if(
        ($sequence->{ $snapshot_state_previous } < $sequence->{'Creating'}) &&
        ($sequence->{ $snapshot_state_current }  > $sequence->{'BackingUp'})
    ) {
        # The snapshot neither was active nor is
        delete($snapshots_active->{ $snapshot_id });
        return(0);
    } elsif ($sequence->{ $snapshot_state_previous } == $sequence->{ $snapshot_state_current }) {
        # The snapshot was active and still is
        $snapshots_active->{'by-id'}->{ $snapshot_id }->{'updated'} = $time_now;
        return(0);
    } elsif($sequence->{ $snapshot_state_previous } < $sequence->{ $snapshot_state_current }) {
        # The snapshot was active, its state has changed
        if($sequence->{ $snapshot_state_current } > $sequence->{'BackingUp'}) {
            # If we're here it means that the snapshot isn't active anymore,
            # so we should delete it from the list of active ones
            delete($snapshots_active->{ $snapshot_id });
            return($sequence->{ $snapshot_state_current })
        } else {
            # It means that the snapshot is still active
            $snapshots_active->{'by-id'}->{ $snapshot_id }->{'state'}   = $snapshot_state_current;
            $snapshots_active->{'by-id'}->{ $snapshot_id }->{'updated'} = $time_now;
            return($sequence->{ $snapshot_state_current })
        }
    } else {
        # FIXME: Show a warning here!
        return($sequence->{ $snapshot_state_current })
    }
}
