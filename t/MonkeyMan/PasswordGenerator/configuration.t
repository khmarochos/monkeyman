#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman;

use Test::More tests => 3;



$monkeyman = MonkeyMan->new(
    app_code                => undef,
    app_name                => 'configuration.t',
    app_description         => 'MonkeyMan::PasswordGenerator testing script',
    app_version             => MM_VERSION,
    configuration_append    => <<__END_OF_CONFIGURATION__
<password_generator>
    <Huyarevo>
        length = 4-20
    </Huyarevo>
    <Zaloopa>
        length = 13
    </Zaloopa>
    <Ebashevo>
        length = 42
    </Ebashevo>
</password_generator>
__END_OF_CONFIGURATION__
);

my $l = length($monkeyman->get_password_generator('Huyarevo')->generate()); ok($l >= 4 && $l <= 20);
is(length($monkeyman->get_password_generator('Zaloopa')->generate()), 13);
is(length($monkeyman->get_password_generator('Ebashevo')->generate()), 42);

done_testing;
