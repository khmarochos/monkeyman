package MonkeyMan::CloudStack::Elements::Domain;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('domain');
}



sub _load_full_list_command {
    return({
        command => 'listDomains',
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
            return("/listdomainsresponse/domain");
        } else {
            return("/listdomainsresponse/domain[" .
                $parameters{'find'}->{'attribute'} . "='" .
                $parameters{'find'}->{'value'} . "']"
            );
        }

    } elsif(defined($parameters{'get'})) {

        # Are they going to get some info about the element?

        return("/domain/$parameters{'get'}");

    }

    return($self->error("I don't understand what you're asking about"));

}



__PACKAGE__->meta->make_immutable;

1;

