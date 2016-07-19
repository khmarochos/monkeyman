#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin;
use lib("$FindBin::Bin/../../lib");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Constants qw(:version);
use MonkeyMan::Exception;

# Use some third-party libraries
use Method::Signatures;
use File::Basename;
use Term::ReadKey;
use Lingua::EN::Inflect qw(PL);



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'deploy_vm.pl',
    app_description     => 'Deploys virtual machines',
    app_version         => '0.1.0',
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    --name <name>
        [opt]       The virtual macine's name
    --display-name <name>
        [opt]       The virtual macine's display name

    --zone-name <name>
        [req*]      The zone's name
    --zone-id <id>
        [req*]      The zone's ID
  * It's required to define at least one of them (but only one).

    --template-name <name>
        [req*,**]   The template's name
    --template-id <id>
        [req*,**]   The template's ID
  * Alternatively, you can choose an ISO instead of a template.
 ** It's required to define at least one of them (but only one).

    --iso-name <name>
        [req*,**]   The ISO's name
    --iso-id <id>
        [req*,**]   The ISO's ID
  * Alternatively, you can choose a template instead of an ISO.
 ** It's required to define at least one of them (but only one).

    --hypervisor-type <type>
        [opt*]      The hypervisor's type
  * May be required if not defined for the template or the ISO.

    --service-offering-name <name>
        [req*]      The service offering's name
    --service-offering-id <id>
        [req*]      The service offering's ID
    --cpu-cores <number>
        [opt**]     The number of CPUs (in MHz)
    --cpu-speed <number>
        [opt**]     The CPUs' speed
    --ram-size <number>
        [opt**]     The quantity of RAM (in MB)
  * It's required to define at least one of them (but only one).
 ** This option requires a custom-sized service offering to be selected.

    --root-disk-offering-name <name>
        [opt*,**] The root disk's offering's name
    --root-disk-offering-id <id>
        [opt*,**] The root disk's offering's ID
    --root-disk-size <size>
        [opt*,**]   The root disk's size (GB)
  * You can configure either a root disk or a data disk (not both of them).
 ** You can set only 1 of these 2 parameters.
*** This option requires a custom-sized disk offering to be selected.

    --data-disk-offering-name <name>
        [opt**,***] The data disk's offering's name
    --data-disk-offering-id <id>
        [opt**,***] The data disk's offering's ID
    --data-disk-size <size>
        [opt*,**]   The data disk's size (GB)
  * This option requires a custom-sized disk offering to be selected.
 ** You can configure either a root disk or a data disk (not both of them).
*** You can set only 1 of these 2 parameters.

    --network-names <name1> <name2> ... <nameN>
        [opt*] [mul] The list of networks' names
    --network-ids <id1> <id2> ... <idN>
        [opt*] [mul] The list of networks' IDs
  * You can set only 1 of these 2 parameters.

    --ipv4-addresses <address1> <address2> ... <addressN>
        [opt] [mul] The list of IPv4-addresses in the order of the networks
    --ipv6-addresses <address1> <address2> ... <addressN>
        [opt] [mul] The list of IPv6-addresses in the order of the networks

    --domain-name <name>
        [opt*]      The domain's full name and path (includung "ROOT")
    --domain-name-short <name>
        [opt*]      The domain's short name (the last chunk)
    --domain-id <id>
        [opt*]      The domain's ID
  * You can set only 1 of these 3 parameters.

    --account-name <name>
        [opt*]      The account's name
    --account-id <id>
        [opt*]      The account's ID
  * One of these is required if the domain is choosen (you can set only one).

    --host-name <name>
        [opt*]      The deployment host's name
    --host-id <id>
        [opt*]      The deployment host's ID
  * You can set only 1 of these 2 parameters.
__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
---
name=s:
  name:
display-name=s:
  display_name:
zone-name=s:
  zone_name:
    conflicts_any:
      - zone_id
zone-id=s:
  zone_id:
    conflicts_any:
      - zone_name
template-name=s:
  template_name:
    conflicts_any:
      - template_id
      - iso_id
      - iso_name
template-id=s:
  template_id:
    conflicts_any:
      - template_name
      - iso_id
      - iso_name
iso-name=s:
  iso_name:
    requires_any:
      - root_disk_offering_id
      - root_disk_offering_name
    conflicts_any:
      - iso_id
      - template_id
      - template_name
