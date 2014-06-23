package MonkeyMan::CloudStack::Elements::Domain;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



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

    # Are they going to find some element?
    if(ref($parameters{'find'}) eq 'HASH') {
        if($parameters{'find'}->{'attribute'} eq 'FINAL') {
            return("/listdomainsresponse/domain");
        } else {
            return("/listdomainsresponse/domain[" .
                $parameters{'find'}->{'attribute'} . "='" .
                $parameters{'find'}->{'value'} . "']"
            );
        }
    # Are they going to get some info about the element?
    } elsif(defined($parameters{'get'})) {
        return("/domain/$parameters{'get'}");
    }

    return($self->error("I don't understand what you're asking about"));

}



__PACKAGE__->meta->make_immutable;

1;

