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

use Method::Signatures;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'vminfo',
    app_description     => 'The utility to get information about a virtual machine',
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    -c <condition>, --condition <condition>
        [mul]       Look up for virtual machines by certain conditions
    -x <query>, --xpath <query>
        [opt] [mul] Apply some XPath-queries and show their result
    -s, --short
        [opt] [mul] Get the result in a short form (try to add it twice!)
__END_OF_USAGE_HELP__
    parameters_to_get   => {
        'c|cond|condition|conditions=s%{,}' => 'conditions',
        'x|xpath|xpaths=s@'                 => 'xpaths',
        's|short|be-short+'                 => 'be_short'
    }
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;




# First of all, let's prepare the list of XPath-queries that will be aplied
# to the full list of virtual machines. These XPath-queries should select only
# those ones that the user needs.

my @xpaths_to_apply;

if(defined($parameters->get_conditions)) {

    # Adding the '/virtualmachineslist' prefix to queries
    my $xpath_base = '/' . $api->get_vocabulary('VirtualMachine')->
        vocabulary_lookup(words => [ 'entity_node' ]);

    my %conditions = %{ $parameters->get_conditions };
    foreach my $condition (keys(%conditions)) {
        my $xpath_to_apply;
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



# So, if the user asked for "-o has_ipaddress=13.13.13.13 -o has_domain=LAB13",
# the @xpaths_to_apply list shall contain the following elements:
# (
#   "/virtualmachineslist/[nic/ipaddress = '13.13.13.13']",
#   "/virtualmachineslist/[domain = 'LAB13']"
# )

my $be_short    = $parameters->get_be_short;

foreach my $vm ($api->get_elements(
    type        => 'VirtualMachine',
    criterions  => { all => 1 },
    xpaths      => [ (@xpaths_to_apply) ]
)) {
    $logger->debugf("Have found the %s %s", $vm, $vm->get_type(noun => 1));

    my @doms = $vm->get_dom;

    if(defined($parameters->get_xpaths)) {

        # If the user would like to ADD some XPath-queries (for example, they
        # asks for "-x /virtualmachine/id"), let's give them what they need.

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

    # In any case we have at least one XML::LibXML::Document, so let's display
    # the results in the form requested (depends on "-s" parameters quantity).

    foreach (@doms) {
        if     (defined($be_short) && $be_short > 1) {
            printf("%s\n", $_->findvalue('*'));
        } elsif(defined($be_short) && $be_short > 0) {
            print($_->toString(0));
        } else {
            print($_->toString(1));
        }
    }

}


