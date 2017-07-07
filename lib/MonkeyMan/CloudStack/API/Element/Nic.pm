package MonkeyMan::CloudStack::API::Element::Nic;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %vocabulary_tree = (
    type => 'Nic',
    name => 'nic',
    entity_node => 'nic',
    information => {
        id              => '/id',
        ipaddress       => '/ipaddress'
    },
    actions => {
        list => {
            request => {
                command             => 'listNics',
                async               => 0,
                paged               => 1,
                parameters          => {
                    filter_by_virtual_machine_id => {
                        required            => 1,
                        command_parameters  => { 'virtualmachineid' => '<%VALUE%>' },
                    },
                    filter_by_nic_id => {
                        required            => 0,
                        command_parameters  => { 'nicid' => '<%VALUE%>' },
                    },
                    filter_by_network_id => {
                        required            => 0,
                        command_parameters  => { 'networkid' => '<%VALUE%>' },
                    },
                }
            },
            response => {
                response_node   => 'listnicsresponse',
                results         => {
                    element         => {
                        return_as       => [ qw( dom element id ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/<%OUR_ENTITY_NODE%>' ],
                        required        => 0,
                        multiple        => 1
                    },
                    id              => {
                        return_as       => [ qw( value ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/<%OUR_ENTITY_NODE%>/id' ],
                        required        => 0,
                        multiple        => 1
                    },
                }
            }
        },
    },
    related => {
        our_virtual_machines => {
            type    => 'VirtualMachine',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/virtualmachineid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        },
        our_networks => {
            type    => 'Network',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/networkid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        }
    }
);



__PACKAGE__->meta->make_immutable;

1;
