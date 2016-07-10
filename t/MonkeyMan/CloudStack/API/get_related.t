#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_related.t',
    app_description     => 'MonkeyMan::CloudStack::API::get_related testing script',
    app_version         => MM_VERSION,
);

use Test::More;
use XML::LibXML;

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

foreach my $domain ($api->get_elements(type => 'Domain')) {

    $logger->debugf(
            "Have got the %s %s (%s)",
        $domain,
        $domain->get_type(noun => 1),
        $domain->qxp(query => 'name', return_as => 'value')
    );
    # 2016/07/06 14:08:37 [D] [main] Have got the [MonkeyMan::CloudStack::API::Element::Domain@0x......./................................] domain (Zaloopa)

    foreach my $virtualmachine ($domain->get_related(related => 'our_virtual_machines')) {

        $logger->debugf(
                "Have got the %s %s (%s)",
            $virtualmachine,
            $virtualmachine->get_type(noun => 1),
            $virtualmachine->qxp(query => 'name', return_as => 'value')
        );
        # 2016/07/06 14:08:37 [D] [main] Have got the [MonkeyMan::CloudStack::API::Element::VirtualMachine@0xdeadbee/badcaffefeeddeafbeefbabedeadface] virualmachinegun :)

        ok($virtualmachine->get_id);

    }

}



done_testing;
