package MonkeyMan::CloudStack::API::Element::Volume;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %vocabulary_tree = (
    type => 'Volume',
    name => 'volume',
    entity_node => 'volume',
    information => {
        id      => '/id',
        name    => '/name'
    },
    actions => {
        list => {
            request => {
                command             => 'listVolumes',
                async               => 0,
                paged               => 1,
                parameters          => {
                    all => {
                        required            => 0,
                        command_parameters  => { 'listall' => 'true' },
                    },
                    filter_by_id => {
                        required            => 0,
                        command_parameters  => { 'id' => '<%VALUE%>' },
                    },
                    filter_by_domain_id => {
                        required            => 0,
                        command_parameters  => { 'domainid' => '<%VALUE%>' },
                    },
                    filter_by_zoneid => {
                        required            => 0,
                        command_parameters  => { 'zoneid' => '<%VALUE%>' },
                    },
                }
            },
            response => {
                response_node   => 'listvolumesresponse',
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
        }
    },
    related => {
        our_snapshots => {
            type    => 'Snapshot',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/id' ] },
                foreign => { parameters => { filter_by_volume_id => '<%OWN_KEY_VALUE%>', all => 1 } },
            }
        },
        our_storage_pools => {
            type    => 'StoragePool',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/storageid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        },
        our_virtual_machines => {
            type    => 'VirtualMachine',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/virtualmachineid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        },
        our_domains => {
            type    => 'Domain',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/domainid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        }
    }
);



__PACKAGE__->meta->make_immutable;

1;
