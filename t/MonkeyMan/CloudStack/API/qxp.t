#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'qxp.t',
    app_description     => 'MonkeyMan::CloudStack::API::qxp testing script',
    app_version         => $MonkeyMan::VERSION,
    parameters_to_get   => {
        't|type=s'          => 'type'
    }
);

use Test::More;
use XML::LibXML;
use Array::Utils qw(array_diff);

my $type            = defined($monkeyman->get_parameters->get_type) ?
                        $monkeyman->get_parameters->get_type :
                        'VirtualMachine';
my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

my $biglist         = $api->run_command(
    command => $api->get_vocabulary($type)->compose_request(
        action      => 'list',
        parameters  => { all => 1 }
    )->get_command
);

$logger->tracef("Have got %s as the list of all elements", $biglist);

my @ids_global;
my @ids_local;



$logger->debug("Getting IDs as values");

@ids_local = ();

foreach my $id ($api->qxp(
    dom         => $biglist,
    query       =>  '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(actions list response response_node)]) .
                    '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(entity_node)]) .
                    '/id',
    return_as   => 'value'
)) {
    $logger->tracef("Have got ID as a value, it's %s", $id);
    push(@ids_global, $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



$logger->debug("Getting elements as DOMs");

@ids_local = ();

foreach my $dom ($api->qxp(
    dom         => $biglist,
    query       =>  '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(actions list response response_node)]) .
                    '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(entity_node)]),
    return_as   => 'dom'
)) {
    my $id = $dom->findvalue('/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(entity_node)]) . '/id');
    $logger->tracef("Have got %s as a DOM, its ID is %s", $dom, $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



$logger->debug("Getting elements");

@ids_local = ();

foreach my $vm ($api->qxp(
    dom         => $biglist,
    query       =>  '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(actions list response response_node)]) .
                    '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(entity_node)]),
    return_as   => 'element'
)) {
    my $id = $vm->get_id;
    $logger->tracef("Have got %s as %s, it ID is %s", $vm, $vm->get_type(noun => 1, a => 1), $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



$logger->debug("Getting elements' IDs");

@ids_local = ();

foreach my $id ($api->qxp(
    dom         => $biglist,
    query       =>  '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(actions list response response_node)]) .
                    '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(entity_node)]),
    return_as   => 'id'
)) {
    $logger->tracef("Have got ID as ID, it's %s", $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



done_testing;
