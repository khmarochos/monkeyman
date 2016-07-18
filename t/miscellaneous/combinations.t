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
    parameterA => [ qw(0 1 2 3 4 5 6 7 8 9) ],
    parameterB => [ qw(0 1 2 3 4 5 6 7 8 9) ],
    parameterC => [ qw(0 1 2 3 4 5 6 7 8 9) ],
    parameterD => [ qw(0 1 2 3 4 5 6 7 8 9) ]
};
my @parameters_output;
my @parameters_names = sort(keys(%{ $parameters_input }));
generate(
    parameters_input    => $parameters_input,
    parameters_names    => \@parameters_names,
    parameters_output   => \@parameters_output
);
printf("Combinations generated: %s\n%s", scalar(@parameters_output), Dumper(\@parameters_output));
