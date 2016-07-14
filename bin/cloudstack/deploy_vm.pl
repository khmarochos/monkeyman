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
    --zone-id <name>
        [req*]      The zone's ID
  * It's required to define at least one of them (but only one).

    --service-offering-name <name>
        [req*]      The service offering's name
    --service-offering-id <name>
        [req*]      The service offering's ID
  * It's required to define at least one of them (but only one).

    --template-name <name>
        [req*]      The template's name
    --template-id <name>
        [req*]      The template's ID
  * It's required to define at least one of them (but only one).

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
    'domain'            => {
        type                => 'Domain',
        number              => 4,
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
        number              => 5,
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

foreach my $huerga (
    sort(
        {
            $what_is_what->{$a}->{'number'} <=> $what_is_what->{$b}->{'number'}
        }
        keys(%{ $what_is_what })
    )
) {

    $logger->tracef("Selecting the %s desired", $huerga);

    my @huerga_desired;
    my %huerga_parameters = ref($what_is_what->{$huerga}->{'parameters_fixed'}) eq 'HASH' ?
        (%{ $what_is_what->{$huerga}->{'parameters_fixed'} }) :
        ();
    foreach my $parameter_name (keys(%{ $what_is_what->{$huerga}->{'parameters_variable'} })) {
        my $parameter_source = $what_is_what->{$huerga}->{'parameters_variable'}->{$parameter_name};
        if(defined($parameter_source->{'from_results'})) {
            $huerga_parameters{$parameter_name} = $deployment_parameters{ $parameter_source->{'from_results'} };
        } elsif(defined($parameter_source->{'from_parameters'})) {
            my $predicate = 'has_' . $parameter_source->{'from_parameters'};
            my $reader    = 'get_' . $parameter_source->{'from_parameters'};
            if($monkeyman->get_parameters->$predicate) {
                my $value = $monkeyman->get_parameters->$reader;
                push(@huerga_desired, { $parameter_source->{'from_parameters'} => $value });
                # ^^^ To keep in mind that the operator asked for it
                $huerga_parameters{$parameter_name} = $value;
                # ^^^ To perform the action in a moment (see below)
            }
        }
    }
    if(@huerga_desired) {
        my @huerga_found = $api->perform_action(
            type        => $what_is_what->{$huerga}->{'type'},
            action      => 'list',
            parameters  => \%huerga_parameters,
            requested   => { element => 'element' }
        );
        if(@huerga_found < 1) {
            MonkeyMan::Exception->throwf(
                "The %s desired (%s) has not been found",
                $huerga,
                join(', ', map({ join(': ', each(%{ $_ })) } @huerga_desired))
            );
        } elsif(@huerga_found > 1) {
            MonkeyMan::Exception->throwf(
                "Too many %s have been found, their IDs are: %s",
                PL($huerga),
                join(', ', map({ $_->get_id } @huerga_found))
            );
        } else {
            my $huerga_selected = $huerga_found[0];
            $logger->debugf(
                "The %s %s has been found, its ID is: %s",
                $huerga_selected,
                $huerga,
                $huerga_selected->get_id
            );
            $elements_found{$huerga} = $huerga_selected;
            foreach my $deployment_parameter (keys(%{ $what_is_what->{$huerga}->{'results'} })) {
                my $query = $what_is_what->{$huerga}->{'results'}->{$deployment_parameter}->{'query'};
                if(defined($query)) {
                    my @results = $huerga_selected->qxp(
                        query       => $query,
                        return_as   => 'value'
                    );
                    if(@results < 1) {
                        MonkeyMan::Exception->throwf("Expected a result, have got none");
                    } elsif(@huerga_found > 1) {
                        MonkeyMan::Exception->throwf("Expected a result, have got too many");
                    } else {
                        $deployment_parameters{$deployment_parameter} = $results[0];
                    }
                }
            }
        }
    } elsif($what_is_what->{$huerga}->{'mandatory'}) {
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
