package MonkeyMan::CloudStack::API::Element::Domain;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use MonkeyMan::Exception qw(
    CantCreateDomain
);
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
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/id' ] },
                foreign => { parameters => { filter_by_domain_id => '<%OWN_KEY_VALUE%>' } },
            }
        },
    }
);



# Actually it's okay to create a domain with calling the perform_action()
# method, which is the "true" way, but I wanted to have a method to create
# a domain recursively (with all the parents needed), so the ...::Domain
# element class has a method for that.

func create_domain(
    Str                         :$desired_name!,
    Bool                        :$recursive = 0,
    MonkeyMan::CloudStack::API  :$api!,
    MonkeyMan::Logger           :$logger = $api->get_cloudstack->get_monkeyman->get_logger
) {
    my @parent_name_array = split('/', $desired_name);
    my $desired_name_tail = pop(@parent_name_array);
    my $parent_name = join('/', @parent_name_array);
    unless(length($parent_name)) {
        (__PACKAGE__ . '::Exception::CantCreateDomain')->throwf(
            "Can't create the %s domain, it has no parent", $desired_name
        );
    }
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
    if(!defined($parent_domain)) {
        if($recursive) {
            $parent_domain = create_domain(
                desired_name    => $parent_name,
                api             => $api,
                logger          => $logger,
                recursive       => 1
            );
        } else {
            (__PACKAGE__ . '::Exception::CantCreateDomain')->throwf(
                "Can't create the %s domain, can't find the %s parent",
                $desired_name, $parent_name
            );
        }
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
