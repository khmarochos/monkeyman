package MonkeyMan::Exception;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Utils;

# Use 3rd party libraries
use Scalar::Util qw(blessed);
use Carp;

# Use Moose :)
use Moose;
use namespace::autoclean;

extends 'Throwable::Error';



# Initializing exception subclasses

foreach my $subclass (qw(
    Initialization
    Initialization::Logger
    Initialization::CloudStack
    MethodInvocationCheck
    MethodInvocationCheck::CheckNotImplemented
    MethodInvocationCheck::ParameterUndefined
    MethodInvocationCheck::ParameterInvalid
    MethodInvocationCheck::TargetInvalid
)) {
    my $subclass_fullname   = __PACKAGE__ . '::' . $subclass;
    my $subclass_parent     = ($subclass_fullname =~ s/::((?!::).)+$//r);

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

    my $orig = shift;
    my $self = shift;

    # Let's look what have we got
    if(defined(blessed($_[0])) && $_[0]->DOES('MonkeyMan::Exception')) {

        # If we already have a MonkeyMan::Exception-based object, just rethrow it
        $_[0]->throw;

    } elsif(scalar(@_) == 1) {

        # If we have only one parameter and it's not a MonkeyMan::Exception-based object, let's consider it's a message
        $self->$orig(message => $_[0])

    } else {

        # Okay, so let's consider it's a set of parameters for Throwable::Error->throw() and pass them all to the original method
        $self->$orig(@_);

    }

    confess("Something really odd has happened: the flow shouldn't has come to this point!");

};



sub throw_f {

    my $self = shift;

    $self->throw(mm_sprintf(@_));

}



sub _build_timestamp {

    return(time);

}



sub _build_stack_trace_args {

    my $talktalk = 0;

    return(
        [
            'indent', 1,
            'frame_filter', sub {
                $talktalk++
                    if(index($_[0]->{'caller'}[0], 'MonkeyMan::Exception') == 0);
                return 1
                    if($talktalk >= 2);
            }
        ]
    );

}



__PACKAGE__->meta->make_immutable;

1;
