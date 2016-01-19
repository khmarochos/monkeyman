#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version :cloudstack);

use Test::More (tests => 3);



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_cloudstack.t',
    app_description     => 'MonkeyMan::get_cloudstack() testing script',
    app_version         => MM_VERSION
);

ok($monkeyman->_get_cloudstacks->{$monkeyman->get_default_cloudstack_id} == $monkeyman->get_cloudstack);
ok($monkeyman->get_cloudstack == $monkeyman->get_cloudstack);
ok($monkeyman->get_cloudstack == $monkeyman->get_cloudstack($monkeyman->get_default_cloudstack_id));
