#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Exception qw(NoParentDomains MultipleParentDomains);

use DateTime;



my $monkeyman       = MonkeyMan->new(
    app_code                    => undef,
    app_name                    => 'contractors_finder',
    app_description             => 'Finds the unregistered contractors',
    app_version                 => '0.0.1',
    app_usage_help              => <<__END_OF_USAGE_HELP__,
This application recognizes the following parameters:

    -u, --update
        [opt]       Update the database
    -e <address>, --email <address>
        [opt] [mul] The email addresses to report to

    --domain-name-full <name>
        [req*]      The parent domain's full path (includung "ROOT")
    --domain-name-short <name>
        [req*]      The parent domain's short name (the last chunk)
    --domain-id <id>
        [req*]      The parent domain's ID
  * You can set only 1 of these 3 parameters, but it's mandatory to set at
    least one of them.
__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
domain-name-full=s:
  domain_name_full:
    conflicts_any:
      - domain_id
      - domain_name_short
domain-name-short=s:
  domain_name_short:
    conflicts_any:
      - domain_id
      - domain_name_full
domain-id=s:
  domain_id:
    conflicts_any:
      - domain_name_full
      - domain_name_short
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $parameters      = $monkeyman->get_parameters;
my $logger          = $monkeyman->get_logger;
my $hypermouse      = $monkeyman->get_hypermouse;
my $db_schema       = $hypermouse->get_schema;
my $now             = DateTime->now;



foreach my $cloudstack_handle (qw(Tucha.Z1 Tucha.Z2)) { #FIXME: Make a parameter

    my $cloudstack      = $monkeyman->get_cloudstack($cloudstack_handle);
    my $cloudstack_api  = $cloudstack->get_api;

    my $resource_group = $db_schema
        ->resultset('ResourceGroup')
        ->search({ name => sprintf("CloudStack %s", $cloudstack_handle) })
        ->filter_validated(mask => 0b000111)
        ->single;
    unless(defined($resource_group)) {
        $logger->warnf(
            "The %s CloudStack couldn't be recognized as a resource group",
            $cloudstack
        );
        next;
    }

    $logger->debugf("Processing the %s cloud as the %s resource group",
        $cloudstack,
        $resource_group
    );

    my @parent_domains_found;

    if(defined($parameters->get_domain_id)) {
        @parent_domains_found = $cloudstack_api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { filter_by_id => $parameters->get_domain_id },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_domain_name_full)) {
        @parent_domains_found = $cloudstack_api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { filter_by_path_all => $parameters->get_domain_name_full },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_domain_name_short)) {
        @parent_domains_found = $cloudstack_api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { filter_by_name => $parameters->get_domain_name_short },
            requested   => { element => 'element' }
        );
    }

    if(@parent_domains_found < 1) {
        (__PACKAGE__ . '::Exception::NoParentDomains')->throw(
            'No parent domains found'
        );
    } elsif(@parent_domains_found > 1) {
        (__PACKAGE__ . '::Exception::MultipleParentDomains')->throwf(
            'More than one parent domains found: %s',
            join(', ', map({ $_->id } @parent_domains_found))
        );
    }

    # 
    foreach my $domain (
        $cloudstack_api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => {
                filter_by_id    => $parent_domains_found[0]->get_id,
                all             => 1
            },
            requested   => { element => 'element' },
            best_before => 0
        ),
        $cloudstack_api->perform_action(
            type        => 'Domain',
            action      => 'list_children',
            parameters  => {
                parent_id       => $parent_domains_found[0]->get_id,
                all             => 1
            },
            requested   => { element => 'element' },
            best_before => 0
        )
    ) {
        $logger->debugf("Found the %s domain", $domain);
        my $provisioning_agreement_name = (
            $domain->get_value('/name') =~ /^A([0-9]{6,8})$/ && $1
        ) || next;
        my $provisioning_agreement = $db_schema
            ->resultset('ProvisioningAgreement')
            ->search({ name => $provisioning_agreement_name })
            ->filter_validated(mask => 0b000111)
            ->single;
        unless(defined($provisioning_agreement)) {
            $logger->infof("Creating the %s provisioning agreement", $provisioning_agreement_name);
            my $contractor_name = sprintf('Default Contractor (%s)', $provisioning_agreement_name);
            my $contractor = $db_schema
                ->resultset('Contractor')
                ->search({ name => $contractor_name })
                ->filter_validated(mask => 0b000111)
                ->single;
            unless(defined($contractor)) {
                $logger->infof("Creating the %s contractor", $contractor_name);
                $contractor = $db_schema
                    ->resultset('Contractor')
                    ->create({
                        valid_from              => $now, 
                        valid_till              => undef,
                        removed                 => undef,
                        name                    => $contractor_name,
                        contractor_type_id      => 1 #FIXME
                    });
            };
            $provisioning_agreement = $db_schema
                ->resultset('ProvisioningAgreement')
                ->create({
                    valid_from              => $now, 
                    valid_till              => undef,
                    removed                 => undef,
                    name                    => $provisioning_agreement_name,
                    provider_contractor_id  => 1,
                    client_contractor_id    => $contractor->id
                });
        }
        $logger->debugf("Found the %s provisioning agreement (%s)",
            $provisioning_agreement,
            $provisioning_agreement_name
        );
        foreach my $virtual_machine ($cloudstack_api->perform_action(
            type        => 'VirtualMachine',
            action      => 'list',
            parameters  => {
                filter_by_domain_id => $domain->get_id,
                all                 => 1
            },
            requested   => { element => 'element' },
            best_before => 0
        )) {
            my $resources = {
                'vdc.element.cpu'   => $virtual_machine->get_value('/cpunumber'),
                'vdc.element.ram'   => $virtual_machine->get_value('/memory'),
                'vdc.element.ssd'   => 0,
                'ip.ip.ipv4'        => 0
            };
            $logger->debugf("Found the %s virtual machine", $virtual_machine);
            foreach my $volume ($cloudstack_api->perform_action(
                type        => 'Volume',
                action      => 'list',
                parameters  => {
                    filter_by_virtual_machine_id    => $virtual_machine->get_id,
                    all                             => 1
                },
                requested   => { element => 'element' },
                best_before => 0
            )) {
                $logger->debugf("Found the %s volume", $volume);
                $resources->{'vdc.element.ssd'} += $volume->get_value('size');
            }
            foreach my $nic ($cloudstack_api->perform_action(
                type        => 'Nic',
                action      => 'list',
                parameters  => {
                    filter_by_virtual_machine_id    => $virtual_machine->get_id
                },
                requested   => { element => 'element' },
                best_before => 0
            )) {
                my @ipv4_addresses = (
                    $nic->get_values('/ipaddress'),
                    $nic->get_values('/secondaryip/ipaddress')
                ); 
                $logger->debugf("Found the %s NIC (%s)", $nic, join(', ', @ipv4_addresses));
                $resources->{'ip.ip.ipv4'} += scalar(@ipv4_addresses);
            }
            my $resource_piece = $db_schema
                ->resultset('ResourcePiece')
                ->search({
                    resource_group_id   => $resource_group->id,
                    resource_handle     => $virtual_machine->get_id
                })
                ->filter_validated(mask => 0b000111)
                ->single;
            unless(defined($resource_piece)) {
                $logger->infof("Creating the %s resource piece", $virtual_machine->get_id);
                $resource_piece = $db_schema
                    ->resultset('ResourcePiece')
                    ->create({
                        valid_from          => $now,
                        valid_till          => undef,
                        removed             => undef,
                        resource_type_id    => 1, #FIXME
                        resource_group_id   => $resource_group->id,
                        resource_handle     => $virtual_machine->get_id
                    });
            }
            foreach my $service_type_full_name (keys(%{ $resources })) {
                if(defined(my $service_type_id = $db_schema
                    ->resultset('ServiceType')
                    ->find_by_full_name(service_type_full_name => $service_type_full_name)
                )) {
                    $db_schema
                        ->resultset('ProvisioningObligation')
                        ->update_obligations(
                            provisioning_agreement  => $provisioning_agreement,
                            resource_piece          => $resource_piece,
                            service_type_id         => $service_type_id,
                            service_level_id        => 1, #FIXME
                            quantity                => $resources->{ $service_type_full_name },
                            now                     => $now
                        );
                } else {
                    #TODO: send a warning
                    next;
                }
            }
        }
    }
}
