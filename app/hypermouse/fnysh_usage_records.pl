#!/usr/bin/env perl




package ServicePackageFinder;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use Method::Signatures;



has 'cache' => (
    required    => 1,
    is          => 'ro',
    isa         => 'Cache::Memcached',
    reader      => 'get_cache'
);

has 'hypermouse_schema' => (
    required    => 1,
    is          => 'ro',
    isa         => 'HyperMouse::Schema',
    reader      => 'get_hypermouse_schema'
);

has 'cloudstack_api' => (
    required    => 1,
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      => 'get_cloudstack_api'
);

has 'resources' => (
    required    => 0,
    init_arg    => undef,
    is          => 'ro',
    isa         => 'HashRef',
    reader      => 'get_resources',
    default     => sub { { } }
);



method check_element (
    Str :$cloudstack_element_type!,
    Str :$cloudstack_element_id!,
    Str :$cloudstack_element_key?
            = $self->compose_element_key($cloudstack_element_type, $cloudstack_element_id)
) {
    my $cloudstack_element_dom = $self->renew_if_needed($cloudstack_element_type => $cloudstack_element_id);
    unless(defined($self->get_resources->{ $cloudstack_element_key })) {
        if($cloudstack_element_dom->findvalue('/virtualmachine/tags[key="billing-legacy"]/value')) {
            $self->get_resources->{ $cloudstack_element_key } = {
                cloudstack_element_type
                    => $cloudstack_element_type,
                cloudstack_element_id
                    => $cloudstack_element_id,
                service_package_id
                    => undef,
                service_package_hint
                    => $cloudstack_element_dom->findvalue('/virtualmachine/tags[key="billing-plan"]/value'),
                available
                    => {}
            };
            return(1);
        }
    }
    return(0);
}

#method consume_resources (
#    Str :$cloudstack_element_type!,
#    Str :$cloudstack_element_id!,
#    Int :$resource_type_id!,
#    Int :$quantity
#) {
#    my $cloudstack_element_key = $self->compose_element_key($cloudstack_element_type, $cloudstack_element_id);
#    my $available = $self->get_resources->{ $cloudstack_element_key }->{'available'};
#    unless(defined($available->{ $resource_type_id })) {
#        $available->{'resource_type_id'} = 0;
#    }
#    return($available->{ $resource_type_id } -= $quantity);
#}

method detect_service_package (
    Str     :$cloudstack_element_type!,
    Str     :$cloudstack_element_id!,
    Str     :$cloudstack_element_key?
                = $self->compose_element_key($cloudstack_element_type, $cloudstack_element_id),
    HashRef :$resources!,
    Int     :$since?,
    Int     :$till?
) {
    my $service_package_set_criterions = [];
    while(my($resource_type_id, $quantity) = each(%{ $resources })) {
        push(@{ $service_package_set_criterions }, {
            service_package_id  => {
                -in =>
                    $self->get_hypermouse_schema
                        ->resultset('ServicePackageSet')
                        ->search({
                            resource_type_id    => $resource_type_id,
                            quantity            => $quantity
                        })
                        ->get_column('service_package_id')
                        ->as_query
            }
        });
    }
    my $service_package_set = $self->get_hypermouse_schema
        ->resultset('ServicePackageSet')
        ->search(
            { -and      => $service_package_set_criterions },
            { group_by  => 'service_package_id' }, 
        )
        ->single
        // return(undef);
    my $service_package = $service_package_set->service_package
        // return(undef);
    # OK, the package is detected!
    foreach (
        $service_package
            ->service_package_sets
            ->all
    ) {
        $self->resources_add(
            cloudstack_element_type => $cloudstack_element_type,
            cloudstack_element_id   => $cloudstack_element_id,
            resources               => { $_->resource_type_id => $_->quantity },
            since                   => $since,
            till                    => $till
        );
    }
    while(my($resource_type_id, $quantity) = each(%{ $resources })) {
        $self->resources_sub(
            cloudstack_element_type => $cloudstack_element_type,
            cloudstack_element_id   => $cloudstack_element_id,
            resources               => { $resource_type_id => $quantity },
            since                   => $since,
            till                    => $till
        );
    }
    return($self->get_resources->{ $cloudstack_element_key }->{'service_package_id'} = $service_package->id);
}

method resources_add(
    Str     :$cloudstack_element_type!,
    Str     :$cloudstack_element_id!,
    Str     :$cloudstack_element_key?
                = $self->compose_element_key($cloudstack_element_type, $cloudstack_element_id),
    HashRef :$resources,
    Int     :$since?,
    Int     :$till?
) {
    while(my($resource_type_id, $quantity) = each(%{ $resources })) {
        if( $self->get_resources->{'_available'}->{ $resource_type_id } ) {
            $self->get_resources->{'_available'}->{ $resource_type_id } += $quantity;
        } else {
            $self->get_resources->{'_available'}->{ $resource_type_id }  = $quantity;
        }
    }
}

method resources_sub(HashRef :$resources, ...) {
    my $i = 0;
    $self->resources_add(@_, resources => {
        map({ $_ = ($i++ % 2) ? 0 - $_ : $_; } each(%{ $resources }))
    })
}

