package MonkeyMan::CloudStack::Elements::Volume;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('volume');
}



sub _load_full_list_command {
    return({
        command => 'listVolumes',
        listall => 'true'
    });
}

sub _generate_xpath_query {

    my($self, %parameters) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%parameters);

    if(defined($parameters{'find'})) {

        # Are they going to find some element?

        if($parameters{'find'}->{'attribute'} eq 'FINAL') {
            return("/listvolumesresponse/volume");
        } else {
            return("/listvolumesresponse/volume[" .
                $parameters{'find'}->{'attribute'} . "='" .
                $parameters{'find'}->{'value'} . "']"
            );
        }

    } elsif(defined($parameters{'get'})) {

        # Are they going to get some info about the element?

        return("/volume/$parameters{'get'}");

    }

    return($self->error("I don't understand what you're asking about"));

}



__PACKAGE__->meta->make_immutable;

1;

