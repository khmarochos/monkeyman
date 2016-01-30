#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'vocabulary.t',
    app_description     => 'MonkeyMan::CloudStack::API::Roles::Element::*vocabulary* testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => {
        't|type=s'          => 'type',
        'i|id=s'            => 'id'
    }
);

use Test::More;

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

my $parameters      = $monkeyman->get_parameters;
my $element_type    = defined($parameters->get_type)?
                              $parameters->get_type :
                              'Domain';
my $element_id      = defined($parameters->get_id)?
                              $parameters->get_id :
                              '6cd7f13c-e1c7-437d-95f9-e98e55eb200d';

my @elements = $api->get_elements(
    type        =>         $element_type,
    criterions  => { listall => 'true' }
#    criterions  => { id => $element_id }
);

plan(tests => scalar(@elements));

foreach my $element (@elements) {
    ok($element->vocabulary_lookup(word => 'name', fatal => 1));
    print(
        $element->compose_command(
            action      => 'list',
            parameters  => { all => 1 }
        ) . "\n"
    );
}

