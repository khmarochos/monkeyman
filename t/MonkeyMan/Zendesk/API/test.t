#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'test.t',
    app_description     => 'MonkeyMan::Zendesk::API very basic testing script',
    app_version         => MM_VERSION
);

use Test::More;

my $zendesk = $monkeyman->get_zendesk;

ok($zendesk);

done_testing;
