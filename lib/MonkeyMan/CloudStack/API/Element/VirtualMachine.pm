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

our %_related = (
    Domain  => {
        class_name  => 'MonkeyMan::CloudStack::API::Element::Domain',
        local_key   => 'domainid',
        foreign_key => 'id'
    }
);



__PACKAGE__->meta->make_immutable;

1;
