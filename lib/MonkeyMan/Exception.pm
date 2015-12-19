package MonkeyMan::Exception;


use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

extends 'Throwable::Error';

use MonkeyMan::Utils;



foreach my $subclass (qw(
    Initialization
    Configuration
    Configuration::Missing
    CloudStack::API
    CloudStack::API::Command
)) {
    subclass_create(__PACKAGE__ . '::' . $subclass)
}

sub subclass_create {
    my $subclass_fullname   = shift;
    my $subclass_parent     = ($subclass_fullname =~ s/::((?!::).)+$//r);
    unless($subclass_parent->DOES(__PACKAGE__)) {
        subclass_create($subclass_parent);
    }
    Moose::Meta::Class->create(
        $subclass_fullname  => (superclasses => [$subclass_parent])
    );
}



has 'timestamp' => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    builder => '_build_timestamp'
);

has 'stack_trace_args' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_stack_trace_args'
);



around 'throw' => sub {

    my $method  = shift;
    my $class   = shift;

    # Let's look what have we got
    if(scalar(@_) == 0) {

        $class->$method;

    } elsif(scalar(@_) == 1) {

        if(find_exceptions($_)) {

            # If we already have a MonkeyMan::Exception-based object, just rethrow it
            $_[0]->throw;

        } else {

            # If we have only one parameter and it's not a MonkeyMan::Exception-based object, let's consider it's a message
            $class->$method(message => "$_[0]");

        }

    } else {

        # Okay, so let's consider it's a set of parameters for Throwable::Error->throw() and pass them all to the method

        $class->$method(@_);

    }

    confess("Something really odd has happened: the flow shouldn't has come to this point!");

};



sub throwf {

    my $self    = shift;
    my $message = shift;
    my @values;
    my @exceptions;

    foreach (@_) {
        if(find_exceptions($_)) {
            push(@exceptions, $_);
            $_ = $_->message;
        }
        push(@values, $_)
    }

    my $new_message = mm_sprintf($message, @values);

    $self->throw(
        message => $new_message
    );

}



sub _build_timestamp {

    return(time);

}



sub _build_stack_trace_args {

    my $talktalk = 0;

    return(
        [
            'indent', 1,
            'no_args', 1, # y u no lemme huv sum urgs dolan pls
#
#           The following piece of code makes the builder of the stack trace
#           skipping some ugly frames of the caller's stack, it doesn't work
#           properly at the moment, but I'm going to return here when I have
#           a bit more of spare time (FIXME)
#
#            'frame_filter', sub {
#                return 1
#                    if($talktalk >= 3);
#                $talktalk++
#                    if($talktalk >1);
#                $talktalk++
#                    if(index($_[0]->{'caller'}[0], 'MonkeyMan::Exception') == 0);
#            }
        ]
    );

}



sub find_exceptions {
    my @result;
    foreach (@_) {
        push(@result, $_)
            if(defined(blessed($_[0])) && (
                $_[0]->DOES('MonkeyMan::Exception') ||
                $_[0]->DOES('Moose::Exception')
            ));
    }
    return(@result);
}



__PACKAGE__->meta->make_immutable;

1;