iso-id=s:
  iso_id:
    requires_any:
      - root_disk_offering_id
      - root_disk_offering_name
    conflicts_any:
      - iso_name
      - template_id
      - template_name
hypervisor-type=s:
  hypervisor_type:
service-offering-name=s:
  service_offering_name:
    conflicts_any:
      - service_offering_id
service-offering-id=s:
  service_offering_id:
    conflicts_any:
      - service_offering_name
cpu-cores=i:
  cpu_cores:
    requires_each:
      - cpu_speed
      - ram_size
cpu-speed=i:
  cpu_speed:
    requires_each:
      - cpu_cores
      - ram_size
ram-size=i:
  ram_size:
    requires_each:
      - cpu_cores
      - cpu_speed
root-disk-offering-name=s:
  root_disk_offering_name:
    conflicts_any:
      - root_disk_offering_id
    requires_any:
      - iso_id
      - iso_name
root-disk-offering-id=s:
  root_disk_offering_id:
    conflicts_any:
      - root_disk_offering_name
    requires_any:
      - iso_id
      - iso_name
root-disk-size=i:
  root_disk_size:
    requires_any:
      - root_disk_offering_name
      - root_disk_offering_id
data-disk-offering-name=s:
  data_disk_offering_name:
    conflicts_any:
      - data_disk_offering_id
    requires_any:
      - template_id
      - template_name
data-disk-offering-id=s:
  data_disk_offering_id:
    conflicts_any:
      - data_disk_offering_name
    requires_any:
      - template_id
      - template_name
data-disk-size=i:
  data_disk_size:
    requires_any:
      - data_disk_offering_name
      - data_disk_offering_id
networks-names=s\@:
  networks_names:
    conflicts_any:
      - networks_ids
networks-ids=s\@:
  networks_ids:
    conflicts_any:
      - networks_names
ipv4-addresses=s\@:
  ipv4_addresses:
    requires_any:
      - networks_names
      - networks_ids
ipv6-addresses=s\@:
  ipv6_addresses:
    requires_any:
      - networks_names
      - networks_ids
domain-name=s:
  domain_name:
    requires_any:
      - account_id
      - account_name
    conflicts_any:
      - domain_id
      - domain_name_short
domain-name-short=s:
  domain_name_short:
    requires_any:
      - account_id
      - account_name
    conflicts_any:
      - domain_id
      - domain_name
domain-id=s:
  domain_id:
    requires_any:
      - account_id
      - account_name
    conflicts_any:
      - create_domain
      - domain_name
      - domain_name_short
account-name=s:
  account_name:
    requires_any:
      - domain_name
      - domain_id
account-id=s:
  account_id:
    requires_any:
      - domain_name
      - domain_id
host-name=s:
  host_name:
    conflicts_any:
      - host_id
host-id=s:
  host_id:
    conflicts_any:
      - host_name
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;

my %deployment_parameters;  # The parameters to be given to the deployment method
my %elements_found;         # The references to the elements found are to be kept here

#
# Setting names
#

$deployment_parameters{'name'} = $monkeyman->get_parameters->get_name
    if($monkeyman->get_parameters->has_name);
$deployment_parameters{'displayname'} = $monkeyman->get_parameters->get_display_name
    if($monkeyman->get_parameters->has_display_name);

#
# Finding all the elements that have been mentioned by their names or ID
#

