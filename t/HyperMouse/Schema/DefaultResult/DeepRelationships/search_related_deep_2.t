#!/usr/bin/env perl

use strict;
use warnings;

use HyperMouse;

use Test::More (tests => 2);



my $hypermouse  = HyperMouse->new;
my $db_schema   = $hypermouse->get_schema;
my $logger      = $hypermouse->get_logger;

my $person_r = $db_schema->resultset('Person')->find(1);

$logger->debugf("The person is %s", $person_r);

my $person_rs = $person_r->search_related_deep(
    resultset_class => 'Person',
    callout         => [ 'Person->-((((@->-Corporation->-Contractor)-&-(@->-Contractor))-[client|provider]>-ProvisioningAgreement)-&-(@->-ProvisioningAgreement))' => { } ]
);

$logger->debugf("The related persons found: %s", scalar($person_rs->all));
foreach my $person_r ($person_rs->all) {
    $logger->debugf("%s (id: %d)", $person_r, $person_r->id);
}


