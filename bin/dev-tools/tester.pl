#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use FindBin qw($Bin);
use lib("$Bin/../lib");
use lib("$Bin/../t");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Utils qw(mm_load_package);
use MonkeyMan::CloudStack::API::Element::Domain;

use Method::Signatures;



MonkeyMan->new(
    app_name            => 'tester',
    app_description     => 'The utility to run tests',
    app_version         => 'v2.1.0-dev_melnik13_v3',
    app_usage_help      => \&tester_usage,
    app_code            => \&tester_app,
    parameters_to_get   => {
        't|test=s@'         => 'tests'
    }
);

func tester_usage {
    return(<<__END_OF_USAGE_HELP__
This application recognizes the following parameters:

    -t <test>, --test <test>
        [mul]       Perform the tests listed
__END_OF_USAGE_HELP__
    );

}

func tester_app(MonkeyMan $mm!) {

    no strict qw(refs);

    foreach my $test (@{ $mm->get_parameters->get_tests }) {
        my $package_name = 'Tests::' . $test;
        my $function_name = $package_name . '::test';
        mm_load_package($package_name);
        $function_name->($mm);
    }

}

