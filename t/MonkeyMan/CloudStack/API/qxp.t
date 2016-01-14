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
    app_version         => 'v2.1.0-dev_melnik13_v3',
    parameters_to_get   => {
        'l|list-command=s'  => 'list_command',
        'q|xpath-query=s'   => 'xpath_query'
    }
);

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;
my $parameters      = $monkeyman->get_parameters;
my $list_command    = defined($parameters->get_list_command) ?
                        $parameters->get_list_command :
                        'listVirtualMachines';
my $xpath_query     = defined($parameters->get_xpath_query) ?
                        $parameters->get_xpath_query :
                        '/listvirtualmachinesresponse' . 
                            '/virtualmachine' .
                            '[nic/ipaddress = "10.13.101.100"]';

my $biglist     = $api->run_command(parameters => {
                    command => $list_command,
                    listall => 'true'
});

$logger->tracef("Have got %s", $biglist);

foreach my $id ($api->qxp(
    query       => $xpath_query . '/id',
    dom         => $biglist,
    return_as   => 'value'
)) {
    ok($logger->tracef("Have found %s", $id));
}

foreach my $vm ($api->qxp(
    query       => $xpath_query,
    dom         => $biglist,
    return_as   => 'element[VirtualMachine]'
)) {
    ok($logger->tracef("Have found %s", $vm->get_id));
}

done_testing;



1;
