#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;


my %note_numbers = (
    a  =>  0, bb =>  1, b  =>  2,
    c  =>  3, db =>  4, d  =>  5,
    eb =>  6, e  =>  7, f  =>  8,
    gb =>  9, g  => 10, ab => 11
);

sub freq {
    my $input = shift;
    if($input =~ /^([A-Ga-g][Bb]?)([0-9]+)$/) {
        my $note        = lc($1);
        my $octave      = $2;
        my $note_number = $note_numbers{$note};
#       return undef unless defined $note_number;
           $note_number = $note_number + ($octave * 12);
        my $freq        = 27.5 * (2 ** ($note_number / 12));
        return $freq;
    }
}

foreach my $octave (0..58) {
    foreach my $note qw/a bb b c db d eb e f gb g ab/ {
        print(sprintf("%2s%2d %0.64b %f\n", $note, $octave, freq("$note$octave"), freq("$note$octave")))
    }
}
