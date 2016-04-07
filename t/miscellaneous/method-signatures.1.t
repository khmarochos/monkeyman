#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;
use Method::Signatures;

die;

my $defval = 'DefVal';

#my $parameters = sprintf(
#    "(Maybe :\$test1 = '%s', Maybe :\$test2 = '%s')",
#    $defval,
#    $defval
#);

func subroutine_t (Maybe :$test1 = $defval, Maybe :$test2 = $defval) {
    ok($test1 eq $defval);
    ok($test2 eq $defval);
}

subroutine_t;
