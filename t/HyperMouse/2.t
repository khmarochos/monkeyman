#!/usr/bin/env perl

use strict;
use warnings;

use HyperMouse;
use HyperMouse::Element::Person;

use Test::More (tests => 1);



my $hypermouse  = HyperMouse->new;
my $logger      = $hypermouse->_get_logger;
my $person      = HyperMouse::Element::Person->new(hypermouse => $hypermouse, db_id => 1);
ok($person->authenticate(12345678));
