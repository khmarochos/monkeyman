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
        parameters_to_get   => { 'h|zaloopa' => 'zaloopa' }
    );
    fail('h|zaloopa');
} catch($e) {
    pass('h|zaloopa: ' . $e);
}

MonkeyMan->_clear_instance;

try {
    $monkeyman = MonkeyMan->new(
        app_code            => undef,
        app_name            => 'BUILD.t',
        app_description     => 'MonkeyMan::Parameters::BUILD testing script',
        app_version         => MM_VERSION,
        parameters_to_get   => { 'z|help' => 'zaloopa' }
    );
    fail('z|help');
} catch($e) {
    pass('z|help: ' . $e);
}

MonkeyMan->_clear_instance;

try {
    $monkeyman = MonkeyMan->new(
        app_code            => undef,
        app_name            => 'BUILD.t',
        app_description     => 'MonkeyMan::Parameters::BUILD testing script',
        app_version         => MM_VERSION,
        parameters_to_get   => { 'z|zaloopa' => 'mm_show_help' }
    );
    fail('mm_show_help');
} catch($e) {
    pass('mm_show_help: ' . $e);
}



done_testing;
