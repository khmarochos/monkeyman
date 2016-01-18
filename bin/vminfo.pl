#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin qw($Bin);
use lib("$Bin/../lib");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Constants qw(:version);
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::API::Element::VirtualMachine;
my %magic_words =
 %::MonkeyMan::CloudStack::API::Element::VirtualMachine::_magic_words;

use Method::Signatures;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'vminfo',
    app_description     => 'The utility to get information about a virtual machine',
    app_version         => MM_VERSION,
    app_usage_help      => \&vminfo_usage,
    parameters_to_get   => {
        'o|cond|conditions=s%{,}'   => 'conditions',
        'x|xpath|xpaths=s@'         => 'xpaths',
        's|short+'                  => 'short'
    }
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;



my @xpaths_to_apply;

if(defined($parameters->get_conditions)) {
    my %conditions = %{ $parameters->get_conditions };
    foreach my $condition (keys(%conditions)) {

        my $xpath_to_apply;
        my $xpath_base = sprintf("/%s",
            $magic_words{'list_tag_entity'}
        );

        if($condition =~ /^has_id/) {
            $xpath_to_apply = sprintf("%s[id = '%s']",
                $xpath_base,
                $conditions{$condition}
            );
        } elsif($condition =~ /^has_ipaddress$/i) {
            $xpath_to_apply = sprintf("%s[nic/ipaddress = '%s']",
                $xpath_base,
                $conditions{$condition}
            );
        } elsif($condition =~ /^has_domain$/i) {
            $xpath_to_apply = sprintf("%s[domain = '%s']",
                $xpath_base,
                $conditions{$condition}
            );
        } else {
            MonkeyMan::Exception->throwf("The %s condition is invalid", $condition);
        }

        push(@xpaths_to_apply, $xpath_to_apply);
        $logger->debugf("Added the following XPath query: %s", $xpath_to_apply);

    }
}

foreach my $vm ($api->get_elements(
    type        => 'VirtualMachine',
    criterions  => { listall => 1 },
    xpaths      => [ (@xpaths_to_apply) ]
)) {
    $logger->debugf("Have found the %s %s", $vm, $vm->get_type(noun => 1));

    my @doms = $vm->get_dom;

    if(defined($parameters->get_xpaths)) {
        foreach my $xpath (@{ $parameters->get_xpaths }) {
            foreach my $dom (@doms) {
                @doms = $api->qxp(
                    query       => $xpath,
                    dom         => $dom,
                    return_as   => 'dom'
                );
            }
        }
    }
    foreach (@doms) {
        if(defined($parameters->get_short) && $parameters->get_short > 1) {
            print($_->findvalue('*'));
        } elsif(defined($parameters->get_short) && $parameters->get_short > 0) {
            print($_->toString(0));
        } else {
            print($_->toString(1));
        }
    }

}



func vminfo_usage {

    return(<<__END_OF_USAGE_HELP__
This application recognizes the following parameters:

    -o <condition>, --condition <condition>
        [mul]       Look up for virtual machines by certain conditions
    -x <query>, --xpath <query>
        [opt] [mul] Apply some XPath-queries and show their result
    -s, --short
        [opt] [mul] Get the result in a short form
__END_OF_USAGE_HELP__
    );

}
