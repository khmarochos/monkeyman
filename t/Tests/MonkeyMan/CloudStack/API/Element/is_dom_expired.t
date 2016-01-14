package Tests::MonkeyMan::CloudStack::API::Element::is_dom_expired;

# Use pragmas
use strict;
use warnings;

use Test::More (tests => 11);
use Method::Signatures;



func test(MonkeyMan :$monkeyman!, Str :$type!, Str :$id!) {

    my $logger      = $monkeyman->get_logger;

    my $d = ($monkeyman->get_cloudstack->get_api->get_elements(
        type        => $type,
        criterions  => { id  => $id }
    ))[0];

    my $wait = 3; sleep($wait);

    my $dom_updated = $d->get_dom_updated;
    my $now = ${$d->get_time_current}[0];
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
    ok(!$d->is_dom_expired('+' . ($wait + 10)) );
    ok( $d->is_dom_expired('-' . ($wait - 1)) );
    ok( $d->is_dom_expired('-' . ($wait + 0)) );
    ok(!$d->is_dom_expired('-' . ($wait + 10)) );
}



1;

