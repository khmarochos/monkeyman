#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

use FindBin qw($Bin);
use lib("$Bin/../lib");

use Moose;
use MooseX::SuperHandlers::T::Fruit;

my $fruit = MooseX::SuperHandlers::T::Fruit->new(
    name        => 'Ololo',
);

printf("Fruit's name is %s!\n", $fruit->name);

warn($fruit->zaloopa);
warn($fruit->zaloopa2);

