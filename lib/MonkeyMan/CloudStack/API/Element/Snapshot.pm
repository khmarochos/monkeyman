package MonkeyMan::CloudStack::API::Element::Snapshot;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %vocabulary_tree = (
    type => 'Snapshot',
    name => 'snapshot',
    entity_node => 'snapshot',
    actions => {
        list => {
            request => {
                command             => 'listSnapshots',
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
                    filter_by_volume_id => {
                        required            => 0,
                        command_parameters  => { 'volumeid' => '<%VALUE%>' },
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
                response_node   => 'listsnapshotsresponse',
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
    }
);



__PACKAGE__->meta->make_immutable;

1;
