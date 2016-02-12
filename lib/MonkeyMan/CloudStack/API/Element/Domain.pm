package MonkeyMan::CloudStack::API::Element::Domain;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %_magic_words = (
    find_command    => 'listDomains',
    list_tag_global => 'listdomainsresponse',
    list_tag_entity => 'domain'
);

our %_related = (
    VirtualMachine  => {
        class_name  => 'MonkeyMan::CloudStack::API::Element::VirtualMachine',
        local_key   => 'id',
        foreign_key => 'domainid'
    }
);

=pod

    $parent1 = $api->get_elements(
        type        => 'Domain',
        xpaths      => [ '<%OUR_ENTITY_NODE>[name = "ZALOOPA"]' ]
    );
    $parent2 = $api->get_elements(
        type        => 'Domain',
        criterions  => { name => 'ZALOOPA' }
    );
    ok($parent1->get_id eq $parent2->get_id);

    $child = $api->new_element('Domain')->do(
        action          => 'create',
        return_as       => 'element[Domain]',
        parentdomainid  => $parent1->get_id
    }

=cut

our %vocabulary_tree = (
    type => 'Domain',
    name => 'domain',
    entity_node => 'domain',
    actions => {
        list => {
            request => {
                command             => 'listDomains',
                async               => 0,
                paged               => 1,
                parameters          => {
                    all => {
                        required            => 0,
                        command_parameters  => { 'listall' => '<%VALUE%>' },
                    },
                    filter_by_id => {
                        required            => 0,
                        command_parameters  => { 'id' => '<%VALUE%>' },
                    },
                    filter_by_name => {
                        required            => 0,
                        command_parameters  => { 'name' => '<%VALUE%>' },
                    },
                    filter_by_path => {
                        required            => 0,
                        filters             => [ '/<%OUR_RESPONSE_NODE%>/<%OUR_ENTITY_NODE%>[path = "<%VALUE%>"]' ]
                    },
                    filter_by_path_all => {
                        required            => 0,
                        command_parameters  => { 'listall' => 'true' },
                        filters             => [ '/<%OUR_RESPONSE_NODE%>/<%OUR_ENTITY_NODE%>[path = "<%VALUE%>"]' ]
                    }
                }
            },
            response => {
                response_node   => 'listdomainsresponse',
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
                    path              => {
                        return_as       => [ qw( value ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/<%OUR_ENTITY_NODE%>/path' ],
                        required        => 0,
                        multiple        => 1
                    }
                }
            }
        }
    },
    related => {
        our_virtual_machines => {
            type    => 'VirtualMachine',
            keys    => [ {
                value   => { xpaths     => [ '/<%OUR_ENTITY_NODE%>/id' ] },
                foreign => { xpaths     => [ '/<%THEIR_ENTITY_NODE%>[domainid = "<%OUR_KEY_VALUE%>"]' ] },
            } ]
        },
        our_accounts => {
            type    => 'Account',
            keys    => [ {
                value   => { xpaths     => [ '/<%OUR_ENTITY_NODE%>/id' ] },
                foreign => { criterions => [ qw( domainid ) ] }
            } ]
        }
    },
);



__PACKAGE__->meta->make_immutable;

1;

=pod

=cut
