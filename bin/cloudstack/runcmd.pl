#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin;
use lib("$FindBin::Bin/../../lib");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Constants qw(:version);
use MonkeyMan::CloudStack::API;

# Use some third-party libraries
use Method::Signatures;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'runcmd.pl',
    app_description     => 'The utility runs an API command and shows the result',
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    -p <parameter=value>, --parameters <parameter=value>
        [req] [mul] The API command and its parameters
    -w <seconds>, --wait <seconds>
        [opt]       To wait some seconds for an async job to finish and show
                    its result instead of the job information: if the number is
                    omitted, it will wait for the result as much as it's needed
                    (by default it doesn't wait for anything, it just returns
                    the job information)
    -x ?, --xpath ?
        [opt] [mul] To apply some XPath-queries to the result
    -s,   --short
        [opt] [mul] To get the result in a short form
__END_OF_USAGE_HELP__
    parameters_to_get   => {
        'p|parameters=s%{,}'    => 'parameters',
        'w|wait:0'              => 'wait',
        'x|xpath|xpaths=s@'     => 'xpaths',
        's|short|be-short+'     => 'be_short'
    }
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;



my @doms = (
    $api->run_command(
        parameters  => $parameters->get_parameters,
        wait        => $parameters->get_wait
    )
);

if(defined($parameters->get_xpaths)) {
    foreach my $xpath (@{ $parameters->get_xpaths }) {
        my @doms_new;
        foreach my $dom (@doms) {
            push(@doms_new, $api->qxp(
                query       => $xpath,
                dom         => $dom,
                return_as   => 'dom'
            ));
        }
        @doms = @doms_new;
    }
}

my $be_short = $parameters->get_be_short;

foreach (@doms) {
    if     (defined($be_short) && $be_short > 1) {
        print($_->findvalue('*'));
    } elsif(defined($be_short) && $be_short > 0) {
        print($_->toString(0));
    } else {
        print($_->toString(1));
    }
    print("\n");
}

