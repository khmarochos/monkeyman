#!/usr/bin/env perl

use strict;
use warnings;

use HyperMouse;

use Test::More (tests => 3);
use TryCatch;



my $hypermouse  = HyperMouse->new;

my $ok;

try {
    $ok = $hypermouse->get_schema->resultset("Person")->authenticate(
        email       => 'v.melnik@tucha.ua',
        password    => '12345678'
    );
} catch($e) {
    warn($e);
}
ok($ok);

try {
    $ok = $hypermouse->get_schema->resultset("Person")->authenticate(
        email       => 'v.melnik@tucha.ua',
        password    => '87654321'
    );
} catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::PersonPasswordIncorrect $e) {
    ok($e);
} catch($e) {
    ok(0);
}

try {
    $ok = $hypermouse->get_schema->resultset("Person")->authenticate(
        email       => 'zaloopa',
        password    => '12345678'
    );
} catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::PersonEmailNotFound $e) {
    warn($e);
    ok($e);
} catch($e) {
    warn($e);
    ok(0);
}

