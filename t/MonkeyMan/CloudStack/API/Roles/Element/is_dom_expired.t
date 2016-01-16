#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib("$RealBin/../../../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

use Test::More (tests => 11);
use Method::Signatures;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'qxp.t',
    app_description     => 'MonkeyMan::CloudStack::API::Roles::Element::is_dom_expired() testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => {
        't|type=s'          => 'type',
        'i|id=s'            => 'id'
    }
);

my $logger      = $monkeyman->get_logger;
my $cloudstack  = $monkeyman->get_cloudstack;
my $api         = $cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;
my $type        = defined($parameters->get_type) ?
                    $parameters->get_type :
                    'Domain';
my $id          = defined($parameters->get_id) ?
                    $parameters->get_id :
                    '6cd7f13c-e1c7-437d-95f9-e98e55eb200d';

my $d = ($api->get_elements(
    type        => $type,
    criterions  => { id  => $id }
))[0];

my $wait = 3; sleep($wait);

my $dom_updated = $d->get_dom_updated;
my $now = $d->get_time_current_rough;
$logger->debugf(
    "The %s domain is loaded, the DOM is updated at %s, it's %s now",
        $d,
        $dom_updated,
        $now
);

ok( $d->is_dom_expired('always') );
ok(!$d->is_dom_expired('never') );
ok(!$d->is_dom_expired($now - ($wait + 1)) );
ok( $d->is_dom_expired($now - ($wait + 0)) );
ok( $d->is_dom_expired($now - ($wait - 1)) );
ok( $d->is_dom_expired('+' . ($wait - 1)) );
ok( $d->is_dom_expired('+' . ($wait + 0)) );
ok(!$d->is_dom_expired('+' . ($wait + 1)) );
ok( $d->is_dom_expired('-' . ($wait - 1)) );
ok( $d->is_dom_expired('-' . ($wait + 0)) );
ok(!$d->is_dom_expired('-' . ($wait + 1)) );



