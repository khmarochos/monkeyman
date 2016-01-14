#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib("$Bin/../../../../../lib");

use MonkeyMan;

use Test::More;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'qxp.t',
    app_description     => 'MonkeyMan::CloudStack::API::qxp testing script',
    app_version         => 'v2.1.0-dev_melnik13_v3'
);

my $logger      = $monkeyman->get_logger;
my $cloudstack  = $monkeyman->get_cloudstack;
my $api         = $cloudstack->get_api;

my $biglist     = $api->run_command(parameters => {
                    command => 'listVirtualMachines',
                    listall => 'true'
});

$logger->tracef("Have got %s", $biglist);

foreach my $id ($api->qxp(
    query       => '/listvirtualmachinesresponse' .
                    '/virtualmachine/' .
                    '/nic' .
                    '/id',
    dom         => $biglist,
    return_as   => 'value'
)) {
    ok($logger->tracef("Have found %s", $id));
}

done_testing;



1;
