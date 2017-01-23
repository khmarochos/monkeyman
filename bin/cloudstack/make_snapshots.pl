#! /usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use constant 1.01;
use constant DEFAULT_TIMING_REFRESH => 600;
use constant DEFAULT_TIMING_SLEEP   => 10;
use constant SNAPSHOT_STATES        => {
    Unknown             => 0,
    Allocated           => 1,
    Creating            => 2,
    CreatedOnPrimary    => 3,
    Copying             => 4,
    BackingUp           => 5,
    BackedUp            => 6,
    Error               => 7,
    Destroying          => 8,
    Destroyed           => 9
};

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
use Time::Period;



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



my $in_progress = 0;

THE_LOOP: while(1) {

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
        (! $in_progress) && (
            (
                defined($components->{'rebuilt'}) ?
                        $components->{'rebuilt'} :
                       ($components->{'rebuilt'} = 0)
            ) + (
                defined($configuration->{'timings'}->{'refresh'}) ?
                        $configuration->{'timings'}->{'refresh'} :
                        DEFAULT_TIMING_REFRESH
            ) <= $time_now
        )
    ) {

        $logger->tracef(
            "Time to refresh the infrastructure view, the last time was at %s",
            $monkeyman->format_time($components->{'rebuilt'})
        );

        foreach my $element_type (keys(%{ $components_indices })) {
            $components->{ $element_type } = {};
        }

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

        %{ $components->{'Snapshot'}->{'by-id'} } = ();

        foreach my $snapshot ($api->perform_action(
            type        => 'Snapshot',
            action      => 'list',
            parameters  => { 'all'      => 1 },
            requested   => { 'element'  => 'element' },
            best_before => 0
        )) {

            my $snapshot_id         = $snapshot->get_id;
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

    $in_progress = 0;

    foreach my $volume_id (keys(%{ $components->{'Volume'}->{'by-id'} })) {

        my $volume_component    = $components->{'Volume'}->{'by-id'}->{ $volume_id };
        my $volume_element      = $volume_component->{'element'};

        # Examine each snapshot that is related to this volume

        $volume_component->{'snapshots_creating'}     = [];
        $volume_component->{'snapshots_backing_up'}   = [];
        $volume_component->{'last_time'} = 0;

        foreach my $snapshot_id (keys(%{ $volume_component->{'related'}->{'Snapshot'}->{'by-id'} })) {

            my $snapshot_component_saved                = dig(1, $volume_component, 'snapshots_state', 'by-id', $snapshot_id);
            my $snapshot_component_fresh                = dig(1, $components, 'Snapshot', 'by-id', $snapshot_id);
            my $snapshot_element                        = $snapshot_component_fresh->{'element'};
            unless(defined($snapshot_element)) {
                delete($volume_component->{'related'}->{'Snapshot'}->{'by-id'}->{ $snapshot_id });
                $logger->infof("The %s snapshot seems to be removed", $snapshot_id);
            }

            $snapshot_component_fresh->{'created'}      = $monkeyman->parse_time($snapshot_element->get_value('/created'));
            $snapshot_component_fresh->{'state'}        =                        $snapshot_element->get_value('/state');
            $volume_component->{'last_time'}            = $snapshot_component_fresh->{'created'} > $volume_component->{'last_time'} ?
                                                          $snapshot_component_fresh->{'created'} : $volume_component->{'last_time'};

            switch($snapshot_component_fresh->{'state'}) {

                case [ qw(Allocated Creating) ] {
                    push(@{ $volume_component->{'snapshots_creating'} }, $snapshot_id);
                    $logger->infof(
                        "The %s snapshot (%s) of the %s volume (%s) is being created",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(
                            snapshot_state_changed(
                                $snapshot_component_saved,
                                $snapshot_component_fresh,
                                $volume_component,
                                1,
                                $time_now,
                                $logger
                            ) &&
                            SNAPSHOT_STATES->{ $snapshot_component_saved->{'state'} } < SNAPSHOT_STATES->{'Allocated'} &&
                            $snapshot_component_saved->{'added'} != $snapshot_component_saved->{'updated'}
                        );
                }

                case [ qw(Copying BackingUp CreatedOnPrimary) ] {
                    push(@{ $volume_component->{'snapshots_backing_up'} }, $snapshot_id);
                    $logger->infof(
                        "The %s snapshot (%s) of the %s volume (%s) is being backed up",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(
                            snapshot_state_changed(
                                $snapshot_component_saved,
                                $snapshot_component_fresh,
                                $volume_component,
                                1,
                                $time_now,
                                $logger
                            ) &&
                            SNAPSHOT_STATES->{ $snapshot_component_saved->{'state'} } < SNAPSHOT_STATES->{'Copying'} &&
                            $snapshot_component_saved->{'added'} != $snapshot_component_saved->{'updated'}
                        );
                }

                case 'BackedUp' {
                    $logger->infof(
                        "The %s snapshot (%s) of the %s volume (%s) has been made!",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(
                            snapshot_state_changed(
                                $snapshot_component_saved,
                                $snapshot_component_fresh,
                                $volume_component,
                                1,
                                $time_now,
                                $logger
                            ) &&
                            $snapshot_component_saved->{'added'} != $snapshot_component_saved->{'updated'}
                        );
                }
                
                case 'Error' {
                    $logger->warnf(
                        "The %s snapshot (%s) of the %s volume (%s) is in the error state!",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element
                    )
                        if(
                            snapshot_state_changed(
                                $snapshot_component_saved,
                                $snapshot_component_fresh,
                                $volume_component,
                                1,
                                $time_now,
                                $logger
                            ) &&
                            $snapshot_component_saved->{'added'} != $snapshot_component_saved->{'updated'}
                        );
                }

                else {
                    $logger->warnf(
                        "The %s snapshot (%s) of the %s volume (%s) has an unusual state: %s",
                        $snapshot_id,
                        $snapshot_element,
                        $volume_id,
                        $volume_element,
                        $snapshot_component_fresh->{'state'}
                    )
                        if(
                            snapshot_state_changed(
                                $snapshot_component_saved,
                                $snapshot_component_fresh,
                                $volume_component,
                                1,
                                $time_now,
                                $logger
                            ) &&
                            $snapshot_component_saved->{'added'} != $snapshot_component_saved->{'updated'}
                        );
                }

            }

            $in_progress +=
                scalar(@{ $volume_component->{'snapshots_creating'} }) +
                scalar(@{ $volume_component->{'snapshots_backing_up'} });

        }

        # Determine which snapshots should be deleted
        if(defined(my $keep = $volume_component->{'configuration'}->{'keep'})) {
            my $snapshots_completed = 0;
            my $snapshots_related_by_id = $volume_component->{'related'}->{'Snapshot'}->{'by-id'};
            foreach my $snapshot_id (
                sort(
                    {
                           $components->{'Snapshot'}->{'by-id'}->{ $b }->{'created'}
                       <=> $components->{'Snapshot'}->{'by-id'}->{ $a }->{'created'}
                    } (keys(%{ $snapshots_related_by_id }))
                )
            ) {
                my $snapshot_component = $components->{'Snapshot'}->{'by-id'}->{ $snapshot_id };
                if($snapshot_component->{'state'} eq 'BackedUp' && ++$snapshots_completed > $keep) {
                    my $snapshot_element = $snapshot_component->{'element'};
                    if($parameters->get_dry_run) {
                        $logger->infof("Pretending like we're removing the %s snapshot (%s) for the %s volume (%s)",
                            $snapshot_id,
                            $snapshot_element,
                            $volume_id,
                            $volume_element
                        );
                    } else {
                        $logger->infof("Removing the %s snapshot (%s) for the %s volume (%s)",
                            $snapshot_id,
                            $snapshot_element,
                            $volume_id,
                            $volume_element
                        );
                        $api->perform_action(
                            type        => 'Snapshot',
                            action      => 'delete',
                            parameters  => { 'id'      => $snapshot_id },
                            requested   => { 'success' => 'value' },
                            wait        => 0,
                        );
                    }

                }
            }
        }

        # Get the newest snapshot and determine when the next one should has or had been created
        if($volume_component->{'last_time'}) {
            $logger->debugf("The newest snapshot for the %s volume (%s) had been created at %s",
                $volume_id,
                $volume_element,
                $monkeyman->format_time($volume_component->{'last_time'})
            );
        } else {
            $logger->debugf("There are no snapshots for the %s volume (%s)",
                $volume_id,
                $volume_element
            );
        }
        my $frequency = $volume_component->{'configuration'}->{'frequency'};
        if(defined($frequency) && $frequency) {
            $volume_component->{'next_time'} = $volume_component->{'last_time'} + $frequency;
            $logger->debugf("The next snapshot for the %s volume (%s) should %s created at %s",
                $volume_id,
                $volume_element,
              (($volume_component->{'next_time'} >= $time_now) ? 'be' : 'had been'),
                $monkeyman->format_time($volume_component->{'next_time'})
            );
        } else {
            $volume_component->{'next_time'} = -1;
            $logger->debugf("The next snapshot for the %s volume (%s) should never be created (frequency = 0)",
                $volume_id,
                $volume_element
            );
        }
    }



    # Start making the snapshots!

    foreach my $volume_id (sort({
              $components->{'Volume'}->{'by-id'}->{ $a }->{'next_time'}
          <=> $components->{'Volume'}->{'by-id'}->{ $b }->{'next_time'}
    } keys(%{ $components->{'Volume'}->{'by-id'} }))) {

        my $volume_component    = $components->{'Volume'}->{'by-id'}->{ $volume_id };
        my $volume_element      = $volume_component->{'element'};

	unless($volume_component->{ 'next_time' } >= 0) {
            $logger->tracef("The %s volume (%s) doesn't need a snapshot to be made",
                $volume_id,
                $volume_element
            );
            next;
        }

        unless($volume_component->{ 'next_time' } <= $time_now) {
            $logger->tracef("It's too early to make a snapshot for the %s volume (%s)",
                $volume_id,
                $volume_element
            );
            next;
        }

        unless((my @suitable = suitable($volume_element, $components, $time_now))[0] eq 'OK') {
            my(
                $component_element,
                $configuration_option,
                $value
            ) = @suitable;
            my $component_id    = $component_element->get_id;
            my $component_type  = $component_element->get_type;
            $logger->tracef(
                "The %s %s (%s) is unsuitable, " .
                "as it has the %s configuration option which is equal to %s, " .
                "whilst the current value is %s",
                $component_id,
                $component_element->get_type(plural => 0),
                $component_element,
                $configuration_option,
                $components->{ $component_element->get_type }->{'by-id'}->{ $component_id }->{'configuration'}->{ $configuration_option },
                $value
            );
            next;
        }

        if($parameters->get_dry_run) {
            $logger->infof("Pretending like we're creating a new snapshot for the %s volume (%s)",
                $volume_id,
                $volume_element
            );
        } else {
            $logger->infof("Creating a new snapshot for the %s volume (%s)",
                $volume_id,
                $volume_element
            );
            $api->perform_action(
                type        => 'Snapshot',
                action      => 'create',
                parameters  => { 'volumeid' => $volume_id },
                requested   => { 'element'  => 'element' },
                wait        => 0,
            );
        }

        next THE_LOOP;

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
    # Update the reference to the element
    $component->{'element'} = $element;
    # Fetch the component's configuration
    my $component_configuration = dig(1, $component, 'configuration');
    while(my($index_type, $index_value_query) = each(%{ $components_indices->{ $element_type } })) {
        my $index_value = $element->get_value($index_value_query);
        # Start configuring the component
        # Are there any pattern-defined settings to be applied?
        foreach my $pattern (sort { length($a) <=> length($b) } (grep(/\*/, keys(%{ $configuration->{ $element_type } })))) {
            if(match_glob($pattern, "$index_type:$index_value")) {
                %{ $component_configuration } = (
                    %{ $component_configuration },
                    %{ $configuration->{ $element_type }->{ $pattern } }
                );
            }
        }
        # Are there any configuration settings for this exact component to be applied?
        if(defined($configuration->{ $element_type }->{ "$index_type:$index_value" })) {
            %{ $component_configuration } = (
                %{ $component_configuration },
                %{ $configuration->{ $element_type }->{ "$index_type:$index_value" } }
            );
        }
        # OK, the component is configured, update the configuration add the component to the global catalog...
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

    $logger->debugf(
        "Checking the %s snapshot (%s): it's current state is %s, " .
        "it's previous state is %s",
        $snapshot_id,
        $snapshot_element,
        $snapshot_state_saved,
        $snapshot_state_fresh
    );

    $snapshot_component_saved->{'state'} = $snapshot_state_fresh
        if(SNAPSHOT_STATES->{ $snapshot_state_fresh } != SNAPSHOT_STATES->{ $snapshot_state_saved } && $change);

    return(0)
        if($snapshot_component_saved->{'added'} == ($snapshot_component_saved->{'updated'} = $time_now));

    return(SNAPSHOT_STATES->{ $snapshot_state_fresh }  - SNAPSHOT_STATES->{ $snapshot_state_saved });
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



func suitable (
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $components!,
    Int                                         $time_now!
) {

    my @result = qw(OK);

    my $element_id              = $element->get_id;
    my $element_type            = $element->get_type;
    my $component               = $components->{ $element_type }->{'by-id'}->{ $element_id };
    my $component_related       = $component->{'related'};
    my $component_configuration = $component->{'configuration'};

    # Are there too many active snapshots for this component?
    my $snapshots_active = count_snapshots($element, $components);
    return($element, 'flows_creating', $snapshots_active->{'creating'})
        if(
            defined($component_configuration->{'flows_creating'}) &&
                    $component_configuration->{'flows_creating'}  <= $snapshots_active->{'creating'}
        );
    return($element, 'flows_backing_up', $snapshots_active->{'backing_up'})
        if(
            defined($component_configuration->{'flows_backing_up'}) &&
                    $component_configuration->{'flows_backing_up'}  <= $snapshots_active->{'backing_up'}
        );

    # Is the component unavailable at this moment?
    return($element, 'available', $monkeyman->format_time($time_now))
        if(
            defined($component_configuration->{'available'}) &&
            !timely($element, $components, $configuration, $time_now)
        );

    # What about the related components then, are they OK?
    unless(defined($component_configuration->{'ignore_related'}) && $component_configuration->{'ignore_related'}) {
        foreach my $related_type (keys(%{ $component->{'related'} })) {
            foreach my $related_id (keys(%{ $component->{'related'}->{ $related_type }->{'by-id'} })) {
                my $related_element =       $component->{'related'}->{ $related_type }->{'by-id'}->{ $related_id }->{'element'};
                return(@result)
                    unless((@result = suitable($related_element, $components, $time_now))[0] eq 'OK');
            }
        }
    }

    return(@result);

}



func count_snapshots (
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $components!
) {

    my $element_stats;
    my $element_id      = $element->get_id;
    my $element_type    = $element->get_type;
    my $component       = $components->{ $element_type }->{'by-id'}->{ $element_id };

    if($element_type eq 'Volume') {
        $element_stats = {
            creating    => scalar(@{ $component->{'snapshots_creating'} }),
            backing_up  => scalar(@{ $component->{'snapshots_backing_up'} })
        };
    } else {
        $element_stats = {
            creating    => 0,
            backing_up  => 0
        };
        foreach my $volume_id (keys(%{ $components->{'Volume'}->{'by-id'} })) {
            my $volume_component    = $components->{'Volume'}->{'by-id'}->{ $volume_id };
            my $volume_element      = $volume_component->{'element'};
            if(defined($volume_component->{'related'}->{ $element_type }->{'by-id'}->{ $element_id })) {
                my $volume_stats = count_snapshots($volume_element, $components);
                $element_stats->{'creating'}    = $element_stats->{'creating'}      + $volume_stats->{'creating'};
                $element_stats->{'backing_up'}  = $element_stats->{'backing_up'}    + $volume_stats->{'backing_up'};
            }
        }
    }

    return($element_stats);

}


func timely (
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $components!,
    HashRef                                     $configuration!,
    Int                                         $time_now!
) {

    my $element_id      = $element->get_id;
    my $element_type    = $element->get_type;
    my $component       = $components->{ $element_type }->{'by-id'}->{ $element_id };

    my $available       = $component->{'configuration'}->{'available'};
    return(1)
        unless(defined($available));

    my $timeperiod      = $configuration->{ 'timeperiod' }->{ $available };
    MonkeyMan::Exception->throwf("The %s timeperiod isn't configured", $available)
        unless(defined($timeperiod));

    foreach my $period (
         ref( $timeperiod->{'period'} ) eq 'ARRAY' ?
           @{ $timeperiod->{'period'} } :
              $timeperiod->{'period'}
    ) {
        return(1)
            if(inPeriod($time_now, $period));
    }

    return(0);

}


