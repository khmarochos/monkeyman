package MonkeyMan::ErrorHandling;

use strict;
use warnings;

use MonkeyMan::Error;

use Want;

use Moose::Role;
use namespace::autoclean;



has 'error' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Error',
    predicate   => 'has_error',
    reader      => '_get_error',
    writer      => '_set_error'
);



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
            text    => $error_text,
            caller  => \%caller_info
        ); };
        warn(mm_sprintify("Can't MonkeyMan::Error->new(): %s", $@))
            if($@);

        $self->_set_error($error) if(defined($error));

        # Returning undef in any case is important, as they would like to return it by the method,
        # so everyone expects undef here

        return(undef);

    } else {

        # Othervise we'll return contents of the error attribute

        return(undef)
            unless($self->has_error);

        if(want('OBJECT')) {
            return($self->_get_error);
        } else {
            return($self->_get_error->text);
        }

    }

}



sub error_message {

    my $self = shift;

    return("Undefined error") unless($self->has_error);

    my $error = $self->_get_error;
    return(mm_sprintify("Have got an error while running: %s", $error->text))
        unless($error->has_caller);

    my $caller = $error->caller;
    return(mm_sprintify(
        "Can't %s(): at %s line %d: %s",
            $caller->{'subroutine'},
            $caller->{'filename'},
            $caller->{'line'},
            $error->text
    ));
    
}



1;
