package MonkeyMan::ErrorHandling;

use strict;
use warnings;

use MonkeyMan::Utils;
use MonkeyMan::Error;

use Want;
use Carp qw(longmess);

use Moose::Role;
use namespace::autoclean;



has 'errors' => (
    is          => 'ro',
    isa         => 'ArrayRef',
    builder     => '_build_errors',
    lazy        => 1
);



sub _build_errors {

    # If it's "lazy", each object has it's own error stack

    return([]);

}



sub error {

    my ($self, $error_text) = @_;

    # Did they give us any arguments?

    if(defined($error_text)) {

        # And let's store some information about the caller

        my %caller_info;
        my @caller = caller(1);
        if(@caller) {
            %caller_info = (
                package     => $caller[0],
                filename    => $caller[1],
                line        => $caller[2],
                subroutine  => $caller[3],
                hasargs     => $caller[4],
                wantarray   => $caller[5],
                evaltext    => $caller[6],
                is_require  => $caller[7],
                hints       => $caller[8],
                bitmask     => $caller[9],
            );
        }

        my $error = eval { MonkeyMan::Error->new(
            text        => $error_text,
            caller      => \%caller_info
        ); };
        warn(mm_sprintify("Can't MonkeyMan::Error->new(): %s", $@))
            if($@);

        $self->push_error($error)
            if(defined($error));

        # Returning undef in any case is important, as they would like to return it by the method,
        # so everyone expects undef here

        return(undef);

    } else {

        # Othervise we'll return contents of the error attribute

        return(undef)
            unless($self->has_errors);

        if(want('OBJECT')) {
            return($self->pop_error);
        } else {
            return($self->pop_error->text);
        }

    }

}



sub push_error {

    my $self    = shift;
    my $error   = shift;

    return(undef)
        unless(ref($error) eq 'MonkeyMan::Error');

    push(@{ $self->errors }, $error);

}



sub pop_error {

    my $self = shift;

    return(pop(@{ $self->errors }))

}



sub has_errors {

    my $self = shift;

    return(scalar(@{ $self->errors }));

}



sub error_message {

    my $self = shift;

    return("The error stack is empty")
        unless($self->has_errors);

    my $error = $self->pop_error;

    return(mm_sprintify("Have got an error: %s", $error->text))
        unless($error->has_caller);

    my $caller = $error->caller;
    return(mm_sprintify(
        "Can't %s(): %s%s",
            $caller->{'subroutine'},
            $error->text,
            $error->text =~ /\[BACKTRACE\]\s/ ? "" : ("\n" . $error->backtrace)
    ));
    
}



1;
