#! /usr/bin/env perl

# Use pragmas
use strict;
use warnings;

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
        [req]       The file containing the schedule
    -d, --dry-run
        [opt]       Don't create the snapshots, emulate work

__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
s|schedule=s:
  schedule:
    requires_each:
      - schedule
d|dry-run:
  dry_run:
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
Domain:
  Volume:
    Snapshot:
    StoragePool:
    VirtualMachine:
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
                    3600
        ) < $time_now
    ) {

        foreach my $domain ($api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { 'all'      => 1 },
            requested   => { 'element'  => 'element' }
        )) {

            configure_element(
                $domain,
                $elements, {
                    'by-path' => ($domain->qxp(query => '/path',   return_as => 'value'))[0],
                    'by-id'   => ($domain->qxp(query => '/id',     return_as => 'value'))[0]
                }
            );
            fetch_related(
                $domain,
                $elements,
                $elements_relations
            );

        }

        $elements->{'rebuilt'} = $time_now;

        $logger->debugf("All the elements are loaded: %s", $elements);

    }



    sleep(
        defined($configuration->{'timings'}->{'rest'}) ?
                $configuration->{'timings'}->{'rest'} :
                60
    );

}



func configure_element (
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
    # OK, the element is configured, add it to the global element's catalog
    while(my ($index_type, $index_value) = each(%{ $indices })) {
        $elements->{ $element_type }->{ $index_type }->{ $index_value } = $element_configured;
    }
}



func fetch_related (
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    HashRef                                     $elements!,
    HashRef                                     $elements_relations!
) {

    my $element_type = $element->get_type;

    for my $related_type (keys(%{ $elements_relations->{ $element_type } })) {
        my $what_to_find = 'our_' . PL(decamelize($related_type));
        foreach my $related_element ($element->get_related(related => $what_to_find, fatal => 0)) {
            configure_element(
                $related_element,
                $elements, {
                    'by-name' => ($related_element->qxp(query => '/name',   return_as => 'value'))[0],
                    'by-id'   => ($related_element->qxp(query => '/id',     return_as => 'value'))[0]
                }
            );
            fetch_related(
                $related_element,
                $elements,
                $elements_relations->{ $element_type }
            );
        }
    }

}



