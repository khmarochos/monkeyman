#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'vocabulary.t',
    app_description     => 'MonkeyMan::CloudStack::API::Vocabulary testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => {
        't|type=s'          => 'type',
        'i|id=s'            => 'id'
    }
);

use Test::More;

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

my $parameters      = $monkeyman->get_parameters;
my $element_type    = defined($parameters->get_type)?
                              $parameters->get_type :
                              'Domain';

my @elements = $api->perform_action(
    type        => $element_type,
    action      => 'list',
    parameters  => { all => 'true' },
    requested   => [ { element => 'element' } ]
);

plan(tests => scalar(@elements));

foreach my $element (@elements) {
    my $path = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_id => $element->get_id },
        requested   => [ { path => 'value' } ]
    );
    $logger->debugf("The path to the %s %s is %s", $element->get_id, $api->translate_type(type => $element->get_type), $path);
    ok(defined($path));
}