method compose_element_key (
    Str $element_type!,
    Str $element_id!
) {
    return(sprintf('%s:%s', $element_type, $element_id));
}

method renew_if_needed (
    Str $element_type!,
    Str $element_id!,
    Str $element_key?
        = $self->compose_element_key($element_type, $element_id)
) {
    my $cache           = $self->get_cache;
    my $cloudstack_api  = $self->get_cloudstack_api;
    my $element_dom     = $cache->get($element_key);
    unless(defined($element_dom)) {
        $element_dom = ($cloudstack_api->perform_action(
            action          => 'list',
            type            => $element_type,
            parameters      => { filter_by_id => $element_id, all => 1 },
            requested       => { element => 'dom' }
        ))[$[];
        $cache->set($element_key, $element_dom, 86400);
    }
    return($element_dom);
}



__PACKAGE__->meta->make_immutable;

1;



package main;

use strict;
use warnings;

use constant UR_T_VIRTUALMACHINE    => 2;
use constant UR_T_IPADDRESS         => 3;
use constant UR_T_VOLUME            => 6;

use ServicePackageFinder;

use MonkeyMan;
use MonkeyMan::Exception qw(
    BadUsageRecord
);

use DateTime;
use XML::LibXML;
use Cache::Memcached;



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
        [opt]       ... #TODO: describe
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
load-usage-records=s:
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
                    location => $parameters->get_load_usage_records
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
                        "The domainid isn't defined in the %s usage record",
                        $usage_record
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
                        "The accountid isn't defined in the %s usage record",
                        $usage_record
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
                        service_package_finder
                            => ServicePackageFinder->new(
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
                my $usage_record_id
                    = $usage_record->get_value('/usageid')
                    // (__PACKAGE__ . '::Exception::BadUsageRecord')->throwf(
                        "The usage record's ID isn't defined in the %s usage record",
                        $usage_record
                    );

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

            my $spf = $account_data->{'service_package_finder'};

            while(my($virtual_machine_id, $virtual_machine_data) = each(%{ $account_data->{'usage_records'}->{ &UR_T_VIRTUALMACHINE } })) {

                $db_schema->storage->txn_begin;

                $logger->debugf("Proceesing the usage records of the %s virtual machine",
                    $virtual_machine_id
                );

                my $billing_legacy = $spf->check_element(
                    cloudstack_element_type
                        => 'VirtualMachine',
                    cloudstack_element_id
                        => $virtual_machine_id,
                );

                my $cpu_obligations = [];
                my $ram_obligations = [];
                my $duration_total = 0;

                foreach my $usage_record (@{ $virtual_machine_data->{'usage_records'} }) {

                    $logger->debugf("Processing the %s usage record",
                        $usage_record
                    );

                    $duration_total += my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);

                    my $cpu = $usage_record->get_value('/cpunumber');
                    my $ram = $usage_record->get_value('/memory');

                    if($billing_legacy && (my $detected = $spf->detect_service_package(
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
                        since
                            => $duration_total - $duration,
                        till
                            => $duration_total
                    ))) {
                        $logger->debugf("The %s service package has been detected",
                            $db_schema
                                ->resultset('ServicePackage')
                                ->find({ id => $detected })
                                ->short_name
                        );
                        $logger->debugf("The resources consumed are: %s", $spf->get_resources);
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

            while(my($volume_id, $volume_data) = each(%{ $account_data->{'usage_records'}->{ &UR_T_VOLUME } })) {

                $db_schema->storage->txn_begin;

                $logger->debugf("Proceesing the usage records of the %s volume",
                    $volume_id
                );

                my $vol_obligations = [];
                my $duration_total = 0;

                foreach my $usage_record (@{ $volume_data->{'usage_records'} }) {

                    $logger->debugf("Processing the %s usage record",
                        $usage_record
                    );

                    $duration_total += my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);
                    if(defined(my $size = $usage_record->get_value('/size'))) {
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
                                => $size,
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
                            => $db_schema
                                ->resultset('ResourceType')
                                ->find_by_full_name(resource_type_full_name => 'volume-a')
                                ->id,
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

            while(my($ipaddress_id, $ipaddress_data) = each(%{ $account_data->{'usage_records'}->{ &UR_T_IPADDRESS } })) {

                $db_schema->storage->txn_begin;

                $logger->debugf("Proceesing the usage records of the %s IP-address",
                    $ipaddress_id
                );

                my $ipv4_obligations = [];
                my $duration_total = 0;

                foreach my $usage_record (@{ $ipaddress_data->{'usage_records'} }) {

                    $logger->debugf("Processing the %s usage record",
                        $usage_record
                    );

                    $duration_total += my $duration = sprintf('%.0f', $usage_record->get_value('/rawusage') * 3600);
                    if(defined(my $size = $usage_record->get_value('/usageid'))) {
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
                                => 1,
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
                            => $db_schema
                                ->resultset('ResourceType')
                                ->find_by_full_name(resource_type_full_name => 'ipv4-a')
                                ->id,
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
