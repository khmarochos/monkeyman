#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Exception qw(
    BadUsageRecord
);

use DateTime;



my $monkeyman       = MonkeyMan->new(
    app_name
        => 'fnysh_accounts',
    app_description
        => 'Fnyshes some real accounts to the database',
    app_version
        => '0.0.1',
    app_usage_help
        => <<__END_OF_USAGE_HELP__,
This application recognizes the following parameters:

    --mode <mode>
        [req]       The operating mode; possible modes are:
                        CloudStack  
                        ISPmanager4 (-)
                        ISPmanager5 (-)
    --actors <actors>
        [opt] [mul] Sources to be proceeded
__END_OF_USAGE_HELP__
    parameters_to_get_validated
        => <<'__END_OF_PARAMETERS_TO_GET_VALIDATED__'
m|mode=s:
  mode:
    requires_each:
      - mode
a|actors=s@:
  actors:
    requires_each:
      - actors
d|days=s:
  days:
domain-id=s:
  domain_id:
account-id=s:
  account_id:
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $parameters      = $monkeyman->get_parameters;
my $logger          = $monkeyman->get_logger;
my $hypermouse      = $monkeyman->get_hypermouse;
my $db_schema       = $hypermouse->get_schema;
my $now             = DateTime->now;
my $then            = $now; $then->subtract(days => $parameters->get_days);



if($parameters->get_mode =~ /^cloudstack$/i) {

    foreach my $cloudstack_handle (@{ $parameters->get_actors }) {

        my $cloudstack      = $monkeyman->get_cloudstack($cloudstack_handle);
        my $cloudstack_api  = $cloudstack->get_api;

        my $resource_set = $db_schema
            ->resultset('ResourceSet')
            ->search({ name => sprintf("CloudStack %s", $cloudstack_handle) })
            ->filter_validated(mask => 0b000111, now => $now)
            ->single;
        unless(defined($resource_set)) {
            $logger->warnf(
                "The %s CloudStack couldn't be recognized as a resource group",
                $cloudstack
            );
            next;
        }
        my $resource_set_id = $resource_set->id;

        my $data = {};

        foreach my $usage_record ($cloudstack_api->perform_action(
            type        => 'UsageRecord',
            action      => 'list',
            parameters  => {
                start_date  => $then->ymd('-'),
                end_date    => $then->ymd('-'),
                type        => 2,
                $parameters->has_domain_id
                    ? (filter_by_domain_id  => $parameters->get_domain_id )
                    : (                                                   ),
                $parameters->has_account_id
                    ? (filter_by_account_id => $parameters->get_account_id)
                    : (                                                   )
            },
            requested   => { element => 'element' }
        )) {
            $logger->debugf("Have got the %s usage record", $usage_record);

            my $domain_id
                = $usage_record->get_value('/domainid')
                // (__PACKAGE__ . '::Exception::BadUsageRecord')->throwf(
                    "The domainid isn't defined in the %s usage record",
                    $usage_record
                );
            my $resource_piece_domain
                = $db_schema
                    ->resultset('ResourcePiece')
                    ->search({
                        resource_type_id
                            => $db_schema
                                ->resultset('ResourceType')
                                ->find_by_full_name(resource_type_full_name => 'domain')
                                ->id,
                        resource_set_id
                            => $resource_set_id,
                        resource_handle
                            => $domain_id
                    })
                    ->filter_validated(now => $now, mask => 0b000111)
                    ->single
                // do {
                    $logger->warnf(
                        "The %s domain hasn't been fnyshed by HyperMouse",
                        $domain_id
                    );
                    next;
                };
            my $provisioning_agreement_domain = $resource_piece_domain
                ->search_related_deep(
                    resultset_class
                        => 'ProvisioningAgreement',
                    callout
                        => [ '@ResourcePiece > @ProvisioningObligation > @ProvisioningAgreement', { } ],
                    now
                        => $now
                )
                ->single;

            my $account_id
                = $usage_record->get_value('/accountid')
                // (__PACKAGE__ . '::Exception::BadUsageRecord')->throwf(
                    "The accountid isn't defined in the %s usage record",
                    $usage_record
                );
            my $resource_piece_account
                = $db_schema
                    ->resultset('ResourcePiece')
                    ->search({
                        resource_type_id
                            => $db_schema
                                ->resultset('ResourceType')
                                ->find_by_full_name(resource_type_full_name => 'account')
                                ->id,
                        resource_set_id
                            => $resource_set_id,
                        resource_handle
                            => $account_id
                    })
                    ->filter_validated(now => $now, mask => 0b000111)
                    ->single
                // do {
                    $logger->warnf(
                        "The account #%d hasn't been fnyshed by HyperMouse",
                        $account_id
                    );
                    next;
                };
            if($resource_piece_account->parent_resource_piece_id != $resource_piece_domain->id) {
                $logger->warnf(
                    "The account #%d seems to have a wrong parent",
                    $account_id
                );
                next;
            }
            my $provisioning_agreement_account = $resource_piece_account
                ->search_related_deep(
                    resultset_class
                        => 'ProvisioningAgreement',
                    callout
                        => [ '@ResourcePiece > @ProvisioningObligation > @ProvisioningAgreement', { } ],
                    now
                        => $now
                )
                ->single;

            if($provisioning_agreement_account->id != $provisioning_agreement_domain->id) {
                $logger->warnf(
                    "The account #%d and the domain #%d belong to different provisioning agreements",
                    $account_id,
                    $domain_id
                );
                next;
            }

            my $virtual_machine_id 
                = $usage_record->get_value('/virtualmachineid')
                // (__PACKAGE__ . '::Exception::BadUsageRecord')->throwf(
                    "The virtualmachineid isn't defined in the %s usage record",
                    $usage_record
                );
            my $resource_piece_virtual_machine
                = $db_schema
                    ->resultset('ResourcePiece')
                    ->search({
                        resource_type_id
                            => $db_schema
                                ->resultset('ResourceType')
                                ->find_by_full_name(resource_type_full_name => 'vm')
                                ->id,
                        resource_set_id
                            => $resource_set_id,
                        resource_handle
                            => $virtual_machine_id
                    })
                    ->filter_validated(now => $now, mask => 0b000111)
                    ->single;

            unless(
                defined($data->{ $virtual_machine_id }) &&
                    ref($data->{ $virtual_machine_id }) eq 'HASH'
            ) {
                $data->{ $virtual_machine_id } = {
                    provisioning_agreement_domain
                        => $provisioning_agreement_domain,
                    provisioning_agreement_account
                        => $provisioning_agreement_account,
                    resource_piece_domain
                        => $resource_piece_domain,
                    resource_piece_account
                        => $resource_piece_account,
                    usage_records
                        => []
                };
            }

            push(@{ $data->{ $virtual_machine_id }->{'usage_records'} }, $usage_record);

        }

        foreach my $virtual_machine_id (keys(%{ $data })) {

            $logger->debugf("Proceesing the usage records of the %s virtual machine",
                $virtual_machine_id
            );

            my $resource_piece_virtual_machine = ($db_schema
                ->resultset('ResourcePiece')
                ->update_when_needed(
                    parent_resource_piece_id
                        => $data->{ $virtual_machine_id }->{'resource_piece_account'}->id,
                    resource_type_id
                        => $db_schema
                            ->resultset('ResourceType')
                            ->find_by_full_name(resource_type_full_name => 'vm')
                            ->id,
                    resource_set_id
                        => $resource_set_id,
                    resource_handle
                        => $virtual_machine_id,
                    provisioning_obligation_update
                        => {
                            provisioning_agreement_id
                                => $data->{ $virtual_machine_id }->{'provisioning_agreement_account'}->id,
                            service_type_id
                                => $db_schema
                                    ->resultset('ServiceType')
                                    ->find_by_full_name(service_type_full_name => 'vdc.element.vm')
                                    ->id,
                            service_level_id
                                => $db_schema
                                    ->resultset('ServiceLevel')
                                    ->filter_validated(now => $now, mask => 0b000111)
                                    ->find({ short_name => 'basic' })
                                    ->id,
                            quantity
                                => 1
                        },
                    provisioning_obligation_bind
                        => 1,
                    now
                        => $now
                ))[$[];

            my $cpu_obligations = [];
            my $ram_obligations = [];

            foreach my $usage_record (@{ $data->{ $virtual_machine_id }->{'usage_records'} }) {

                $logger->debugf("Proceeding the %s usage record",
                    $usage_record->get_value('usageid')
                );

                my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);
                if(defined(my $cpu = $usage_record->get_value('/cpunumber'))) {
                    push(@{ $cpu_obligations }, {
                        provisioning_agreement_id
                            => $data->{ $virtual_machine_id }->{'provisioning_agreement_account'}->id,
                        service_type_id
                            => $db_schema
                                ->resultset('ServiceType')
                                ->find_by_full_name(service_type_full_name => 'vdc.element.cpu')
                                ->id,
                        service_level_id
                            => $db_schema
                                ->resultset('ServiceLevel')
                                ->filter_validated(now => $now, mask => 0b000111)
                                ->find({ short_name => 'basic' })
                                ->id,
                        quantity
                            => $cpu,
                        duration
                            => $duration
                    });
                }
                if(defined(my $ram = $usage_record->get_value('/memory'))) {
                    push(@{ $ram_obligations }, {
                        provisioning_agreement_id
                            => $data->{ $virtual_machine_id }->{'provisioning_agreement_account'}->id,
                        service_type_id
                            => $db_schema
                                ->resultset('ServiceType')
                                ->find_by_full_name(service_type_full_name => 'vdc.element.ram')
                                ->id,
                        service_level_id
                            => $db_schema
                                ->resultset('ServiceLevel')
                                ->filter_validated(now => $now, mask => 0b000111)
                                ->find({ short_name => 'basic' })
                                ->id,
                        quantity
                            => $ram,
                        duration
                            => $duration
                    });
                }
            }

            $db_schema
                ->resultset('ResourcePiece')
                ->update_when_needed(
                    parent_resource_piece_id
                        => $resource_piece_virtual_machine->id,
                    resource_type_id
                        => $db_schema
                            ->resultset('ResourceType')
                            ->find_by_full_name(resource_type_full_name => 'vm.cpu')
                            ->id,
                    resource_set_id
                        => $resource_set_id,
                    resource_handle
                        => $virtual_machine_id,
                    provisioning_obligation_update
                        => $cpu_obligations,
                    provisioning_obligation_bind
                        => 1,
                    now
                        => $now
                );
            $db_schema
                ->resultset('ResourcePiece')
                ->update_when_needed(
                    parent_resource_piece_id
                        => $resource_piece_virtual_machine->id,
                    resource_type_id
                        => $db_schema
                            ->resultset('ResourceType')
                            ->find_by_full_name(resource_type_full_name => 'vm.ram')
                            ->id,
                    resource_set_id
                        => $resource_set_id,
                    resource_handle
                        => $virtual_machine_id,
                    provisioning_obligation_update
                        => $ram_obligations,
                    provisioning_obligation_bind
                        => 1,
                    now
                        => $now
                );
        }

    }
}
