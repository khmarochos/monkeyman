#!/usr/bin/env perl



package Zaloopa;

use MooseX::Singleton;

1;



package main;

use strict;
use warnings;

use Zaloopa;
use Test::More;
use TryCatch;

Zaloopa->instance;

try {
    Zaloopa->initialize;
} catch {
    ok(1);
}

ok(1);

done_testing;
