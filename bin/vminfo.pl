#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin qw($Bin);
use lib("$Bin/../lib");

# Use my own modules
use MonkeyMan;



MonkeyMan->new(
    app_name            => 'vminfo',
    app_description     => 'The utility to get information about a virtual machine',
    app_version         => '2.0.0-rc.1',
    app_usage_help      => \&vminfo_usage,
    application         => \&vminfo_app,
    parse_parameters    => {
        'o|cond|conditions=s%{,}'   => 'conditions',
        'x|xpath=s@'                => 'xpath',
        's|short+'                  => 'short'
    }
);



sub vminfo_app {

    my $mm = shift;

    $mm->logger->trace("Hello, world!");

    $mm->cloudstack->api->test;

}



sub vminfo_usage {

    return(<<__END_OF_USAGE_HELP__
This application recognizes the following parameters:

    -o <condition>, --condition <condition>
        [mul]       Look up for virtual machines by certain conditions
    -x <query>, --xpath <query>
        [opt] [mul] Apply some XPath-queries
    -s, --short
        [opt] [mul] Get the result in a short form
__END_OF_USAGE_HELP__
    );

}
