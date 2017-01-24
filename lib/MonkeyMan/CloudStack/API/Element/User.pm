package MonkeyMan::CloudStack::API::Element::User;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %vocabulary_tree = (
    type => 'User',
    name => 'user',
    entity_node => 'user',
    actions => {
        list => {
            request => {
                command             => 'listUsers',
                async               => 0,
                paged               => 1,
                parameters          => {
                    all => {
                        required            => 0,
                        command_parameters  => { 'listall' => 'true' }
                    },
                    name => {
                        required            => 0,
                        command_parameters  => { 'username' => '<%VALUE%>' }
                    },
                    account => {
                        required            => 0,
                        command_parameters  => { 'account' => '<%VALUE%>' }
                    },
                    domain => {
                        required            => 0,
                        command_parameters  => { 'domainid' => '<%VALUE%>' }
                    }
                }
            },
            response => {
                response_node   => 'listusersresponse',
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
                command             => 'createUser',
                async               => 0,
                paged               => 0,
                parameters          => {
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
                    }
                }
            },
            response => {
                response_node   => 'createuserresponse',
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
        },
        update => {
            request => {
                command             => 'updateUser',
                async               => 0,
                paged               => 0,
                parameters          => {
                    id => {
                        required            => 1,
                        command_parameters  => { 'id' => '<%VALUE%>' },
                    },
                    email => {
                        required            => 0,
                        command_parameters  => { 'email' => '<%VALUE%>' },
                    },
                    first_name => {
                        required            => 0,
                        command_parameters  => { 'firstname' => '<%VALUE%>' },
                    },
                    last_name => {
                        required            => 0,
                        command_parameters  => { 'lastname' => '<%VALUE%>' },
                    },
                    password => {
                        required            => 0,
                        command_parameters  => { 'password' => '<%VALUE%>' },
                    },
                    time_zone => {
                        required            => 0,
                        command_parameters  => { 'timezone' => '<%VALUE%>' },
                    },
                    user_api_key => {
                        required            => 0,
                        command_parameters  => { 'userapikey' => '<%VALUE%>' }
                    },
                    user_secret_key => {
                        required            => 0,
                        command_parameters  => { 'usersecretkey' => '<%VALUE%>' }
                    }
                }
            },
            response => {
                response_node   => 'createuserresponse',
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
