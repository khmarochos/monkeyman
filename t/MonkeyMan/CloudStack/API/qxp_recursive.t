#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'qxp_recursive.t',
    app_description     => 'MonkeyMan::CloudStack::API::qxp testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => {
        't|type=s'          => 'type'
    }
);

use Test::More;
use XML::LibXML;

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



$logger->debug("Getting IDs as values");

@ids_local = ();

foreach my $id ($api->qxp(
    dom         => $biglist,
    query       =>  [
                        '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(actions list response response_node)]) .
                        '/' . $api->get_vocabulary($type)->vocabulary_lookup(words => [qw(entity_node)]),
                        '/id'
                    ]
    return_as   => 'value'
)) {
    $logger->tracef("Have got ID as a value, it's %s", $id);
}





done_testing;
