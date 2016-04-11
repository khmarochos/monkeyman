#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman;

use Test::More tests => 1;
use Class::Unload;
use TryCatch;



try {
    @ARGV = qw(-w -z);
    $monkeyman = MonkeyMan->new(
        app_code            => undef,
        app_name            => 'parameters_to_get_validated.003.t',
        app_description     => 'MonkeyMan::Parameters::parameters_to_get_validated testing script',
        app_version         => MM_VERSION,
        parameters_to_get_validated => <<__YAML__
---
w|whatever:
  whatever:
    requires_each:
      - zaloopa
z|zaloopa:
  zaloopa:
    requires_each:
      - whatever
__YAML__
    );
    pass('whatever & zaloopa');
} catch($e) {
    fail('whatever & zaloopa: ' . $e);
}



done_testing;
