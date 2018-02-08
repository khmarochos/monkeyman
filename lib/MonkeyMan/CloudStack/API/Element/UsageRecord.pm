package MonkeyMan::CloudStack::API::Element::UsageRecord;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Roles::Element';

use Method::Signatures;




our %vocabulary_tree = (
    type => 'UsageRecord',
    name => 'usage record',
    entity_node => 'usagerecord',
    actions => {
        list => {
            request => {
                command             => 'listUsageRecords',
                async               => 0,
                paged               => 1,
                parameters          => {
                    start_date => {
                        required            => 1,
                        command_parameters  => { 'startdate' => '<%VALUE%>' }
                    },
                    end_date => {
                        required            => 1,
                        command_parameters  => { 'enddate' => '<%VALUE%>' }
                    },
                    type => {
                        required            => 0,
                        command_parameters  => { 'type' => '<%VALUE%>' }
                    },
                    filter_by_domain_id => {
                        required            => 0,
                        command_parameters  => { 'domainid' => '<%VALUE%>' }
                    },
                    filter_by_account_id => {
                        required            => 0,
                        command_parameters  => { 'accountid' => '<%VALUE%>' }
                    }
                }
            },
            response => {
                response_node   => 'listusagerecordsresponse',
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
        our_accounts => {
            type    => 'Account',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/accountid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        },
        our_domains => {
            type    => 'Domain',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/domainid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        },
        our_virtual_machines => {
            type    => 'VirtualMachine',
            keys    => {
                own     => { queries    => [ '/<%OUR_ENTITY_NODE%>/virtualmachineid' ] },
                foreign => { parameters => { filter_by_id => '<%OWN_KEY_VALUE%>' } },
            }
        }
    }
);



__PACKAGE__->meta->make_immutable;

1;
