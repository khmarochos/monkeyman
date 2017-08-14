#!/usr/bin/env perl

use strict;
use warnings;

use constant UR_T_VIRTUALMACHINE    => 2;
use constant UR_T_IPADDRESS         => 3;
use constant UR_T_VOLUME            => 6;

use HyperMouse::ServicePackagePool;

use MonkeyMan;
use MonkeyMan::Exception qw(
    BadUsageRecord
);

use DateTime;
use DateTime::Format::Strptime;
use XML::LibXML;
use Cache::Memcached;
use Data::UUID;



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
    --actor <actor>
        [opt] [mul] Sources to be proceeded
    --days <number of days>
        [opt]       Rewind to N days ago (default: 1)
    --domain-id <domain ID>
        [opt] [mul] ... #TODO: describe
    --account-id <account ID>
        [opt] [mul] ... #TODO: describe
    --load-usage-records <file name>
        [opt] [mul] ... #TODO: describe
__END_OF_USAGE_HELP__
    parameters_to_get_validated
        => <<'__END_OF_PARAMETERS_TO_GET_VALIDATED__'
m|mode=s:
  mode:
    requires_each:
      - mode
a|actor=s@:
  actor:
    requires_each:
      - actor
d|days=s:
  days:
domain-id=s@:
  domain_id:
account-id=s@:
  account_id:
load-usage-records=s%:
  load_usage_records
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $parameters      = $monkeyman->get_parameters;
my $logger          = $monkeyman->get_logger;
my $hypermouse      = $monkeyman->get_hypermouse;
my $db_schema       = $hypermouse->get_schema;

my $now             = DateTime->now;
my $then            = $now;
$then->subtract(
    days => $parameters->has_days ? $parameters->get_days : 1
);

my $cache           = Cache::Memcached->new(servers => '127.0.0.1:11211');
                    # ^^^ TODO: parametrize or even make MonkeyMan::Cache
my $datetime_strp   = DateTime::Format::Strptime->new(
    pattern     => "%F'T'%T%z",
    locale      => "en_US",
    on_error    => "croak",
    strict      => 1
);
my $uuid_generator  = Data::UUID->new;



