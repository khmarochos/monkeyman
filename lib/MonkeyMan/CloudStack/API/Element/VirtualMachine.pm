package MonkeyMan::CloudStack::API::Element::VirtualMachine;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;



our %vocabulary_tree = (
    type => 'VirtualMachine',
    name => 'virtual machine',
    entity_node => 'virtualmachine',
    actions => {
        list => {
            request => {
                command             => 'listVirtualMachines',
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
                response_node   => 'listvirtualmachinesresponse',
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
                command             => 'deployVirtualMachine',
                async               => 1,
                paged               => 0,
                parameters          => {
                    zoneid => {
                        required            => 1,
                        command_parameters  => { 'zoneid' => '<%VALUE%>' },
                    },
                    templateid => {
                        required            => 1,
                        command_parameters  => { 'templateid' => '<%VALUE%>' },
                    },
                    serviceofferingid => {
                        required            => 1,
                        command_parameters  => { 'serviceofferingid' => '<%VALUE%>' },
                    },
                    diskofferingid => {
                        required            => 0,
                        command_parameters  => { 'diskofferingid' => '<%VALUE%>' },
                    },
                    size => {
                        required            => 0,
                        command_parameters  => { 'size' => '<%VALUE%>' },
                    },
                    rootdisksize => {
                        required            => 0,
                        command_parameters  => { 'rootdisksize' => '<%VALUE%>' },
                    },
                    details => {
                        required            => 0,
                        command_parameters  => { 'details' => '<%VALUE%>' },
                    },
                    networkids => {
                        required            => 0,
                        command_parameters  => { 'networkids' => '<%VALUE%>' },
                    },
                    iptonetworklist => {
                        required            => 0,
                        command_parameters  => { 'iptonetworklist' => '<%VALUE%>' }
                    },
                    domainid => {
                        required            => 0,
                        command_parameters  => { 'domainid' => '<%VALUE%>' },
                    },
                    account => {
                        required            => 0,
                        command_parameters  => { 'account' => '<%VALUE%>' },
                    },
                    hostid => {
                        required            => 0,
                        command_parameters  => { 'hostid' => '<%VALUE%>' },
                    },
                    name => {
                        required            => 0,
                        command_parameters  => { 'name' => '<%VALUE%>' },
                    },
                    displayname => {
                        required            => 0,
                        command_parameters  => { 'displayname' => '<%VALUE%>' },
                    },
                    hypervisor => {
                        required            => 0,
                        command_parameters  => { 'hypervisor' => '<%VALUE%>' },
                    },
                    startvm => {
                        required            => 0,
                        command_parameters  => { 'startvm' => '<%VALUE%>' },
                    }
                }
            },
            response => {
                response_node   => 'queryasyncjobresultresponse',
                results         => {
                    element         => {
                        return_as       => [ qw( dom element id ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/jobresult/<%OUR_ENTITY_NODE%>' ],
                        required        => 0,
                        multiple        => 1
                    },
                    id              => {
                        return_as       => [ qw( value ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/jobresult/<%OUR_ENTITY_NODE%>/id' ],
                        required        => 0,
                        multiple        => 1
                    }
                }
            }
        },
        start => {
            request => {
                command             => 'startVirtualMachine',
                async               => 1,
                paged               => 0,
                parameters          => {
                    id => {
                        auto                => 1,
                        command_parameters  => { 'id' => '<%OUR_ID%>' },
                    },
                }
            },
            response => {
                response_node   => 'queryasyncjobresultresponse',
                results         => {
                    element         => {
                        return_as       => [ qw( dom element id ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/jobresult/<%OUR_ENTITY_NODE%>' ],
                        required        => 0,
                        multiple        => 1
                    },
                    id              => {
                        return_as       => [ qw( value ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/jobresult/<%OUR_ENTITY_NODE%>/id' ],
                        required        => 0,
                        multiple        => 1
                    }
                }
            }
        },
        stop => {
            request => {
                command             => 'stopVirtualMachine',
                async               => 1,
                paged               => 0,
                parameters          => {
                    id => {
                        auto                => 1,
                        command_parameters  => { 'id' => '<%OUR_ID%>' },
                    }
                }
            },
            response => {
                response_node   => 'queryasyncjobresultresponse',
                results         => {
                    element         => {
                        return_as       => [ qw( dom element id ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/jobresult/<%OUR_ENTITY_NODE%>' ],
                        required        => 0,
                        multiple        => 1
                    },
                    id              => {
                        return_as       => [ qw( value ) ],
                        queries         => [ '/<%OUR_RESPONSE_NODE%>/jobresult/<%OUR_ENTITY_NODE%>/id' ],
                        required        => 0,
                        multiple        => 1
                    }
                }
            }
        },
        change_service_offering => {
            request => {
                command             => 'changeServiceForVirtualMachine',
                async               => 0,
                paged               => 0,
                parameters          => {
                    service_offering_id => {
                        required            => 1,
                        command_parameters  => { 'serviceofferingid' => '<%VALUE%>' },
                    },
                    id => {
                        auto                => 1,
                        command_parameters  => { 'id' => '<% OUR_ID || VALUE %>' },
                    },
                }
            },
            response => {
                response_node   => 'changeserviceforvirtualmachineresponse',
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
        our_hosts => {
            type    => 'Host',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/hostid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        }
    }
);



__PACKAGE__->meta->make_immutable;

1;
