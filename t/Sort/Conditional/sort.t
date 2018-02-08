#!/usr/bin/env perl

use strict;
use warnings;

use feature qw(say);

use Sort::Conditional qw(sort_conditional);

my $i = {

#   e => { before => [ qw(   ) ], after => [ qw( d ) ] },
#   d => { before => [ qw( e ) ], after => [ qw( c ) ] },
#   c => { before => [ qw( d ) ], after => [ qw( b ) ] },
#   b => { before => [ qw( c ) ], after => [ qw( a ) ] },
#   a => { before => [ qw( b ) ], after => [ qw(   ) ] }

#   e => { before => [ qw( ) ], after => [ qw( a b c d ) ] },
#   d => { before => [ qw( e ) ], after => [ qw( a b c ) ] },
#   c => { before => [ qw( d c ) ], after => [ qw( a b ) ] },
#   b => { before => [ qw( c d e ) ], after => [ qw( a ) ] },
#   a => { before => [ qw( b c d e ) ], after => [ qw( ) ] }

    e => { },
    d => { },
    c => { },
    b => { },
    a => { }
};

foreach(sort_conditional($i)) {
    say($_);
}