my $what_is_what = {
    'zone'              => {
        type                => 'Zone',
        number              => 1,
        mandatory           => 1,
        results             => { zoneid => { query => '/id' } },
        parameters_fixed    => { available => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'zone_id' },
            filter_by_name          => { from_parameters => 'zone_name' }
        }
    },
    'template'          => {
        type                => 'Template',
        number              => 2,
        mandatory           => 0,
        results             => { templateid => { query => '/id' } },
        parameters_fixed    => { all => 'true', filter_by_type => 'executable' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'template_id' },
            filter_by_name          => { from_parameters => 'template_name' },
            filter_by_zoneid        => { from_results => 'zoneid' }
        }
    },
    'ISO'          => {
        type                => 'ISO',
        number              => 3,
        mandatory           => 0,
        results             => { templateid => { query => '/id' } },
        parameters_fixed    => { all => 'true', filter_by_type => 'executable' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'iso_id' },
            filter_by_name          => { from_parameters => 'iso_name' },
            filter_by_zoneid        => { from_results => 'zoneid' }
        }
    },
    'service offering'  => {
        type                => 'ServiceOffering',
        number              => 4,
        mandatory           => 1,
        results             => { serviceofferingid => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'service_offering_id' },
            filter_by_name          => { from_parameters => 'service_offering_name' }
        }
    },
    'root disk offering'  => {
        type                => 'DiskOffering',
        number              => 5,
        mandatory           => 0,
        results             => { diskofferingid => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'root_disk_offering_id' },
            filter_by_name          => { from_parameters => 'root_disk_offering_name' }
        }
    },
    'data disk offering'  => {
        type                => 'DiskOffering',
        number              => 6,
        mandatory           => 0,
        results             => { diskofferingid => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'data_disk_offering_id' },
            filter_by_name          => { from_parameters => 'data_disk_offering_name' }
        }
    },
    'network'          => {
        type                => 'Network',
        number              => 7,
        mandatory           => 0,
        ref                 => 'ARRAY', # There'll be multiple networks to be found!
        results             => { _networks => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'networks_ids' },
            filter_by_name          => { from_parameters => 'networks_names' }
        }
    },
    'domain'            => {
        type                => 'Domain',
        number              => 8,
        mandatory           => 0,
        results             => { domainid => { query => '/id' } },
        parameters_fixed    => { all => 'true', filter_by_type => 'executable' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'domain_id' },
            filter_by_path          => { from_parameters => 'domain_name' },
            filter_by_name          => { from_parameters => 'domain_name_short'}
        }
    },
    'account'            => {
        type                => 'Account',
        number              => 9,
        mandatory           => 0,
        results             => { account => { query => '/name' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'account_id' },
            filter_by_name          => { from_parameters => 'account_name' },
            filter_by_domainid      => { from_results => 'domainid' }
        }
    },
    'host'            => {
        type                => 'Host',
        number              => 10,
        mandatory           => 0,
        results             => { hostid => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'host_id' },
            filter_by_name          => { from_parameters => 'host_name' },
            filter_by_zoneid        => { from_results => 'zoneid' }
        }
    }
};

