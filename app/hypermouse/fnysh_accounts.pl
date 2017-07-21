#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Exception qw(
    .
    NoParentDomains
    MultipleParentDomains
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

    --parent-domain-name-full <name>
        [req*][mul] The parent domain's full path (includung "ROOT")
    --parent-domain-name-short <name>
        [req*][mul] The parent domain's short name (the last chunk)
    --parent-domain-id <id>
        [req*][mul]   The parent domain's ID
  * These parameters are available for the CloudStack mode only, it's
    mandatory to set at least one of them if the mode is choosen
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
parent-domain-name-full=s@:
  parent_domain_name_full:
parent-domain-name-short=s@:
  parent_domain_name_short:
parent-domain-id=s@:
  parent_domain_id:
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $parameters      = $monkeyman->get_parameters;
my $logger          = $monkeyman->get_logger;
my $hypermouse      = $monkeyman->get_hypermouse;
my $db_schema       = $hypermouse->get_schema;
my $now             = DateTime->now;



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

        $logger->debugf("Processing the %s CloudStack as the %s resource group",
            $cloudstack_handle,
            $resource_set
        );

        my @parent_domains_found;

        if(defined($parameters->get_parent_domain_id)) {
            foreach my $parent_domain_id (@{ $parameters->get_parent_domain_id }) {
                push(@parent_domains_found, $cloudstack_api->perform_action(
                    type        => 'Domain',
                    action      => 'list',
                    parameters  => { filter_by_id => $parent_domain_id },
                    requested   => { element => 'element' }
                ))
                    || $logger->warnf("The domain with the %s ID isn't recognized",
                        $parent_domain_id
                    );
            }
        }
        if(defined($parameters->get_parent_domain_name_full)) {
            foreach my $parent_domain_name_name_full (@{ $parameters->get_parent_domain_name_full }) {
                push(@parent_domains_found, $cloudstack_api->perform_action(
                    type        => 'Domain',
                    action      => 'list',
                    parameters  => { filter_by_path_all => $parent_domain_name_name_full },
                    requested   => { element => 'element' }
                ))
                    || $logger->warnf("The domain with the %s full name isn't recognized",
                        $parent_domain_name_name_full
                    );
            }
        }
        if(defined($parameters->get_parent_domain_name_short)) {
            foreach my $parent_domain_name_name_short (@{ $parameters->get_parent_domain_name_name_short }) {
                push(@parent_domains_found, $cloudstack_api->perform_action(
                    type        => 'Domain',
                    action      => 'list',
                    parameters  => { filter_by_name => $parent_domain_name_name_short },
                    requested   => { element => 'element' }
                ))
                    || $logger->warnf("The domain with the %s short name isn't recognized",
                        $parent_domain_name_name_short
                    );
            }
        }

        if(@parent_domains_found < 1) {
            (__PACKAGE__ . '::Exception::NoParentDomains')->throw(
                'No parent domains found'
            );
        }

        foreach my $domain (map({
            my $domain_id = $_->get_id;
            $cloudstack_api->perform_action(
                type        => 'Domain',
                action      => 'list',
                parameters  => {
                    filter_by_id    => $domain_id,
                    all             => 1
                },
                requested   => { element => 'element' },
                best_before => 0
            ),
            $cloudstack_api->perform_action(
                type        => 'Domain',
                action      => 'list_children',
                parameters  => {
                    parent_id       => $domain_id,
                    all             => 1
                },
                requested   => { element => 'element' },
                best_before => 0
            )
        } @parent_domains_found)) {

            $logger->debugf("Have got the %s domain", $domain);
            my $provisioning_agreement_name = (
                $domain->get_value('/name') =~ /^A([0-9]{6,8})$/ && $1
            ) || next;
            my $provisioning_agreement = $db_schema
                ->resultset('ProvisioningAgreement')
                ->search({ name => $provisioning_agreement_name })
                ->filter_validated(mask => 0b000111, now => $now)
                ->single;
            unless(defined($provisioning_agreement)) {
                $logger->infof("Creating the %s provisioning agreement", $provisioning_agreement_name);
                my $contractor_name = sprintf('Default Contractor (%s)', $provisioning_agreement_name);
                my $contractor = $db_schema
                    ->resultset('Contractor')
                    ->search({ name => $contractor_name })
                    ->filter_validated(mask => 0b000111, now => $now)
                    ->single;
                unless(defined($contractor)) {
                    $logger->infof("Creating the %s contractor", $contractor_name);
                    $contractor = $db_schema
                        ->resultset('Contractor')
                        ->create({
                            valid_since             => $now, 
                            valid_till              => undef,
                            removed                 => undef,
                            name                    => $contractor_name,
                            contractor_type_id      => 1 #FIXME
                        });
                };
                $logger->debugf("Have got the %s contractor (%s)",
                    $contractor,
                    $contractor_name
                );
                $provisioning_agreement = $db_schema
                    ->resultset('ProvisioningAgreement')
                    ->create({
                        valid_since             => $now, 
                        valid_till              => undef,
                        removed                 => undef,
                        name                    => $provisioning_agreement_name,
                        provider_contractor_id  => 1,
                        client_contractor_id    => $contractor->id
                    });
            }
            $logger->debugf("Have got the %s provisioning agreement (%s)",
                $provisioning_agreement,
                $provisioning_agreement_name
            );

            $db_schema->txn_begin;

            $db_schema->storage->dbh->trace(0);

            my @resource_pieces = $db_schema
                ->resultset('ResourcePiece')
                ->update_when_needed(
                    parent_resource_piece_id
                        => undef,
                    resource_type_id
                        => $db_schema
                            ->resultset('ResourceType')
                            ->find_by_full_name(resource_type_full_name => 'domain') #FIXME
                            ->id,
                    resource_set_id
                        => $resource_set->id,
                    resource_handle
                        => $domain->get_id,
                    provisioning_obligation_update
                        => {
                            provisioning_agreement_id
                                => $provisioning_agreement->id,
                            service_type_id
                                => $db_schema
                                    ->resultset('ServiceType')
                                    ->find_by_full_name(service_type_full_name => 'vdc.group.domain')
                                    ->id,
                            service_level_id
                                => $db_schema
                                    ->resultset('ServiceLevel')
                                    ->filter_validated(mask => 0b000111, now => $now)
                                    ->find({ short_name => 'basic' })
                                    ->id,
                            quantity
                                => 1
                        },
                    provisioning_obligation_bind
                        => 1,
                    now
                        => $now
                );

            foreach my $account ($domain->get_related(
                related => 'our_accounts',
                fatal   => 0
            )) {

                $logger->debugf("Have got the %s account", $account);

                my @resource_pieces = $db_schema
                    ->resultset('ResourcePiece')
                    ->update_when_needed(
                        parent_resource_piece_id
                            => $resource_pieces[0]->id,
                        resource_type_id
                            => $db_schema
                                ->resultset('ResourceType')
                                ->find_by_full_name(resource_type_full_name => 'account') #FIXME
                                ->id,
                        resource_set_id
                            => $resource_set->id,
                        resource_handle
                            => $account->get_id,
                        provisioning_obligation_update
                            => {
                                provisioning_agreement_id
                                    => $provisioning_agreement->id,
                                service_type_id
                                    => $db_schema
                                        ->resultset('ServiceType')
                                        ->find_by_full_name(service_type_full_name => 'vdc.group.account')
                                        ->id,
                                service_level_id
                                    => $db_schema
                                        ->resultset('ServiceLevel')
                                        ->filter_validated(mask => 0b000111, now => $now)
                                        ->find({ short_name => 'basic' })
                                        ->id,
                                quantity
                                    => 1
                            },
                        provisioning_obligation_bind
                            => 1,
                        now
                            => $now
                    );

            }

            $db_schema->storage->dbh->trace(0);

            $db_schema->txn_commit;

   #        foreach my $virtual_machine ($cloudstack_api->perform_action(
   #            type        => 'VirtualMachine',
   #            action      => 'list',
   #            parameters  => {
   #                filter_by_domain_id => $domain->get_id,
   #                all                 => 1
   #            },
   #            requested   => { element => 'element' },
   #            best_before => 0
   #        )) {
   #            my $resources = {
   #                'vdc.element.cpu'   => $virtual_machine->get_value('/cpunumber'),
   #                'vdc.element.ram'   => $virtual_machine->get_value('/memory'),
   #                'vdc.element.ssd'   => 0,
   #                'ip.ip.ipv4'        => 0
   #            };
   #            $logger->debugf("Found the %s virtual machine", $virtual_machine);
   #            foreach my $volume ($cloudstack_api->perform_action(
   #                type        => 'Volume',
   #                action      => 'list',
   #                parameters  => {
   #                    filter_by_virtual_machine_id    => $virtual_machine->get_id,
   #                    all                             => 1
   #                },
   #                requested   => { element => 'element' },
   #                best_before => 0
   #            )) {
   #                $logger->debugf("Found the %s volume", $volume);
   #                $resources->{'vdc.element.ssd'} += $volume->get_value('size');
   #            }
   #            foreach my $nic ($cloudstack_api->perform_action(
   #                type        => 'Nic',
   #                action      => 'list',
   #                parameters  => {
   #                    filter_by_virtual_machine_id    => $virtual_machine->get_id
   #                },
   #                requested   => { element => 'element' },
   #                best_before => 0
   #            )) {
   #                my @ipv4_addresses = (
   #                    $nic->get_values('/ipaddress'),
   #                    $nic->get_values('/secondaryip/ipaddress')
   #                ); 
   #                $logger->debugf("Found the %s NIC (%s)", $nic, join(', ', @ipv4_addresses));
   #                $resources->{'ip.ip.ipv4'} += scalar(@ipv4_addresses);
   #            }
   #            my $resource_piece = $db_schema
   #                ->resultset('ResourcePiece')
   #                ->search({
   #                    resource_group_id   => $resource_group->id,
   #                    resource_handle     => $virtual_machine->get_id
   #                })
   #                ->filter_validated(mask => 0b000111)
   #                ->single;
   #            unless(defined($resource_piece)) {
   #                $logger->infof("Creating the %s resource piece", $virtual_machine->get_id);
   #                $resource_piece = $db_schema
   #                    ->resultset('ResourcePiece')
   #                    ->create({
   #                        valid_since         => $now,
   #                        valid_till          => undef,
   #                        removed             => undef,
   #                        resource_type_id    => 1, #FIXME
   #                        resource_group_id   => $resource_group->id,
   #                        resource_handle     => $virtual_machine->get_id
   #                    });
   #            }
   #            foreach my $service_type_full_name (keys(%{ $resources })) {
   #                if(defined(my $service_type_id = $db_schema
   #                    ->resultset('ServiceType')
   #                    ->find_by_full_name(service_type_full_name => $service_type_full_name)
   #                )) {
   #                    $db_schema
   #                        ->resultset('ProvisioningObligation')
   #                        ->update_obligations(
   #                            provisioning_agreement  => $provisioning_agreement,
   #                            resource_piece          => $resource_piece,
   #                            service_type_id         => $service_type_id,
   #                            service_level_id        => 1, #FIXME
   #                            quantity                => $resources->{ $service_type_full_name },
   #                            now                     => $now
   #                        );
   #                } else {
   #                    #TODO: send a warning
   #                    next;
   #                }
   #            }
   #        }
       }
    }

} else {

    (__PACKAGE__ . '::Exception')->throwf(
        "The %s mode isn't supported",
        $parameters->get_mode
    );

}
