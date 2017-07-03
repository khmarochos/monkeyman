#!/usr/bin/env perl

use strict;
use warnings;

use HyperMouse;
use MonkeyMan;



my $monkeyman       = MonkeyMan->new(
    app_code                    => undef,
    app_name                    => 'contractors_finder',
    app_description             => 'Finds the unregistered contractors',
    app_version                 => 'v0.0.1',
    app_usage_help              => <<__END_OF_USAGE_HELP__,
This application recognizes the following parameters:

    -u, --update
        [opt]       Update the database
    -e <address>, --email <address>
        [opt] [mul] The email addresses to report to
__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $cloudstack_api  = $cloudstack->get_api;
my $hypermouse      = HyperMouse->new(monkeyman => $monkeyman);
my $db_schema       = $hypermouse->get_schema;



foreach my $domain ($cloudstack_api->perform_action(
    type        => 'Domain',
    action      => 'list',
    parameters  => { 'all'      => 1 },
    requested   => { 'element'  => 'element' },
    best_before => 0
)) {
    $logger->tracef("Found the %s domain", $domain);
}
