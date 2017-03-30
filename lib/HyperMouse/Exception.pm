package HyperMouse::Exception;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

extends 'MonkeyMan::Exception';

use Method::Signatures;
use Switch;



func import (@exceptions) {

    foreach(@exceptions) {
        if($_ =~ /^::/) {
            __PACKAGE__->_register_exception_class($_);
        } else {
            __PACKAGE__->_register_exception_class((caller)[0] . '::Exception::' . $_);
        }
    }

}



func _explaination_validity(
    Maybe[Str]  $check!,
    Maybe[Int]  $number!
) {
    return
        unless(
            defined($check) &&
            defined($number)
        );
    return(sprintf(
        '%d %s %s',
        $number,
        $number > 1 ? 'records are' : 'record is',
        {
            (1 << 0) => 'already expired',
            (1 << 1) => 'still premature',
            (1 << 2) => 'removed',
            (1 << 3) => 'still not expired, as it was requested',
            (1 << 4) => 'already not premature, as it was requested',
            (1 << 5) => 'not removed, as it was requested'
        }->{ $check }
    ));
}



method throwf_validity(
    HashRef $checks_failed!,
    Str     $message!,
            @values?
) {
    my @explaination;
    foreach my $reason (keys(%{ $checks_failed })) {
        if(my $c = $checks_failed->{ $reason } > 0) {
            push(@explaination, _explaination_validity($reason, $c));
        }
    }
    push(@explaination, 'no records found')
        unless(@explaination);
    $self->throwf($message . ' (hint: ' . join(', ', @explaination) . ')', @values);
}



__PACKAGE__->meta->make_immutable;

1;
