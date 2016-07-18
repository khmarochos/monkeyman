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
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    --zone-name <name>
        [req*]      The zone's name
    --zone-id <id>
        [req*]      The zone's ID
  * It's required to define at least one of them (but only one).

    --service-offering-name <name>
        [req*]      The service offering's name
    --service-offering-id <id>
        [req*]      The service offering's ID
  * It's required to define at least one of them (but only one).

    --template-name <name>
        [req*]      The template's name
    --template-id <id>
        [req*]      The template's ID
  * It's required to define at least one of them (but only one).

    --network-names <name1> <name2> ... <nameN>
        [opt*] [mul] The list of networks' names
    --network-ids <id1> <id2> ... <idN>
        [opt*] [mul] The list of networks' IDs
  * You can set only 1 of these 2 parameters.

    --ipv4-addresses <address1> <address2> ... <addressN>
        [opt] [mul] The list of IPv4-addresses
    --ipv6-addresses <address1> <address2> ... <addressN>
        [opt] [mul] The list of IPv6-addresses

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
        [opt*]      The account's name
  * One of these is required if the domain is choosen (you can set only one).

    --password <password>
        [opt*]      The user's password
    --password-generate <length>
        [opt]       The user's password needs to be generated
    --password-stdin
        [opt]       The user's password needs to be got from STDIN
    --password-prompt
        [opt]       The user's password needs to be entered twice
  * We don't recommend you to use this option, it may lead to password leak!
__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
---
zone-name=s:
  zone_name:
    conflicts_any:
      - zone_id
zone-id=s:
  zone_id:
    conflicts_any:
      - zone_name
service-offering-name=s:
  service_offering_name:
    conflicts_any:
      - service_offering_id
service-offering-id=s:
  service_offering_id:
    conflicts_any:
      - service_offering_name
template-name=s:
  template_name:
    conflicts_any:
      - template_id
template-id=s:
  template_id:
    conflicts_any:
      - template_name
networks-names=s\@:
  networks_names:
    conflicts_any:
      - networks_ids
networks-ids=s\@:
  networks_ids:
    conflicts_any:
      - networks_names
ipv4-addresses=s\%:
  ipv4_addresses:
    requires_any:
      - networks_names
      - networks_ids
ipv6-addresses=s\%:
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
password=s:
  password:
    conflicts_any:
      - password_generate
      - password_stdin
      - password_prompt
password-generate:
  password_generate:
    conflicts_any:
      - password
      - password_stdin
      - password_prompt
password-stdin:
  password_stdin:
    conflicts_any:
      - password
      - password_generate
      - password_prompt
password-prompt:
  password_prompt:
    conflicts_any:
      - password
      - password_generate
      - password_stdin
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;

my %deployment_parameters;  # The parameters to be given to the deployment method
my %elements_found;         # The references to the elements found are to be kept here

my $what_is_what = {
    'zone'              => {
        type                => 'Zone',
        number              => 1,
        mandatory           => 1,
        results             => { zone_id => { query => '/id' } },
        parameters_fixed    => { available => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'zone_id' },
            filter_by_name          => { from_parameters => 'zone_name' }
        }
    },
    'service offering'  => {
        type                => 'ServiceOffering',
        number              => 2,
        mandatory           => 1,
        results             => { service_offering_id => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'service_offering_id' },
            filter_by_name          => { from_parameters => 'service_offering_name' }
        }
    },
    'template'          => {
        type                => 'Template',
        number              => 3,
        mandatory           => 1,
        results             => { template_id => { query => '/id' } },
        parameters_fixed    => { all => 'true', filter_by_type => 'executable' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'template_id' },
            filter_by_name          => { from_parameters => 'template_name' }
        }
    },
    'network'          => {
        type                => 'Network',
        number              => 4,
        mandatory           => 0,
        ref                 => 'ARRAY', # There'll be multiple networks to be found!
        results             => { network_id => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'networks_ids' },
            filter_by_name          => { from_parameters => 'networks_names' }
        }
    },
    'domain'            => {
        type                => 'Domain',
        number              => 5,
        mandatory           => 0,
        results             => { domain_id => { query => '/id' } },
        parameters_fixed    => { all => 'true', filter_by_type => 'executable' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'domain_id' },
            filter_by_path          => { from_parameters => 'domain_name' },
            filter_by_name          => { from_parameters => 'domain_name_short'}
        }
    },
    'account'            => {
        type                => 'Account',
        number              => 6,
        mandatory           => 0,
        results             => { account_id => { query => '/id' } },
        parameters_fixed    => { all => 'true' },
        parameters_variable => {
            filter_by_id            => { from_parameters => 'account_id' },
            filter_by_name          => { from_parameters => 'account_name' },
            filter_by_domainid      => { from_results => 'domain_id' }
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

    $logger->debugf(
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

    $logger->debugf(
        "We're ready to perform list-getting actions to find the following element(s): %s",
        \%huerga_desired
    );

    if(
        # So, have we got any command-line parameters about this huerga?
        (my @action_parameters_names = keys(%huerga_desired)) ||
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

        $logger->debugf(
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
                    $huerga_name, join(', ', map({ sprintf("%s: %s", $_, $huerga_desired{$_})} keys(%{ %huerga_desired })))
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
                            if(@action_parameters_sets == 1) {
                                # If we need to get only one element, we'll simply put it
                                # to the $deployment_parameters hash as a scalar value
                                $deployment_parameters{$deployment_parameter} = $results[0];
                            } else {
                                # If we need to get multiple elements, we'll put it
                                # to an array referenced from the $deployment_parameters hash
                                unless(defined($deployment_parameters{$deployment_parameter})) {
                                    # If it hasn't been initialized yet
                                    $deployment_parameters{$deployment_parameter} = [ $results[0] ];
                                } else {
                                    # Otherwise, we'll push the new element
                                    push(@{ $deployment_parameters{$deployment_parameter} }, $results[0]);
                                }
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
# Deploying a VM
#
$logger->debugf(
    "Going to deploy a virtual machine, " .
    "the following parameters' set is to be used: %s",
    \%deployment_parameters
);



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