package Tests::MonkeyMan::CloudStack::API::Element::is_dom_expired;

# Use pragmas
use strict;
use warnings;

use Test::More (tests => 11);



sub test {
    my $mm = shift;
    my $log = $mm->get_logger;
    my $d = ($mm->get_cloudstack->get_api->get_elements(
        type        => 'Domain',
        criterions  => { id  => '6cd7f13c-e1c7-437d-95f9-e98e55eb200d' }
    ))[0];
    my $wait = 3;
    sleep($wait);
    my $dom_updated = $d->get_dom_updated;
    my $now = ${$d->get_time_current}[0];
    $log->debugf(
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
}



1;

