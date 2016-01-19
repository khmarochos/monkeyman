#!/usr/bin/env perl

use strict;
use warnings;

our $_PrimaryZaloopaID      = 'PRIMARY_ZALOOPA';
our $_PrimaryZaloopaValue   = 13;



package _Zaloopator;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Moose;
use MooseX::Handies;
use namespace::autoclean;

has 'zaloopas' => (
    isa     => 'HashRef[Int]',
    is      => 'ro',
    reader  => 'get_zaloopas',
    default => sub {{}},
    handies => [
        {
            name        => 'get_zaloopa',
            default     => $::_PrimaryZaloopaID,
            strict      => 1
        }
    ]
);

__PACKAGE__->meta->make_immutable;



package main;

use Test::More (tests => 3);


my $zaloopator = _Zaloopator->new;
   ${$zaloopator->get_zaloopas->{$_PrimaryZaloopaID}}   =   $::_PrimaryZaloopaValue;
ok(${$zaloopator->get_zaloopas->{$_PrimaryZaloopaID}}   ==  $::_PrimaryZaloopaValue);
ok(  $zaloopator->get_zaloopas->{$_PrimaryZaloopaID}    ==  $zaloopator->get_zaloopa());
ok(  $zaloopator->get_zaloopas->{$_PrimaryZaloopaID}    ==  $zaloopator->get_zaloopa($_PrimaryZaloopaID));

