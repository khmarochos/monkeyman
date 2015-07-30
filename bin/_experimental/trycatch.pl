#!/usr/bin/env perl

use FindBin qw($Bin);
use lib("$Bin/../../lib");

package MonkeyMan::Zaloopa;

use strict;
use warnings;
use MonkeyMan::Exception;
use Moose;
use namespace::autoclean;



sub BUILD {
    MonkeyMan::Exception->throw("Pizdets!");
}



__PACKAGE__->meta->make_immutable;

1;



package main;

use strict;
use warnings;
use TryCatch;
use MonkeyMan::Exception;

my $zaloopa;
try {
    $zaloopa = MonkeyMan::Zaloopa->new;
} catch(MonkeyMan::Exception $e) {
    MonkeyMan::Exception->throw($e);
} catch($e) {
    MonkeyMan::Exception->throw($e);
}
print("Zaloopa! $zaloopa\n");
