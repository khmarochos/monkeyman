#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib("$RealBin/../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

use Test::More;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_dom.t',
    app_description     => 'MonkeyMan::CloudStack::API::get_dom() testing script',
    app_version         => MM_VERSION
);

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;


foreach my $vm ($api->get_elements(
    type        => 'VirtualMachine',
    criterions  => {
        listall => 1
    }
)) {
    ok($vm->get_id eq $vm->get_dom->findvalue('/virtualmachine/id'));
}



done_testing;
