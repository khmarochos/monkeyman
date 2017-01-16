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
            requested   => { 'element'  => 'element' },
            best_before => 0
        )) {

            refresh_component(
                $volume,
                $volume,
                $components,
                $components_relations,
                $components_indices,
                $configuration,
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
                    $snapshot_id,
                    $snapshot,
                    $volume_id
                );
                next;
            }

            my $volume = $volume_component->{'element'};

            configure_component(
                $volume,
                $snapshot,
                $components,
                $components_indices,
                $configuration
            );
            $logger->tracef(
                "The %s snapshot (%s) of the %s volume (%s) has been refreshed",
                $snapshot_id,
                $snapshot,
                $volume_id,
                $volume
            );

        }

    }



    # Examine all the volumes' snapshots

    foreach my $volume_id (keys(%{ $components->{'Volume'}->{'by-id'} })) {

        my $volume_component    = $components->{'Volume'}->{'by-id'}->{ $volume_id };
        my $volume_element      = $volume_component->{'element'};

        # Examine each snapshot that is related to this volume

        foreach my $snapshot_id (keys(%{ $volume_component->{'related'}->{'Snapshot'}->{'by-id'} })) {

            my $snapshot_component_saved                = dig(1, $volume_component, 'snapshots_state',      'by-id', $snapshot_id);
            my $snapshot_component_fresh                = dig(0, $volume_component, 'related', 'Snapshot',  'by-id', $snapshot_id);
            my $snapshot_element                        = $snapshot_component_fresh->{'element'};
               $snapshot_component_fresh->{'created'}   = $monkeyman->parse_time($snapshot_element->get_value('/created'));
               $snapshot_component_fresh->{'state'}     =                        $snapshot_element->get_value('/state');

            switch($snapshot_component_fresh->{'state'}) {

                case 'Creating' {
                    $logger->infof(
                        "The %s snapshot (%s) of the %s volume (%s) is being created",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(snapshot_state_changed(
                            $snapshot_component_saved,
                            $snapshot_component_fresh,
                            $volume_component,
                            1,
                            $time_now,
                            $logger
                        ));
                }

                case [ qw(BackingUp CreatedOnPrimary) ] {
                    $logger->infof(
                        "The %s snapshot (%s) of the %s volume (%s) is being backed up",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(snapshot_state_changed(
                            $snapshot_component_saved,
                            $snapshot_component_fresh,
                            $volume_component,
                            1,
                            $time_now,
                            $logger
                        ));
                }

                case 'BackedUp' {
                    $logger->infof(
                        "The %s snapshot (%s) of the %s volume (%s) has been made!",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(snapshot_state_changed(
                            $snapshot_component_saved,
                            $snapshot_component_fresh,
                            $volume_component,
                            1,
                            $time_now,
                            $logger
                        ));
                }
                
                case 'Error' {
                    $logger->warnf(
                        "The %s snapshot (%s) of the %s volume (%s) hasn't been made!",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(snapshot_state_changed(
                            $snapshot_component_saved,
                            $snapshot_component_fresh,
                            $volume_component,
                            1,
                            $time_now,
                            $logger
                        ));
                }

                else {
                    $logger->warnf(
                        "The %s snapshot (%s) of the %s volume (%s) has an unusual state: %s",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element,
                        $snapshot_component_fresh->{'state'}
                    );
                }

            }

        }

        # Now let's sort the snapshots by their creation time
        my @snapshots_sorted;
        foreach my $snapshot_id (sort(
            {
                         $volume_component->{'snapshots_state'}->{'by-id'}->{ $a }->{'created'} <=>
                         $volume_component->{'snapshots_state'}->{'by-id'}->{ $b }->{'created'}
            }
                (keys(%{ $volume_component->{'snapshots_state'}->{'by-id'} }))
        )) {
            push(@snapshots_sorted, $snapshot_id);
            $logger->debugf(
                "The %s snapshot had been created at %s",
                $snapshot_id,
                $monkeyman->format_time($volume_component->{'snapshots_state'}->{'by-id'}->{ $snapshot_id }->{'created'})
            );
        }
        $volume_component->{'snapshots_sorted'}->{'by-id'} = \@snapshots_sorted;
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
    HashRef                                     $configuration!,
    Bool                                        $recursive!
) {

    my $element_type = $element->get_type;

    configure_component(
        $master_element,
        $element,
        $components,
        $components_indices,
        $configuration
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
                $configuration,
                1
            );
        }
    }

}



func configure_component (
    MonkeyMan::CloudStack::API::Roles::Element  $master_element!,
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $components!,
    HashRef                                     $components_indices!,
    HashRef                                     $configuration!
) {
    my $element_id          = $element->get_id;
    my $element_type        = $element->get_type;
    my $master_element_id   = $master_element->get_id;
    my $master_element_type = $master_element->get_type;
    # Initialize the component only if it's needed
    my $component = dig(1, $components, $element_type, 'by-id', $element_id);
    # Fetch the component's configuration
    while(my($index_type, $index_value_query) = each(%{ $components_indices->{ $element_type } })) {
        my $index_value = $element->get_value($index_value_query);
        # Update the reference to the element
        $component->{'element'} = $element;
        # Start configuring the component
        my %component_configuration = ();
        # Are there any pattern-defined settings to be applied?
        foreach my $pattern (grep(/\*/, keys(%{ $configuration->{ $element_type } }))) {
            if(match_glob($pattern, "$index_type:$index_value")) {
                %component_configuration = (
                    %component_configuration,
                    %{ $configuration->{ $element_type }->{ $pattern } }
                );
            }
        }
        # Are there any configuration settings for this exact component to be applied?
        if(defined($configuration->{ $element_type }->{ "$index_type:$index_value" })) {
            %component_configuration = (
                %component_configuration,
                %{ $configuration->{ $element_type }->{ "$index_type:$index_value" } }
            );
        }
        # OK, the component is configured, update the configuration add the component to the global catalog...
        $component->{'configuration'} = \%component_configuration;
        $components
            ->{ $element_type }
                ->{ $index_type }
                    ->{ $index_value }
                        = $component;
        # ...as well as to the master component's related elements' list!
        $components
            ->{ $master_element_type }
                ->{ 'by-id' }
                    ->{ $master_element_id }
                        ->{'related'}
                            ->{ $element_type }
                                ->{ $index_type }
                                    ->{ $index_value }
                                        = $component
                                            unless($master_element_type eq $element_type);
    }
    # Shall we inherit any configuration from this component parameters to the component of the master element?
    my $inherited_parameters;
    if(
        defined($inherited_parameters =
            $components
                ->{ $master_element_type }
                    ->{ 'by-id' }
                        ->{ $master_element_id }
                            ->{'configuration'}
                                ->{'inherit'}
                                    ->{ $element_type }
        ) && ref($inherited_parameters) eq 'HASH'
    ) {
        foreach my $inherited_parameter (keys(%{ $inherited_parameters })) {
            my $inheritance_mode;
            my $master_element_configuration = 
                $components
                    ->{ $master_element_type }
                        ->{ 'by-id' }
                            ->{ $master_element_id }
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
                defined(my $inherited_value = $component->{'configuration'}->{ $inherited_parameter }) &&
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
    HashRef             $snapshot_component_saved!,
    HashRef             $snapshot_component_fresh!,
    HashRef             $volume_component!,
    Bool                $change!,
    Int                 $time_now!,
    MonkeyMan::Logger   $logger!
) {
    my $snapshot_created    = $snapshot_component_fresh->{'created'};
    my $snapshot_element    = $snapshot_component_fresh->{'element'};
    my $snapshot_id         = $snapshot_element->get_id;

    $snapshot_component_saved->{'created'}  = $snapshot_created unless defined($snapshot_component_saved->{'created'});
    $snapshot_component_saved->{'added'}    = $time_now         unless defined($snapshot_component_saved->{'added'});
    $snapshot_component_saved->{'state'}    = 'Unknown'         unless defined($snapshot_component_saved->{'state'});
    my $snapshot_state_saved = $snapshot_component_saved->{'state'};
    my $snapshot_state_fresh = $snapshot_component_fresh->{'state'};

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
        "it's previous state is %s",
        $snapshot_id,
        $snapshot_element,
        $snapshot_state_saved,
        $snapshot_state_fresh
    );

    $snapshot_component_saved->{'updated'} = $time_now;
    $snapshot_component_saved->{'state'} = $snapshot_state_fresh
        if(($sequence->{ $snapshot_state_fresh } != $sequence->{ $snapshot_state_saved }) && $change);

    return($sequence->{ $snapshot_state_fresh } - $sequence->{ $snapshot_state_saved });
}



func dig (Bool $create!, HashRef $hashref!, @keys?) {
    if(my $key = shift(@keys)) {
        return(defined($hashref->{ $key }) ?
            (@keys   ? dig($create, $hashref->{ $key }     , @keys) : $hashref->{ $key }) :
            ($create ? dig($create, $hashref->{ $key } = {}, @keys) : undef)
        );
    } else {
        return($hashref);
    }
}