if($parameters->get_mode =~ /^cloudstack$/i) {

    foreach my $cloudstack_handle (@{ $parameters->get_actor }) {

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

        my $all_domains;
        my $all_accounts;
        my $all_usage_records = {
            &UR_T_VIRTUALMACHINE    => {},
            &UR_T_VOLUME            => {},
            &UR_T_IPADDRESS         => {}
        };

        #
        # Collecting and sorting the usage records
        #

        foreach my $usage_record_type (UR_T_VIRTUALMACHINE, UR_T_VOLUME, UR_T_IPADDRESS) {

            my @usage_records;
            if($parameters->has_load_usage_records) {
                my $usage_records_dom = XML::LibXML->load_xml(
                    location => $parameters->get_load_usage_records->{ $usage_record_type }
                );
                foreach my $usage_record_node (map({ $_->cloneNode(1) } $usage_records_dom->findnodes('//usagerecord'))) {
                    my $usage_record_dom = XML::LibXML::Document->createDocument; $usage_record_dom->setDocumentElement($usage_record_node);
                    push(@usage_records, $cloudstack_api->get_elements(
                        type        => 'UsageRecord',
                        doms        => [ $usage_record_dom ],
                        return_as   => 'element'
                    ));
                }
            } else {
                if($parameters->has_domain_id) {
                    foreach my $domain_id (@{ $parameters->get_domain_id }) {
                        push(@usage_records, $cloudstack_api->perform_action(
                            type        => 'UsageRecord',
                            action      => 'list',
                            parameters  => {
                                start_date          => $then->ymd('-'),
                                end_date            => $then->ymd('-'),
                                type                => $usage_record_type,
                                filter_by_domain_id => $domain_id
                            },
                            requested   => { element => 'element' }
                        ));
                    }
                }
                if($parameters->has_account_id) {
                    foreach my $account_id (@{ $parameters->get_account_id }) {
                        push(@usage_records, $cloudstack_api->perform_action(
                            type        => 'UsageRecord',
                            action      => 'list',
                            parameters  => {
                                start_date          => $then->ymd('-'),
                                end_date            => $then->ymd('-'),
                                type                => $usage_record_type,
                                filter_by_account_id => $account_id
                            },
                            requested   => { element => 'element' }
                        ));
                    }
                }
                if(
                    (! $parameters->has_domain_id) &&
                    (! $parameters->has_account_id)
                ) {
                    @usage_records = $cloudstack_api->perform_action(
                        type        => 'UsageRecord',
                        action      => 'list',
                        parameters  => {
                            start_date          => $then->ymd('-'),
                            end_date            => $then->ymd('-'),
                            type                => $usage_record_type
                        },
                        requested   => { element => 'element' }
                    );
                }
            }

            foreach my $usage_record (@usage_records) {

                $logger->debugf("Have got the %s usage record", $usage_record);

                # Getting the domain's information

                my $domain_data;
                my $domain_id
                    = $usage_record->get_value('/domainid')
                    // (__PACKAGE__ . '::Exception::BadUsageRecord')->throwf(
                        "The domainid isn't defined in the %s usage record (%s)",
                        $usage_record,
                        $usage_record->get_dom
                    );
                unless(
                    defined($domain_data = $all_domains->{ $domain_id }) &&
                        ref($domain_data) eq 'HASH'
                ) {
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
                    $domain_data = $all_domains->{ $domain_id } = {
                        provisioning_agreement_domain
                            => $provisioning_agreement_domain,  # ResultSet
                        resource_piece_domain
                            => $resource_piece_domain,          # ResultSet
                        accounts
                            => {}                               # being filled with the data
                    };
                }

                # Getting the account's information

                my $account_data;
                my $account_id
                    = $usage_record->get_value('/accountid')
                    // (__PACKAGE__ . '::Exception::BadUsageRecord')->throwf(
                        "The accountid isn't defined in the %s usage record (%s)",
                        $usage_record,
                        $usage_record->get_dom
                    );
                unless(
                    defined($account_data = $all_accounts->{ $account_id }) &&
                        ref($account_data) eq 'HASH'
                ) {
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
                    if($resource_piece_account->parent_resource_piece_id != $domain_data->{'resource_piece_domain'}->id) {
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
                    if($provisioning_agreement_account->id != $domain_data->{'provisioning_agreement_domain'}->id) {
                        $logger->warnf(
                            "The account #%d and the domain #%d belong to different provisioning agreements",
                            $account_id,
                            $domain_id
                        );
                        next;
                    }
                    $account_data = $all_accounts->{ $account_id } = {
                        provisioning_agreement_account
                            => $provisioning_agreement_account, # ResultSet
                        resource_piece_account
                            => $resource_piece_account,         # ResultSet
                        service_package_pool
                            => HyperMouse::ServicePackagePool->new(
                                cache                   => $cache,
                                hypermouse_schema       => $db_schema,
                                cloudstack_api          => $cloudstack_api
                            ),
                        usage_records
                            => {
                                &UR_T_VIRTUALMACHINE    => {},
                                &UR_T_VOLUME            => {},
                                &UR_T_IPADDRESS         => {}
                            },
                    };
                }
                unless(defined($all_domains->{ $domain_id }->{'accounts'}->{ $account_id })) {
                               $all_domains->{ $domain_id }->{'accounts'}->{ $account_id } = $account_data;
                }

                my $usage_record_data;
                my $usage_record_id =
                    $usage_record->get_value('/usageid') //
                    lc($uuid_generator->create_str);

                # If there are no records about this element in the big hash,
                # create a record and fill it with the data
 
                unless(
                    defined($usage_record_data = $all_usage_records->{ $usage_record_type }->{ $usage_record_id }) &&
                        ref($usage_record_data) eq 'HASH'
                ) {
                    $usage_record_data = $all_usage_records->{ $usage_record_type }->{ $usage_record_id } = {
                        provisioning_agreement_account
                            => $account_data->{'provisioning_agreement_account'},   # ResultSet
                        resource_piece_account
                            => $account_data->{'resource_piece_account'},           # ResultSet
                        account_data
                            => $account_data,
                        usage_records
                            => []                                                   # being filled with the data
                    };
                }
                push(@{ $usage_record_data->{'usage_records'} }, $usage_record);
                unless(
                    defined($all_accounts->{ $account_id }->{'usage_records'}->{ $usage_record_type }->{ $usage_record_id }) &&
                        ref($all_accounts->{ $account_id }->{'usage_records'}->{ $usage_record_type }->{ $usage_record_id }) eq 'ARRAY'
                ) {
                    $all_accounts->{ $account_id }->{'usage_records'}->{ $usage_record_type }->{ $usage_record_id } = $usage_record_data;
                }

            }
        }

        #
        # Now all the usage records have been collected and stored to various
        # $all-variables, proceeding them for each account separately
        # 

        my $service_packages = {};

        while(my($account_id, $account_data) = each(%{ $all_accounts })) {

            $logger->debugf("Processing the usage records of the %s account",
                $account_id
            );

            my $spp = $account_data->{'service_package_pool'};

            # Processing virtual machines' usage records

            while(my($virtual_machine_id, $virtual_machine_data) = each(%{ $account_data->{'usage_records'}->{ &UR_T_VIRTUALMACHINE } })) {

                $db_schema->storage->txn_begin;

                $logger->debugf("Processing the usage records of the %s virtual machine",
                    $virtual_machine_id
                );

                my $cpu_obligations = [];
                my $ram_obligations = [];
                my $duration_total = 0;
                my $datetime_base;

                foreach my $usage_record (@{ $virtual_machine_data->{'usage_records'} }) {

                    $logger->debugf("Processing the %s usage record",
                        $usage_record
                    );

                    my $datetime_base_new = $datetime_strp->parse_datetime($usage_record->get_value('/startdate'));
                    $logger->warnf("This usage record's startdate differs from the previous one's")
                        if(defined($datetime_base) && ! DateTime->compare($datetime_base, $datetime_base_new));
                    $datetime_base = $datetime_base_new->clone;

                    $duration_total += my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);

                    my $cpu = $usage_record->get_value('/cpunumber');
                    my $ram = $usage_record->get_value('/memory');

                    # Try to detect a legacy (non-flexible) service package

                    if(my $service_package_id = $spp->detect_service_package(
                        cloudstack_element_type
                            => 'VirtualMachine',
                        cloudstack_element_id
                            => $virtual_machine_id,
                        resources
                            => {
                                $db_schema
                                    ->resultset('ResourceType')
                                    ->find_by_full_name(resource_type_full_name => 'vm.cpu')
                                    ->id
                                        => $cpu,
                                $db_schema
                                    ->resultset('ResourceType')
                                    ->find_by_full_name(resource_type_full_name => 'vm.ram')
                                    ->id
                                        => $ram
                            },
                        from
                            => $datetime_base->epoch + $duration_total - $duration,
                        till
                            => $datetime_base->epoch + $duration_total
                    )) {
                        $logger->debugf("The %s service package is detected",
                            $db_schema
                                ->resultset('ServicePackage')
                                ->find($service_package_id)
                                ->short_name
                        );
                    } else {
                        push(@{ $cpu_obligations }, {
                            provisioning_agreement_id
                                => $virtual_machine_data->{'provisioning_agreement_account'}->id,
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
                        push(@{ $ram_obligations }, {
                            provisioning_agreement_id
                                => $virtual_machine_data->{'provisioning_agreement_account'}->id,
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

                my $resource_piece_virtual_machine =
                    $db_schema
                        ->resultset('ResourcePiece')
                        ->search({ id => { 'in' => [
                            map({ $_->id }
                                $db_schema
                                    ->resultset('ResourcePiece')
                                    ->update_when_needed(
                                        parent_resource_piece_id
                                            => $virtual_machine_data->{'resource_piece_account'}->id,
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
                                                    => $virtual_machine_data->{'provisioning_agreement_account'}->id,
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
                                                    => 1,
                                                duration
                                                    => $duration_total
                                            },
                                        provisioning_obligation_bind
                                            => 1,
                                        now
                                            => $now
                                    )
                            )
                        ] } } )
                        ->filter_validated(now => $now, mask => 0b000111)
                        ->single;
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

                $db_schema->storage->txn_commit;
            }

            # Processing volume's usage records

            while(my($volume_id, $volume_data) = each(%{ $account_data->{'usage_records'}->{ &UR_T_VOLUME } })) {

                $db_schema->storage->txn_begin;

                $logger->debugf("Processing the usage records of the %s volume",
                    $volume_id
                );

                my $vol_obligations = [];
                my $duration_total = 0;
                my $datetime_base;
                my $resource_type_id = $db_schema
                    ->resultset('ResourceType')
                    ->find_by_full_name(resource_type_full_name => 'volume-a')
                    ->id;

                foreach my $usage_record (@{ $volume_data->{'usage_records'} }) {

                    $logger->debugf("Processing the %s usage record",
                        $usage_record
                    );

                    my $datetime_base_new = $datetime_strp->parse_datetime($usage_record->get_value('/startdate'));
                    $logger->warnf("This usage record's startdate differs from the previous one's")
                        if(defined($datetime_base) && ! DateTime->compare($datetime_base, $datetime_base_new));
                    $datetime_base = $datetime_base_new->clone;
                    
                    $duration_total += my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);

                    my $resources = { $resource_type_id => $usage_record->get_value('/size') };
                    if(my $service_package_id = $spp->detect_service_package(
                        cloudstack_element_type
                            => 'Volume',
                        cloudstack_element_id
                            => $volume_id,
                        resources
                            => $resources,
                        exceed
                            => 1,
                        from
                            => $datetime_base->epoch + $duration_total - $duration,
                        till
                            => $datetime_base->epoch + $duration_total
                    )) {
                        $logger->debugf("The %s service package is detected",
                            $db_schema
                                ->resultset('ServicePackage')
                                ->find($service_package_id)
                                ->short_name
                        );
                    }
                    if(scalar(grep({ $_ > 0 } values(%{ $resources })))) {
                        push(@{ $vol_obligations }, {
                            provisioning_agreement_id
                                => $volume_data->{'provisioning_agreement_account'}->id,
                            service_type_id
                                => $db_schema
                                    ->resultset('ServiceType')
                                    ->find_by_full_name(service_type_full_name => 'vdc.element.vol-a')
                                    ->id,
                            service_level_id
                                => $db_schema
                                    ->resultset('ServiceLevel')
                                    ->filter_validated(now => $now, mask => 0b000111)
                                    ->find({ short_name => 'basic' })
                                    ->id,
                            quantity
                                => $resources->{ $resource_type_id },
                            duration
                                => $duration
                        });
                    }
                }

                $db_schema
                    ->resultset('ResourcePiece')
                    ->update_when_needed(
                        parent_resource_piece_id
                            => $volume_data->{'resource_piece_account'}->id,
                        resource_type_id
                            => $resource_type_id,
                        resource_set_id
                            => $resource_set_id,
                        resource_handle
                            => $volume_id,
                        provisioning_obligation_update
                            => $vol_obligations,
                        provisioning_obligation_bind
                            => 1,
                        now
                            => $now
                    );

                $db_schema->storage->txn_commit;
            }

            # Processing IP-addresses' usage records

            while(my($ipaddress_id, $ipaddress_data) = each(%{ $account_data->{'usage_records'}->{ &UR_T_IPADDRESS } })) {

                $db_schema->storage->txn_begin;

                $logger->debugf("Processing the usage records of the %s IP-address",
                    $ipaddress_id
                );

                my $ipv4_obligations = [];
                my $duration_total = 0;
                my $datetime_base;
                my $resource_type_id = $db_schema
                    ->resultset('ResourceType')
                    ->find_by_full_name(resource_type_full_name => 'ipv4-a')
                    ->id;

                foreach my $usage_record (@{ $ipaddress_data->{'usage_records'} }) {

                    $logger->debugf("Processing the %s usage record",
                        $usage_record
                    );

                    my $datetime_base_new = $datetime_strp->parse_datetime($usage_record->get_value('/startdate'));
                    $logger->warnf("This usage record's startdate differs from the previous one's")
                        if(defined($datetime_base) && ! DateTime->compare($datetime_base, $datetime_base_new));
                    $datetime_base = $datetime_base_new->clone;
                    
                    $duration_total += my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);

                    my $resources = { $resource_type_id => 1 };
                    if(my $service_package_id = $spp->detect_service_package(
                        cloudstack_element_type
                            => 'Ipaddress',
                        cloudstack_element_id
                            => $ipaddress_id,
                        resources
                            => $resources,
                        exceed
                            => 1,
                        from
                            => $datetime_base->epoch + $duration_total - $duration,
                        till
                            => $datetime_base->epoch + $duration_total
                    )) {
                        $logger->debugf("The %s service package is detected",
                            $db_schema
                                ->resultset('ServicePackage')
                                ->find($service_package_id)
                                ->short_name
                        );
                    }
                    if(scalar(grep({ $_ > 0 } values(%{ $resources })))) {
                        push(@{ $ipv4_obligations }, {
                            provisioning_agreement_id
                                => $ipaddress_data->{'provisioning_agreement_account'}->id,
                            service_type_id
                                => $db_schema
                                    ->resultset('ServiceType')
                                    ->find_by_full_name(service_type_full_name => 'vdc.element.ipv4-a')
                                    ->id,
                            service_level_id
                                => $db_schema
                                    ->resultset('ServiceLevel')
                                    ->filter_validated(now => $now, mask => 0b000111)
                                    ->find({ short_name => 'basic' })
                                    ->id,
                            quantity
                                => $resources->{ $resource_type_id },
                            duration
                                => $duration
                        });
                    }
                }

                $db_schema
                    ->resultset('ResourcePiece')
                    ->update_when_needed(
                        parent_resource_piece_id
                            => $ipaddress_data->{'resource_piece_account'}->id,
                        resource_type_id
                            => $resource_type_id,
                        resource_set_id
                            => $resource_set_id,
                        resource_handle
                            => $ipaddress_id,
                        provisioning_obligation_update
                            => $ipv4_obligations,
                        provisioning_obligation_bind
                            => 1,
                        now
                            => $now
                    );

                $db_schema->storage->txn_commit;
            }

        }

    }
}
