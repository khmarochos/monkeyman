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
    requested   => { element => 'element' }
);

plan(tests => scalar(@elements) * 3);

foreach my $element (@elements) {

    $logger->debugf("Performing a singular request, requesting the path to the %s %s", $element->get_id, $element->get_type(noun => 1));
    my $path = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_id => $element->get_id },
        requested   => { path => 'value' }
    );
    ok(defined($path));

    $logger->debugf("Performing a plural request, requesting the path to the %s %s twice", $element->get_id, $element->get_type(noun => 1));
    my @paths = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_id => $element->get_id },
        requested   => [ { path => 'value' }, { path => 'value' } ]
    );
    ok($path eq $paths[0] && $paths[0] eq $paths[1]);

    my $id = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_path_all => $path },
        requested   => { id => 'value' }
    );
    ok($id eq $element->get_id);

    $logger->debugf("Results were: %s, %s, %s, %s", $path, $paths[0], $paths[1], $id);

} 



