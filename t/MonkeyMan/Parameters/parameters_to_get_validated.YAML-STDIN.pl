#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

my $monkeyman;


my $yaml; $yaml .= $_ while(<STDIN>);


$monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'parameters_to_get_validated.YAML-STDIN.t',
    app_description     => 'MonkeyMan::Parameters::parameters_to_get_validated testing script',
    app_version         => $MonkeyMan::VERSION,
    parameters_to_get_validated => $yaml
);

exit(0);
