#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code        => undef,
    app_name        => 'vocabulary.t',
    app_description => 'MonkeyMan::CloudStack::API::Vocabulary testing script',
    app_version     => MM_VERSION
);

use Test::More;

my $logger                  = $monkeyman->get_logger;
my $cloudstack              = $monkeyman->get_cloudstack;
my $api                     = $cloudstack->get_api;

my $element_type            = 'Domain';
my $element_related_type    = 'VirtualMachine';

my @elements = $api->perform_action(
    type        => $element_type,
    action      => 'list',
    parameters  => { all => 'true' },
    requested   => { element => 'element' }
);

plan(tests => scalar(@elements) * 4);

foreach my $element (@elements) {

    $logger->debugf("Performing a singular request, requesting the ID of the %s %s", $element->get_id, $element->get_type(noun => 1));
    my $id = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_id => $element->get_id },
        requested   => { id => 'value' }
    );
    ok($id eq $element->get_id);

    $logger->debugf("Performing a singular request, requesting the path to the %s %s", $element->get_id, $element->get_type(noun => 1));
    my $path = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_id => $element->get_id },
        requested   => { path => 'value' }
    );
    ok(defined($path));

    $logger->debugf("Performing a plural request, requesting the ID of and the path to the %s whose path is %s", $element->get_type(noun => 1), $path);
    my @values = $api->perform_action(
        type        => $element_type,
        action      => 'list',
        parameters  => { filter_by_path_all => $path },
        requested   => [ { path => 'value' }, { id => 'value' } ]
    );
    ok($path eq $values[0] && $id eq $values[1]);

    $logger->debugf("Getting a list of the %s related to the %s %s", $api->translate_type(type => $element_related_type, noun => 1, plural => 1), $id, $element->get_type(noun => 1));
    my @related = $element->get_related(related => 'our_virtual_machines');

    ok(1);

} 