foreach my $huerga_name (
    sort(
        {
            # We need to have it sorted, because certain parameters need some
            # other parameters to have been proceeded beforehand. For example,
            # the "account" parametr that is depentant on the "domain" one.
            $what_is_what->{$a}->{'number'} <=> $what_is_what->{$b}->{'number'}
        }
        keys(%{ $what_is_what })
    )
) {

    # We've got the key, now let's get the value...
    my $huerga_configuration = $what_is_what->{$huerga_name};

    $logger->tracef(
        "Selecting the %s desired (as defined in %s)",
        $huerga_name,
        $huerga_configuration
    );

    # Later we'll need to know what exactly search criterions had been really set
    my %huerga_desired;

    # Now let's define the hash that will be passed to the perform_action() method,
    # it shall contain all the search criterions for the huerga we proceed.
    my %action_parameters = ref($huerga_configuration->{'parameters_fixed'}) eq 'HASH' ?
        (%{ $huerga_configuration->{'parameters_fixed'} }) :
        ();

    # Is this huerga choosen by the operator?
    my $huerga_choosen = 0;
    # What variable parameters do we have for this huerga?
    foreach my $action_parameter_name (keys(%{ $huerga_configuration->{'parameters_variable'} })) {

        # The value will be needed later
        my $action_parameter_configuration = $huerga_configuration->{'parameters_variable'}->{$action_parameter_name};

        my $source;
        my $value;
        if(($source = $action_parameter_configuration->{'from_results'}) && defined($source)) {
            # The parameter's value needs to be fetched from the results that have been already got
            $value = $deployment_parameters{ $source };
        } elsif(($source = $action_parameter_configuration->{'from_parameters'}) && defined($source)) {
            # The parameter's value needs to be fetched from the command-line paramters
            my $predicate = 'has_' . $source;
            my $reader    = 'get_' . $source;
            if($monkeyman->get_parameters->$predicate) {
                $value = $monkeyman->get_parameters->$reader;
                $huerga_choosen++; # This huerga has been choosen by the operator!
            }
        }
        if(defined($value)) {
            if(ref($value) eq 'ARRAY') {
                $huerga_desired{$action_parameter_name} = $value;
            } else {
                $huerga_desired{$action_parameter_name} = [ $value ];
            }
        }
    }

    $logger->tracef(
        "We're ready to perform list-getting actions to find the following element(s): %s",
        \%huerga_desired
    );

    if(
        # So, have we got any command-line parameters about this huerga?
        ($huerga_choosen && (my @action_parameters_names = keys(%huerga_desired))) ||
        # Or shall it be proceeded even without the command-line parameters given?
        ($huerga_configuration->{'forced'})
    ) {

        my @action_parameters_sets = ();

        # It's a recursive subrouting that is generating all possible combinations of the parameters.
        generate_parameters(
            parameters_input    => \%huerga_desired,
            parameters_names    => \@action_parameters_names,
            parameters_output   => \@action_parameters_sets
        );

        $logger->tracef(
            "The following list of parameters' sets are needed to be proceeded: %s",
            \@action_parameters_sets
        );

        # There can be multiple parameters sets (for example, in the case when the operator defined multiple networks),
        # so we're going to fetch them all
        foreach my $action_parameters_set (@action_parameters_sets) {

            # OK, let's perform the action
            my @huerga_found = $api->perform_action(
                type        => $huerga_configuration->{'type'},
                action      => 'list',
                parameters  => { %action_parameters, %{ $action_parameters_set } },
                requested   => { element => 'element' }
            );

            # How much huerga have we found?
            if(@huerga_found < 1) {
                # Too little (less than 1 element)
                MonkeyMan::Exception->throwf(
                    "The %s desired (%s) has not been found",
                    $huerga_name, join(', ', map({ sprintf("%s: %s", $_, $huerga_desired{$_})} keys(%huerga_desired)))
                );
            } elsif(@huerga_found > 1) {
                # Too much (more than 1 element)
                MonkeyMan::Exception->throwf(
                    "Too many %s have been found, their IDs are: %s",
                    PL($huerga_name), join(', ', map({ $_->get_id } @huerga_found))
                );
            } else {
                # Perfect! :)
                my $huerga_selected = $huerga_found[0];
                $logger->debugf(
                    "The %s %s has been found, its ID is: %s",
                    $huerga_selected,
                    $huerga_name,
                    $huerga_selected->get_id
                );
                foreach my $deployment_parameter (keys(%{ $huerga_configuration->{'results'} })) {
                    if(defined(my $query = $huerga_configuration->{'results'}->{$deployment_parameter}->{'query'})) {
                        my @results = $huerga_selected->qxp(
                            query       => $query,
                            return_as   => 'value'
                        );
                        if(@results < 1) {
                            MonkeyMan::Exception->throwf("Expected a result, have got none");
                        } elsif(@results > 1) {
                            MonkeyMan::Exception->throwf("Expected a result, have got too many");
                        } else {
                            if(defined($huerga_configuration->{'ref'}) && $huerga_configuration->{'ref'} eq 'ARRAY') {
                                # If we need to get multiple elements, we'll put it
                                # to an array referenced from the $deployment_parameters hash
                                unless(defined($deployment_parameters{$deployment_parameter})) {
                                    # If it hasn't been initialized yet
                                    $deployment_parameters{$deployment_parameter} = [ $results[0] ];
                                } else {
                                    # Otherwise, we'll push the new element
                                    push(@{ $deployment_parameters{$deployment_parameter} }, $results[0]);
                                }
                            } else {
                                # If we need to get only one element, we'll simply put it
                                # to the $deployment_parameters hash as a scalar value
                                $deployment_parameters{$deployment_parameter} = $results[0];
                            }
                        }
                    }
                }
            }

        }

    } elsif($huerga_configuration->{'mandatory'}) {
        MonkeyMan::Exception->throwf("The %s (a required parameter) hasn't been choosen");
    }

}

#
# Dealing with custom offerings
#

$deployment_parameters{'size'} = $monkeyman->get_parameters->get_root_disk_size
    if($monkeyman->get_parameters->has_root_disk_size);
$deployment_parameters{'size'} = $monkeyman->get_parameters->get_data_disk_size
    if($monkeyman->get_parameters->has_data_disk_size);
$deployment_parameters{'details[0].cpuNumber'} = $monkeyman->get_parameters->get_cpu_cores
    if($monkeyman->get_parameters->has_cpu_cores);
