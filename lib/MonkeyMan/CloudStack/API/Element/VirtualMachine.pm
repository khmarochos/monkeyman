package MonkeyMan::CloudStack::API::Element::VirtualMachine;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %_magic_words = (
    find_command    => 'listVirtualMachines',
    list_tag_global => 'listvirtualmachinesresponse',
    list_tag_entity => 'virtualmachine',
);



__PACKAGE__->meta->make_immutable;

1;
