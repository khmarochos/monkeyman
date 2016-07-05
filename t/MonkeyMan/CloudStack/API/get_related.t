#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_related.t',
    app_description     => 'MonkeyMan::CloudStack::API::get_related testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => {
        't|type=s'          => 'type'
    }
);

use Test::More;
use XML::LibXML;

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

foreach my $domain ($api->get_elements(type => 'Domain')) {
    $logger->debugf("Have got the %s domain", $domain);
}



done_testing;
