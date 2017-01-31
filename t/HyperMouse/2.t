#!/usr/bin/env perl

use strict;
use warnings;

use HyperMouse;

use Test::More (tests => 3);
use TryCatch;



my $hypermouse  = HyperMouse->new;

my $ok;

try {
    $ok = $hypermouse->_get_db_schema->resultset("Person")->authenticate(
        email       => 'v.melnik@tucha.ua',
        password    => '12345678'
    );
}
ok($ok);

try {
    $ok = $hypermouse->_get_db_schema->resultset("Person")->authenticate(
        email       => 'v.melnik@tucha.ua',
        password    => '87654321'
    );
} catch(HyperMouse::Schema::ResultSet::Person::Exception::PasswordIncorrect $e) {
    ok($e);
} catch {
    ok(0);
}
ok($ok);

