package MonkeyMan::Exception;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

use MonkeyMan::Logger;

use Method::Signatures;
use Devel::StackTrace;
use POSIX qw(strftime);

use overload q{""} => 'as_string';



func import (@exceptions) {

    foreach(@exceptions) {
        if($_ =~ /^::/) {
            _register_exception($_);
        } else {
            _register_exception((caller)[0] . '::Exception::' . $_);
        }
    }

}

func _register_exception(Str $exception!) {
    unless ( $exception->DOES(__PACKAGE__) ) {
        Moose::Meta::Class->create(
            $exception => (superclasses => [__PACKAGE__])
        );
    }
}



has 'message' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>    'get_message',
    writer      =>   '_set_message'
);

method message {
    return($self->get_message);
}



has 'timestamp' => (
    is          => 'ro',
    isa         => 'Int',
    lazy        => 0,
    reader      =>    'get_timestamp',
    writer      =>   '_set_timestamp',
    predicate   =>    'has_timestamp',
    builder     => '_build_timestamp'
);

method _build_timestamp {
    return(time);
}

method get_timestamp_formatted(Str $format? = &MonkeyMan::DEFAULT_DATE_TIME_FORMAT) {
    return(strftime($format, localtime($self->get_timestamp)));
}



has 'stack_trace_parameters' => (
    is          => 'ro',
    isa         => 'HashRef',
    lazy        => 1,
    reader      =>    'get_stack_trace_parameters',
    writer      =>   '_set_stack_trace_parameters',
    predicate   =>    'has_stack_trace_parameters',
    builder     => '_build_stack_trace_parameters',
);

method _build_stack_trace_parameters {
    return({
        indent          => 1,
        no_args         => 1,
        ignore_class    => [ qw(MonkeyMan::Exception) ]
    });
}



has 'stack_trace' => (
    is          => 'ro',
    isa         => 'Devel::StackTrace',
    lazy        => 1,
    reader      =>    'get_stack_trace',
    writer      =>   '_set_stack_trace',
    predicate   =>   '_has_stack_trace',
    builder     => '_build_stack_trace'
);

method _build_stack_trace {
    return(Devel::StackTrace->new(
        (defined($self) && blessed($self)) ?
            %{ $self->get_stack_trace_parameters } :
            %{     _build_stack_trace_parameters() }
    ));
}



func throw(...) {

    my $arg = shift;

    unless(blessed($arg)) {
        $arg = $arg->new(
            message     => "@_",
            stack_trace => _build_stack_trace
        );
    }

    die($arg);

}

method throwf(...) {

    my $message = shift;
    my @values;

    foreach my $element (@_) {
        push(@values, find_exceptions($element) ?
            $element->message :
            $element
        );
    }

    $self->throw(MonkeyMan::Logger::mm_sprintf($message, @values));
    # We have to address to it as MonkeyMan::Logger::mm_sprintf, because the
    # current subclass may not have such subroutine in its namespace!

}



func find_exceptions(...) {
    my @result;
    foreach (@_) {
        push(@result, $_)
            if(blessed($_[0]) && (
                $_[0]->DOES('MonkeyMan::Exception') ||
                $_[0]->DOES('Moose::Exception')
            ));
    }
    return(@result);
}



method as_string(...) {
    return(
        MonkeyMan::Logger::mm_sprintf(
            "[!] %s\n" .
            "^^^ The %s exception had been thrown at %s\n" .
            "^^^ %s",
                $self->get_message,
                blessed($self),
                $self->get_timestamp_formatted,
                $self->get_stack_trace->as_string
        )
     );
}

method as_string_short(...) {
    return(
        MonkeyMan::Logger::mm_sprintf(
            "%s [%s]",
                $self->get_message,
                blessed($self)
        )
     );
}



__PACKAGE__->meta->make_immutable;

1;
