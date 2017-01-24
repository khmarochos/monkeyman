#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

use Test::More (tests => 5);



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_dom.t',
    app_description     => 'MonkeyMan::CloudStack::Cache testing script',
    app_version         => $MonkeyMan::VERSION
);

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;
my $cache           = $api->get_cache;



$cache->save_object('test', 'zaloopa', time);
ok(!$cache->restore_object('test'));
ok( $cache->restore_object('test', time + 5));

$cache->save_object('test', 'zaloopa', '+5');
ok( $cache->restore_object('test'));
sleep 3;
ok( $cache->restore_object('test'));
sleep 3;
ok(!$cache->restore_object('test'));
