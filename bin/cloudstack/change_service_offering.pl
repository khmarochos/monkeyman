#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Use my own modules
use MonkeyMan;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'change_service_offering',
    app_description     => 'Changes the service offering for a virtual machine',
    app_version         => $MonkeyMan::VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    --zone-name <name>
        [req*]      The zone's name
    --zone-id <id>
        [req*]      The zone's ID
  * It's required to define at least one of them (but only one).

    -v, --virtual-machine-id <id>
        [req]       The virtual machine's ID

    -S, --service-offering-name <name>
        [req*]      The service offering's name
    -s, --service-offering-id <id>
        [req*]      The service offering's ID
    -c, --cpu-cores <number>
        [opt**]     The number of CPUs (in MHz)
    -C, --cpu-speed <number>
        [opt**]     The CPUs' speed
    -m, --ram-size <number>
        [opt**]     The quantity of RAM (in MB)
  * It's required to define at least one of them (but only one).
 ** This option requires a custom-sized service offering to be selected.

    --no-stop
        [opt]       Don't stop the virtual machine if it's running
    --no-start
        [opt]       Don't start the virtual machine after making the changes

__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
Z|zone-name=s:
  zone_name:
    conflicts_any:
      - zone_id
z|zone-id=s:
  zone_id:
    conflicts_any:
      - zone_name
i|virtual-machine-id=s:
  virtual_machine_id:
    requires_each:
      - virtual_machine_id
O|service-offering-name=s:
  service_offering_name:
    conflicts_any:
      - service_offering_id
o|service-offering-id=s:
  service_offering_id:
    conflicts_any:
      - service_offering_name
c|cpu-cores=i:
  cpu_cores:
    requires_each:
      - cpu_speed
      - ram_size
s|cpu-speed=i:
  cpu_speed:
    requires_each:
      - cpu_cores
      - ram_size
m|ram-size=i:
  ram_size:
    requires_each:
      - cpu_cores
      - cpu_speed
no-stop:
  no_stop:
no-start:
  no_start:
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);

my $parameters  = $monkeyman->get_parameters;
my $logger      = $monkeyman->get_logger;
my $cloudstack  = $monkeyman->get_cloudstack;
my $api         = $cloudstack->get_api;



my $elements_catalog = {
    'zone'              => {
        type                => 'Zone',
        number              => 1,
        mandatory           => 1,
        results             => { zone => { query => 'element' } },
        parameters_fixed    => { available => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'zone_id' },
            filter_by_name          => { from_parameters => 'zone_name' }
        }
    },
    'virtual machine'   => {
        type                => 'VirtualMachine',
        number              => 2,
        mandatory           => 1,
        results             => { virtual_machine => { query => 'element' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'virtual_machine_id' },
            filter_by_zoneid        => { from_results => 'zoneid' }
        }
    },
    'service offering'  => {
        type                => 'ServiceOffering',
        number              => 3,
        mandatory           => 1,
        results             => { service_offering => { query => 'element' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'service_offering_id' },
            filter_by_name          => { from_parameters => 'service_offering_name' }
        }
    }
};
my $elements_recognized = { };

$cloudstack->find_all_elements(
    parameters          => $parameters,
    elements_catalog    => $elements_catalog,
    elements_recognized => $elements_recognized
);



my $zone                = $elements_recognized->{'zone'};
my $virtual_machine     = $elements_recognized->{'virtual_machine'};
my $service_offering    = $elements_recognized->{'service_offering'};
my $details = [ { } ];
$details->[0]->{'cpuNumber'} = $monkeyman->get_parameters->get_cpu_cores
    if($monkeyman->get_parameters->has_cpu_cores);
$details->[0]->{'cpuSpeed'} = $monkeyman->get_parameters->get_cpu_speed
    if($monkeyman->get_parameters->has_cpu_speed);
$details->[0]->{'memory'} = $monkeyman->get_parameters->get_ram_size
    if($monkeyman->get_parameters->has_ram_size);

$logger->debugf(
    "Going to switch the %s virtual machine in the %s zone to the %s service offering",
    $zone->get_id,
    $virtual_machine->get_id,
    $service_offering->get_id
);

my $virtual_machine_state = ($virtual_machine->qxp(
    query       => '/state',
    return_as   => 'value'
))[0];

if($virtual_machine_state ne 'Stopped') {
    MonkeyMan::Exception->throwf("The %s virtual machine isn't stopped (it's %s)", $virtual_machine, lc($virtual_machine_state))
        if($parameters->get_no_stop);
    $virtual_machine->perform_action(
        action      => 'stop',
        requested   => { 'id' => 'value' }
    );
    $logger->infof("The %s virtual machine has been stopped", $virtual_machine);
}



$virtual_machine->perform_action(
    action      => 'change_service_offering',
    parameters  => { 'service_offering_id' => $service_offering->get_id, 'details' => $details },
    requested   => { 'id' => 'value' }
);
$logger->infof(
    "The %s virtual machine's service offering has been changed to %s",
    $virtual_machine,
    $service_offering
);



if(! $parameters->get_no_start) {
    $virtual_machine->perform_action(
        action      => 'start',
        requested   => { 'id' => 'value' }
    );
    $logger->infof("The %s virtual machine has been started", $virtual_machine);
}
