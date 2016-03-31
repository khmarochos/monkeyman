package MonkeyMan::CloudStack::API::Element::Domain;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



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
                        command_parameters  => { 'listall' => 'true' },
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
        },
        create => {
            request => {
                command             => 'createDomain',
                async               => 0,
                paged               => 0,
                parameters          => {
                    name => {
                        required            => 1,
                        command_parameters  => { 'name' => '<%VALUE%>' },
                    },
                    parent => {
                        required            => 0,
                        command_parameters  => { 'parentdomainid' => '<%VALUE%>' },
                    }
                }
            },
            response => {
                response_node   => 'createdomainresponse',
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
                    }
                }
            }
        }
    },
    related => {
        our_virtual_machines => {
            type    => 'VirtualMachine',
            keys    => [ {
                value   => { queries    => [ '<%OUR_ENTITY_NODE%>/id' ] },
                foreign => { requested  => [ { filter_by_domain_id => '<%OUR_KEY_VALUE%>' } ] },
            } ]
        },
    }
);



func create_domain_recursive(
    Str                         :$desired_name!,
    MonkeyMan::CloudStack::API  :$api!,
    MonkeyMan::Logger            $logger = $api->get_cloudstack->get_monkeyman->get_logger
) {
    my @parent_name_array = split('/', $desired_name);
    my $desired_name_tail = pop(@parent_name_array);
    my $parent_name = join('/', @parent_name_array);
    $logger->tracef(
        "Looking for the parent of the %s domain (it's supposed to be %s)",
        $desired_name, $parent_name
    );
    my $parent_domain = $api->perform_action(
        type        => 'Domain',
        action      => 'list',
        parameters  => { filter_by_path_all => $parent_name },
        requested   => { element => 'element' }
    );
    unless(defined($parent_domain)) {
        $parent_domain = create_domain_recursive(
            desired_name    => $parent_name,
            api             => $api,
            logger          => $logger
        );
    }
    $logger->tracef("The parent domain has been found (%s)", $parent_domain);
    my $domain = $api->perform_action(
        type        => 'Domain',
        action      => 'create',
        parameters  => {
            name        => $desired_name_tail,
            parent      => $parent_domain->get_id
        },
        requested   => { element => 'element' }
    );
    return($domain);
}



__PACKAGE__->meta->make_immutable;

1;
