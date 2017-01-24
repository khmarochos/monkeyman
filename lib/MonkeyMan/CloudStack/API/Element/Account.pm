package MonkeyMan::CloudStack::API::Element::Account;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %vocabulary_tree = (
    type => 'Account',
    name => 'account',
    entity_node => 'account',
    actions => {
        list => {
            request => {
                command             => 'listAccounts',
                async               => 0,
                paged               => 1,
                parameters          => {
                    all => {
                        required            => 0,
                        command_parameters  => { 'listall' => 'true' },
                    },
                    accounttype => {
                        required            => 0,
                        command_parameters  => { 'accounttype' => '<%VALUE%>' },
                    },
                    filter_by_id => {
                        required            => 0,
                        command_parameters  => { 'id' => '<%VALUE%>' },
                    },
                    filter_by_name => {
                        required            => 0,
                        command_parameters  => { 'name' => '<%VALUE%>' },
                    },
                    filter_by_domainid => {
                        required            => 0,
                        command_parameters  => { 'domainid' => '<%VALUE%>' }
                    }
                }
            },
            response => {
                response_node   => 'listaccountsresponse',
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
        create => {
            request => {
                command             => 'createAccount',
                async               => 0,
                paged               => 0,
                parameters          => {
                    type => {
                        required            => 1,
                        command_parameters  => { 'accounttype' => '<%VALUE%>' },
                    },
                    name => {
                        required            => 1,
                        command_parameters  => { 'username' => '<%VALUE%>' },
                    },
                    email => {
                        required            => 1,
                        command_parameters  => { 'email' => '<%VALUE%>' },
                    },
                    first_name => {
                        required            => 1,
                        command_parameters  => { 'firstname' => '<%VALUE%>' },
                    },
                    last_name => {
                        required            => 1,
                        command_parameters  => { 'lastname' => '<%VALUE%>' },
                    },
                    password => {
                        required            => 1,
                        command_parameters  => { 'password' => '<%VALUE%>' },
                    },
                    account => {
                        required            => 0,
                        command_parameters  => { 'account' => '<%VALUE%>' },
                    },
                    domain => {
                        required            => 0,
                        command_parameters  => { 'domainid' => '<%VALUE%>' },
                    },
                    time_zone => {
                        required            => 0,
                        command_parameters  => { 'timezone' => '<%VALUE%>' },
                    },
                    network_domain => {
                        required            => 0,
                        command_parameters  => { 'networkdomain' => '<%VALUE%>' },
                    }
                }
            },
            response => {
                response_node   => 'createaccountresponse',
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
    }
);



__PACKAGE__->meta->make_immutable;

1;
