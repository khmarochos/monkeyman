package Sort::Conditional;

use strict;
use warnings;

use Data::Dumper;
use feature qw(say);

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA        = qw(Exporter);
@EXPORT     = qw();
@EXPORT_OK  = qw(sort_conditional);



sub sort_conditional {

    my $input           = shift;

    my @keys            = keys(%{ $input });
    my $result          = {
        map(
            {
                my @before = ref($input->{ $_ }->{'before'}) eq 'ARRAY' ? @{ $input->{ $_ }->{'before'} } : ();
                my @after  = ref($input->{ $_ }->{'after'})  eq 'ARRAY' ? @{ $input->{ $_ }->{'after'}  } : ();
                (
                    $_, {
                        before  => \@before,
                        after   => \@after,
                        score   => undef
                    }
                )
            } (@keys)
        )
    };

    my $c = 0;
    my $u = 0;
    while(my @keys_unplaced = grep({ !defined($result->{ $_ }->{'score'}) } @keys)) {
        foreach my $element_key (@keys_unplaced) {
            my($score_lower, $score_upper) = _get_limits($result, $element_key);
            my $score_new;
            if($c++ == 0) {
                $score_new = 0;
            } elsif(defined($score_lower) && defined($score_upper)) {
                $score_new = ($score_lower + $score_upper) / 2;
            } elsif(defined($score_lower)) {
                $score_new =  $score_lower + scalar(@keys) - 1;
            } elsif(defined($score_upper)) {
                $score_new =  $score_upper - scalar(@keys) + 1;
            }
            if($u != @keys_unplaced) {
                $result->{ $element_key }->{'score'} = $score_new;
            } else {
                $result->{ $element_key }->{'score'} = 0;
                last;
            }
        }
        $u = @keys_unplaced;
    }

    return(
        sort(
            {
                my $cmp_result_score = $result->{ $a }->{'score'} <=> $result->{ $b }->{'score'};
                my $cmp_result_order = _compare($result, $a, $b);
                die("The sorting result doesn't match all the conditions, they seem to be self-contradictory")
                    if($cmp_result_order && $cmp_result_order != $cmp_result_score);
                return($cmp_result_score);
            } @keys
        )
    );

}



sub _get_limits {

    my($result, $key_a) = @_;

    my $score_lower;
    my $score_upper;

    foreach my $key_b (keys(%{ $result })) {
        if(defined(my $score_b = $result->{ $key_b }->{'score'})) {
            my $compared = _compare($result, $key_a, $key_b);
            unless(defined($compared)) {
                die("The $key_a and $key_b elements' conditions are mutually contradictory");
            } elsif($compared > 0) {
                $score_lower = (!defined($score_lower) || $score_lower < $score_b) ? $score_b : $score_lower;
            } elsif($compared < 0) {
                $score_upper = (!defined($score_upper) || $score_upper > $score_b) ? $score_b : $score_upper;
            }
        }
    }

    return($score_lower, $score_upper);

}



sub _listed {

    my($ref, $key) = @_;

    die
        unless(ref($ref) eq 'ARRAY');

    foreach(@{ $ref }) {
        return(1)
            if($_ eq $key);
    }

    return(0);

}



sub _compare {

    my($result, $key_a, $key_b) = @_;

    my $cmp_result = 0;

    # Should A be placed before B due to A's requirements?
    $cmp_result = ($cmp_result == 1) ? return(undef) : -1
        if(_listed($result->{ $key_a }->{'before'}, $key_b));

    # Should A be placed after B due to A's requirements?
    $cmp_result = ($cmp_result == -1) ? return(undef) : 1
        if(_listed($result->{ $key_a }->{'after'}, $key_b));

    # Should A be placed after B due to B's requirements?
    $cmp_result = ($cmp_result == -1) ? return(undef) : 1
        if(_listed($result->{ $key_b }->{'before'}, $key_a));

    # Should A be placed before B due to B's requirements?
    $cmp_result = ($cmp_result == 1) ? return(undef) : -1
        if(_listed($result->{ $key_b }->{'after'}, $key_a));

    #say("$key_a (before: [@{ $result->{ $key_a }->{'before'} }], [after: [@{ $result->{ $key_a }->{'after'} }]) <=> $key_b (before: [@{ $result->{ $key_b }->{'before'} }], [after: [@{ $result->{ $key_b }->{'after'} }]) == $cmp_result");

    return($cmp_result);

}



1;
