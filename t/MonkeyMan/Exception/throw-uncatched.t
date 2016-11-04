#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Constants qw(:version);
use MonkeyMan::Utils qw(mm_sprintf);
use MonkeyMan::Exception qw(Test);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'throw-uncatched.t',
    app_description     => 'MonkeyMan::Exception::throw() testing script',
    app_version         => MM_VERSION
);

main::Exception::Test->throw('Zaloopa');
