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

func _criterions_to_parameters(
        :$listall,
    Str :$id,
    Str :$name
) {
    my %parameters;
    $parameters{'listall'}  = 'true'        if(defined($listall));
    $parameters{'id'}       = $id           if(defined($id));
    $parameters{'name'}     = $name         if(defined($name));
    return(%parameters);
}



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

our %vocabulary_data = (
    name => 'domain',
    entity_node => '<%OUR_NAME%>',
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
    actions => {
        list => {
            request  => {
                command             => 'listDomains',
                parameters          => {
                    all             => {
                        isa             => 'Bool',
                        required        => 0,
                        parameter_name  => 'listall',
                        parameter_value => '<%VALUE%>'
                    },
                    filter_by_id    => {
                        isa             => 'Str',
                        required        => 0,
                        parameter_name  => 'id',
                        parameter_value => '<%VALUE%>'
                    },
                    filter_by_name  => {
                        isa             => 'Str',
                        required        => 0,
                        parameter_name  => 'name',
                        parameter_value => '<%VALUE%>'
                    }
                }
            },
            response => {
                async           => 0,
                paged           => 1,
                response_node   => 'listdomainsresponse',
                results         => {
                    element         => {
                        return_as       => [ qw( dom element[Domain] id[Domain] ) ],
                        xpaths          => [ '/<%OUR_ENTITY_NODE%>' ],
                        required        => 0,
                        multiple        => 1
                    },
                    id              => {
                        return_as       => [ qw( value ) ],
                        xpaths          => [ '/<%OUR_ENTITY_NODE%>/id' ],
                        required        => 0,
                        multiple        => 1
                    }
                }
            }
        },
        create => {
            request => {
                command         => 'createDomain',
                parameters      => {
                    network_domain_name => {
                        isa             => 'Str',
                        required        => 0,
                        parameter_name  => 'networkdomain',
                        parameter_value => '<%VALUE%>'
                    },
                    parent_domain_id    => {
                        isa             => 'Str',
                        required        => 1,
                        parameter_name  => 'parentdomainid',
                        parameter_value => '<%VALUE%>'
                    }
                }
            },
            response => {
                async           => 1,
                response_node   => 'createdomainresponse',
                results         => {
                    domain          => {
                        return_as       => [ qw( dom element[Domain] id[Domain] ) ],
                        xpaths          => [ '/<%OUR_ENTITY_NODE%>' ],
                        required        => 1,
                        multiple        => 0
                    },
                    id              => {
                        return_as       => [ qw( value ) ],
                        xpaths          => [ '/<%OUR_ENTITY_NODE%>/id' ],
                        required        => 1,
                        multiple        => 0
                    },
                }
            }
        }
    }
);



__PACKAGE__->meta->make_immutable;

1;

=pod

=cut
