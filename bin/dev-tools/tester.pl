#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use FindBin qw($Bin);
use lib("$Bin/../../lib");
use lib("$Bin/../../t");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Utils qw(mm_load_package);
use MonkeyMan::CloudStack::API::Element::Domain;

use Method::Signatures;
use TryCatch;



MonkeyMan->new(
    app_name            => 'tester',
    app_description     => 'The utility to run tests',
    app_version         => 'v2.1.0-dev_melnik13_v3',
    app_usage_help      => \&tester_usage,
    app_code            => \&tester_app,
    parameters_to_get   => {
        't|test=s@'         => 'tests',
        'o|options=s%'      => 'options'
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

func tester_app(MonkeyMan $monkeyman!) {

    my $logger = $monkeyman->get_logger;
    my $options = $monkeyman->get_parameters->has_options ?
        $monkeyman->get_parameters->get_options :
        {};
    foreach my $test (@{ $monkeyman->get_parameters->get_tests }) {
        $logger->infof(
            "Performing the %s test with the following set of options: %s" ,
            $test,
            $monkeyman->get_parameters->get_options
        );
        try {
            no strict qw(refs);
            my $package     = 'Tests::' . $test;
            my $function    = $package . '::test';
            mm_load_package($package);
            $function->(monkeyman => $monkeyman, %{ $options });
        } catch($e) {
            $logger->warnf("The %s test failed: %s", $test, $e);
        }
    }

}

