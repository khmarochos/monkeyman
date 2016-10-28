#!/usr/bin/env perl

use strict;
use Method::Signatures;
use Data::Dumper;

func generate(
    HashRef         :$parameters_input!,
    ArrayRef[Str]   :$parameters_names!,
    ArrayRef        :$parameters_output!,
    HashRef         :$state = {},
    Int             :$depth = 0
) {
    my $current_parameter_name = $parameters_names->[$depth];
    foreach my $current_parameter_value (@{ $parameters_input->{$current_parameter_name} }) {
        $state->{$current_parameter_name} = $current_parameter_value;
        if($depth < @{ $parameters_names } - 1) {
            generate(
                parameters_input    => $parameters_input,
                parameters_names    => $parameters_names,
                parameters_output   => $parameters_output,
                state               => $state,
                depth               => $depth + 1
            );
        } else {
            push(@{ $parameters_output }, { %{ $state } });
        }
    }
}

my $parameters_input = {
    q1 => [ qw(G Em) ],
    q2 => [ qw(Em C Bm Am) ],
    q3 => [ qw(C G) ],
    q4 => [ qw(D Am Bm) ]
};
my @parameters_output;
my @parameters_names = sort(keys(%{ $parameters_input }));
generate(
    parameters_input    => $parameters_input,
    parameters_names    => \@parameters_names,
    parameters_output   => \@parameters_output
);
printf("Combinations generated: %s\n", scalar(@parameters_output));
foreach my $combo (@parameters_output) {
    printf("%s\n", join("\t", map({ $combo->{$_}; } sort(keys(%{ $combo })))));
}
