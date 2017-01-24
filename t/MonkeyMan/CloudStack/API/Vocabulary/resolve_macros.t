#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'resolve_macros.t',
    app_description     => 'MonkeyMan::CloudStack::API::Vocabulary::resolve_macros testing script',
    app_version         => $MonkeyMan::VERSION,
    parameters_to_get   => { 't|type=s' => 'type' }
);

use Test::More;

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;
my $parameters      = $monkeyman->get_parameters;
my $element_type    = defined($parameters->get_type)?
                              $parameters->get_type :
                              'Domain';

my $vocabulary = $api->get_vocabulary($element_type);
my $our_response_node = $vocabulary->vocabulary_lookup(
    words   => [ qw(actions list response response_node) ],
    fatal   => 1
);

ok($vocabulary->resolve_macros(
    source  => '/<%OUR_RESPONSE_NODE%>/<%OUR_ENTITY_NODE%>',
    macros  => { OUR_RESPONSE_NODE => $our_response_node }
) eq sprintf('/%s/%s', $our_response_node, $api->translate_type(type => $element_type)));

done_testing;
