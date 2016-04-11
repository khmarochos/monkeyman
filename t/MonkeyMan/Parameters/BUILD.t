#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman;

use Test::More tests => 3;
use TryCatch;



# one can't just redefine a common parameter

try {
    $monkeyman = MonkeyMan->new(
        app_code            => undef,
        app_name            => 'BUILD.t',
        app_description     => 'MonkeyMan::Parameters::BUILD testing script',
        app_version         => MM_VERSION,
        parameters_to_get   => { 'h|help' => 'zaloopa' }
    );
    fail('h|help');
} catch($e) {
    pass('h|help: ' . $e);
}