$deployment_parameters{'details[0].cpuSpeed'} = $monkeyman->get_parameters->get_cpu_speed
    if($monkeyman->get_parameters->has_cpu_speed);
$deployment_parameters{'details[0].memory'} = $monkeyman->get_parameters->get_ram_size
    if($monkeyman->get_parameters->has_ram_size);

#
# It's required
#

$deployment_parameters{'hypervisor'} = $monkeyman->get_parameters->get_hypervisor_type
    if($monkeyman->get_parameters->has_hypervisor_type);


#
# Dealing with networks and IP-addresses
#

my @networks_ids = (
    defined($deployment_parameters{'_networks'}) &&
        ref($deployment_parameters{'_networks'}) eq 'ARRAY'
) ? @{ $deployment_parameters{'_networks'} } : ( );
# Getting rid of a temporary parameter
delete($deployment_parameters{'_networks'})
    if(@networks_ids);
my @ipv4_addresses = (
           ($monkeyman->get_parameters->has_ipv4_addresses) &&
    defined($monkeyman->get_parameters->get_ipv4_addresses) &&
        ref($monkeyman->get_parameters->get_ipv4_addresses) eq 'ARRAY'
) ? @{ $monkeyman->get_parameters->get_ipv4_addresses } : ();
my @ipv6_addresses = (
           ($monkeyman->get_parameters->has_ipv6_addresses) &&
    defined($monkeyman->get_parameters->get_ipv6_addresses) &&
        ref($monkeyman->get_parameters->get_ipv6_addresses) eq 'ARRAY'
) ? @{ $monkeyman->get_parameters->get_ipv6_addresses } : ();
if(@ipv4_addresses || @ipv6_addresses) {
    if(
        (@ipv4_addresses != @networks_ids) ||
        (@ipv6_addresses != @networks_ids)
    ) {
        MonkeyMan::Exception->throwf(
            "The quanttity of the IP-addresses (IPv4: %s; IPv6: %s) doesn't match the quantity of the networks (%s)",
            join(', ', @ipv4_addresses  ? @ipv4_addresses   : qw(-)),
            join(', ', @ipv6_addresses  ? @ipv6_addresses   : qw(-)),
            join(', ', @networks_ids    ? @networks_ids     : qw(-))
        );
    }
    for(my $i = 0; $i < @networks_ids; $i++) {
        $deployment_parameters{"iptonetworklist[$i].networkid"} = $networks_ids[$i];
        $deployment_parameters{"iptonetworklist[$i].ip"}        = $ipv4_addresses[$i]
            if(defined($ipv4_addresses[$i]) && $ipv4_addresses[$i] !~ /auto/i);
        $deployment_parameters{"iptonetworklist[$i].ipv6"}      = $ipv6_addresses[$i]
            if(defined($ipv6_addresses[$i]) && $ipv6_addresses[$i] !~ /auto/i);
    }
} elsif(@networks_ids) {
    @deployment_parameters{'networkids'} = join(' ', @networks_ids);
}




#
# Deploying a VM
#

$logger->debugf(
    "Going to deploy a virtual machine, " .
    "the following parameters' set is to be used: %s",
    \%deployment_parameters
);

$deployment_parameters{'command'} = 'deployVirtualMachine';
my $result = $api->run_command(
    parameters  => \%deployment_parameters,
    wait        => 300,
    fatal_empty => 1,
    fatal_fail  => 1
);



#
# That's all!
#

printf("The virtual machine's ID is %s\n", $result->findvalue('/queryasyncjobresultresponse/jobresult/virtualmachine/id'));

exit;




func generate_parameters (
    HashRef     :$parameters_input!,
    ArrayRef    :$parameters_names!,
    ArrayRef    :$parameters_output!,
    HashRef     :$state = {},
    Int         :$depth = 0
) {
    my $current_parameter_name = $parameters_names->[$depth];
    foreach my $current_parameter_value (@{ $parameters_input->{$current_parameter_name} }) {
        $state->{$current_parameter_name} = $current_parameter_value;
        if($depth < @{ $parameters_names } - 1) {
            generate_parameters(
                parameters_input    => $parameters_input,
                parameters_names    => $parameters_names,
                parameters_output   => $parameters_output,
                state               => $state,
                depth               => $depth + 1
            );
        } else {
            push(@{ $parameters_output }, { %{ $state } });
        }
    }
}
