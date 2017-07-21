package HyperMouse::Schema::ValidityCheck;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

use HyperMouse::Schema::ValidityCheck::Constants qw(:ALL);

use Method::Signatures;
use Switch;
use DateTime;
use DateTime::TimeZone;

our $LocalTZ = DateTime::TimeZone->new(name => 'local');



method _get_validity_check(Int $check!, Str $source_alias!, DateTime $now!) {
    switch($check) {
          case(VC_B_NOT_EXPIRED) {
            return(
                -or => [
                     { "$source_alias.valid_till"    => { '='  => undef                        } },
                     { "$source_alias.valid_till"    => { '>'  => $self->format_datetime($now) } }
                ]
            );
        } case(VC_B_NOT_PREMATURE) {
            return(
                -or => [
                     { "$source_alias.valid_since"   => { '!=' => undef                        } },
                     { "$source_alias.valid_since"   => { '<=' => $self->format_datetime($now) } }
                ]
            );
        } case(VC_B_NOT_REMOVED) {
            return(
                       "$source_alias.removed"       => { '='  => undef                        }
            );
        } case(VC_B_EXPIRED) {
            return(
                       "$source_alias.valid_till"    => { '<=' => $self->format_datetime($now) }
            );
        } case(VC_B_PREMATURE) {
            return(
                -or => [
                     { "$source_alias.valid_since"   => { '='  => undef                        } },
                     { "$source_alias.valid_since"   => { '>'  => $self->format_datetime($now) } }
                ]
            );
        } case(VC_B_REMOVED) {
            return(
                       "$source_alias.removed"       => { '!=' => undef                        }
            );
        } else {
            # TODO: Raise an exception
        }
    }
};

method _get_validity_checks(Int $mask!, Str $source_alias!, DateTime $now!) {
    my @result;
    foreach my $check (0..5) {
        push(@result, $self->_get_validity_check($check, $source_alias, $now))
            if($mask & 1 << $check);
    }
    return(@result);
}

method filter_validated (
    Str         :$source_alias?     = $self->current_source_alias,
    DateTime :   $now?              = DateTime->now(time_zone => $LocalTZ),
    Bool        :$removed?          = 0,
    Bool        :$premature?        = 0,
    Bool        :$expired?          = 0,
    Bool        :$not_removed?      = 1,
    Bool        :$not_premature?    = 1,
    Bool        :$not_expired?      = 1,
    Maybe[Int]  :$mask?,
    Maybe[Ref]  :$checks_failed?
) {

    die
        if(
            ($removed   && $not_removed  ) ||
            ($premature && $not_premature) ||
            ($expired   && $not_expired  )
        );
    # ^^^ FIXME: Raise a proper exception if mutual contradictory flags are given

    $mask =
        (    $removed << VC_B_REMOVED    ) + (    $premature << VC_B_PREMATURE    ) + (    $expired << VC_B_EXPIRED    ) +
        ($not_removed << VC_B_NOT_REMOVED) + ($not_premature << VC_B_NOT_PREMATURE) + ($not_expired << VC_B_NOT_EXPIRED)
       unless(defined($mask));

    my $resultset = $self;
    my @checks_all;
    my @checks_needed;

    if(defined($checks_failed)) {
        foreach my $check (0..5) {
            my @check_sentence = $self->_get_validity_check($check, $source_alias, $now)
                if($mask & 1 << $check);
            if(
                (my $counter_b = ($resultset->all)) >                                           # How many elements was there before the check?
                (my $counter_a = ($resultset = $resultset->search({ @check_sentence }))->all)   # How many elements has gone?
            ) {                # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^         # The resultset has to be updated
                $checks_failed->{ 1 << $check } = $counter_b - $counter_a;
            }
        }
    } else {
        $resultset = $self->search_rs({ -and => [ $self->_get_validity_checks($mask, $source_alias, $now) ] });
    }

    return($resultset);

}



1;
