#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

use Test::More;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_dom.t',
    app_description     => 'MonkeyMan::CloudStack::API::get_dom() testing script',
    app_version         => $MonkeyMan::VERSION
);

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;


foreach my $account ($api->get_elements(
    type        => 'Account',
    return_as   => 'element',
    criterions  => { listall => 1 }
)) {
    ok($account->get_id eq $account->get_dom->findvalue('/account/id'));
}



done_testing;
