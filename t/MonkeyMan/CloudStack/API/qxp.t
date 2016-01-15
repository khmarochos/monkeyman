#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib("$RealBin/../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

use Test::More;
use Array::Utils qw(array_diff);



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'qxp.t',
    app_description     => 'MonkeyMan::CloudStack::API::qxp testing script',
    app_version         => MM_VERSION
);

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

my $biglist     = $api->run_command(parameters => {
                    command => 'listVirtualMachines',
                    listall => 'true'
});

$logger->tracef("Have got %s as the list of all elements", $biglist);

my @ids_global;
my @ids_local;



$logger->debug("Getting values");

@ids_local = ();

foreach my $id ($api->qxp(
    dom         => $biglist,
    query       => '/listvirtualmachinesresponse' . 
                    '/virtualmachine' .
                    '[nic/id]' .
                    '/id',
    return_as   => 'value'
)) {
    $logger->tracef("Have got ID as a value, it's %s", $id);
    push(@ids_global, $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



$logger->debug("Getting DOMs");

@ids_local = ();

foreach my $dom ($api->qxp(
    dom         => $biglist,
    query       => '/listvirtualmachinesresponse' . 
                    '/virtualmachine' .
                    '[nic/id]',
    return_as   => 'dom'
)) {
    my $id = $dom->findvalue('/virtualmachine/id');
    $logger->tracef("Have got %s as a DOM, its ID is %s", $dom, $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



$logger->debug("Getting elements");

@ids_local = ();

foreach my $vm ($api->qxp(
    dom         => $biglist,
    query       => '/listvirtualmachinesresponse' . 
                    '/virtualmachine' .
                    '[nic/id]',
    return_as   => 'element[VirtualMachine]'
)) {
    my $id = $vm->get_id;
    $logger->tracef("Have got %s as %s, it ID is %s", $vm, $vm->get_type(noun => 1, a => 1), $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



$logger->debug("Getting IDs");

@ids_local = ();

foreach my $id ($api->qxp(
    dom         => $biglist,
    query       => '/listvirtualmachinesresponse' . 
                    '/virtualmachine' .
                    '[nic/id]',
    return_as   => 'id[VirtualMachine]'
)) {
    $logger->tracef("Have got ID as ID, it's %s", $id);
    push(@ids_local, $id);
}

ok(!array_diff(@ids_local, @ids_global));



done_testing;



1;
