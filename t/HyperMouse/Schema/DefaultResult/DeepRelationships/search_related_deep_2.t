#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

use Test::More (tests => 2);



my $monkeyman   = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'search_related_deep_2.t',
    app_description     => '...',
    app_version         => $MonkeyMan::VERSION
);
my $hypermouse  = $monkeyman->get_hypermouse;
my $logger      = $monkeyman->get_logger;
my $db_schema   = $hypermouse->get_schema;

my $person_r = $db_schema->resultset('Person')->find(100);

$logger->debugf("The person is %s", $person_r);

my $person_rs = $person_r->search_related_deep(
    resultset_class => 'Person',
    callout         => [ '@Person-[everything]>-@Person' => { } ]
);

$logger->debugf("The related persons found: %s", scalar($person_rs->all));
foreach my $person_r ($person_rs->all) {
    $logger->debugf("%s (id: %d)", $person_r, $person_r->id);
}


