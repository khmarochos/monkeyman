package MonkeyMan::CloudStack::Elements::VirtualMachine;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Elements::_common';



sub _load_full_list_command {
    return({
        command => 'listVirtualMachines',
        listall => 'true'
    });
}

sub _generate_xpath_query {

    my($self, %parameters) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%parameters);

    # Are they going to find some element?
    if(ref($parameters{'find'}) eq 'HASH') {
        if($parameters{'find'}->{'attribute'} eq 'RESULT') {
            return("/listvirtualmachinesresponse/virtualmachine");
        } else {
            return("/listvirtualmachinesresponse/virtualmachine[" .
                $parameters{'find'}->{'attribute'} . "='" .
                $parameters{'find'}->{'value'} . "']"
            );
        }
    # Are they going to get some info about the element?
    } elsif(defined($parameters{'get'})) {
        return("/virtualmachine/$parameters{'get'}");
    }

    return($self->error("I don't understand what you're asking about"));

}


__PACKAGE__->meta->make_immutable;

1;

