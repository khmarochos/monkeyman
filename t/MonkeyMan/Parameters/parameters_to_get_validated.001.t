#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman;

use Test::More tests => 2;
use TryCatch;



# parameters_to_get_validated shall override the settings given as parameters_to_get

$monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'parameters_to_get_validated.t',
    app_description     => 'MonkeyMan::Parameters::parameters_to_get_validated testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => { 'w|whatever' => 'whatever_deprecated' },
    parameters_to_get_validated => <<__YAML__
---
w|whatever:
  whatever:
__YAML__
);

try {
    $monkeyman->get_parameters->get_whatever;
    pass('whatever');
} catch($e) {
    fail('whatever:' . $e);
}

try {
    $monkeyman->get_parameters->get_whatever_deprecated;
    fail('whatever_deprecated');
} catch($e) {
    pass('whatever_deprecated: ' . $e);
}



done_testing;
