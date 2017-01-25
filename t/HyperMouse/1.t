#!/usr/bin/env perl

use strict;
use warnings;

use HyperMouse;

use Test::More (tests => 2);



my $hypermouse = HyperMouse->new;

ok($hypermouse->_get_monkeyman->get_logger == $hypermouse->_get_monkeyman->get_logger);
ok($hypermouse->_get_schema == $hypermouse->_get_schema);

