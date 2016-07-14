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
use MonkeyMan::CloudStack::API;

# Use some third-party libraries
use Method::Signatures;
use File::Basename;
use Term::ReadKey;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'deploy_vm.pl',
    app_description     => 'Deploys virtual machines',
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    --service-offering-name <name>
        [req*]      The service offering's name
    --service-offering-id <name>
        [req*]      The service offering's ID
  * It's required to define at least one of them (you can set only one).

    --template-name <name>
        [req*]      The template's name
    --template-id <name>
        [req*]      The template's ID
  * It's required to define at least one of them (you can set only one).

    --zone-name <name>
        [req*]      The zone's name
    --zone-id <name>
        [req*]      The zone's ID
  * It's required to define at least one of them (you can set only one).

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

# 
# Dealing with the service offering (a mandatory parameter)
#

if(
    $parameters->has_service_offering_id ||
    $parameters->has_service_offering_name
) {

    my @service_offerings;

    if(defined($parameters->get_service_offering_id)) {
        # The ID is defined, so it will be easy to find the service offering
        @service_offerings = $api->perform_action(
            type        => 'ServiceOffering',
            action      => 'list',
            parameters  => { filter_by_id => $parameters->get_service_offering_id },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_service_offering_name)) {
        # Okay, they want to find the service_offering by the name
        @service_offerings = $api->perform_action(
            type        => 'ServiceOffering',
            action      => 'list',
            parameters  => { filter_by_name => $parameters->get_service_offering_name },
            requested   => { element => 'element' }
        );
    }

    if(@service_offerings > 1) {
        MonkeyMan::Exception->throwf(
            "Too many service offerings have been found, their IDs are: %s",
            join(', ', map({ $_->get_id } @service_offerings))
        );
    } elsif(@service_offerings < 1) {
        MonkeyMan::Exception->throw("The service offering hasn't been found");
    }

    $elements_found{'service_offering'} = $service_offerings[0];
    $deployment_parameters{'service_offering_id'} = $elements_found{'service_offering'}->get_id;

    $logger->debugf(
        "The %s service offering has been found, its ID is: %s",
        $elements_found{'service_offering'},
        $elements_found{'service_offering'}->get_id
    );

} else {

    # The service offering parameter is mandatory
    MonkeyMan::Exception->throw("The service offering (a required parameter) hasn't been choosen");

}

#
# Dealing with the template (another mandatory parameter)
#

if(
    $parameters->has_template_id ||
    $parameters->has_template_name
) {

    my @templates;

    if(defined($parameters->get_template_id)) {
        # The ID is defined, so it will be easy to find the templae
        @templates = $api->perform_action(
            type        => 'Template',
            action      => 'list',
            parameters  => {
                filter_by_type  => 'executable',
                filter_by_id    => $parameters->get_template_id
            },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_template_name)) {
        # Okay, they want to find the template by the name
        @templates = $api->perform_action(
            type        => 'Template',
            action      => 'list',
            parameters  => {
                filter_by_type  => 'executable',
                filter_by_name  => $parameters->get_template_name
            },
            requested   => { element => 'element' }
        );
    }

    if(@templates > 1) {
        MonkeyMan::Exception->throwf(
            "Too many templates have been found, their IDs are: %s",
            join(', ', map({ $_->get_id } @templates))
        );
    } elsif(@templates < 1) {
        MonkeyMan::Exception->throw("The template hasn't been found");
    }

    $elements_found{'template'} = $templates[0];
    $deployment_parameters{'template_id'} = $elements_found{'template'}->get_id;

    $logger->debugf(
        "The %s template has been found, its ID is: %s",
        $elements_found{'template'},
        $elements_found{'template'}->get_id
    );

} else {

    # The service offering parameter is mandatory
    MonkeyMan::Exception->throw("The template (a required parameter) hasn't been choosen");

}

#
# Dealing with the domain (if referenced)
#

my $domain_selected;

if(
    $parameters->has_domain_id          ||
    $parameters->has_domain_name        ||
    $parameters->get_domain_name_short
) {

    my @domains;

    if(defined($parameters->get_domain_id)) {
        # The ID is defined, so it will be easy to find the domain
        @domains = $api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { filter_by_id => $parameters->get_domain_id },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_domain_name)) {
        # Okay, they want to find the domain by the "full name", so let's make sure
        # that the path matches
        @domains = $api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { filter_by_path_all => $parameters->get_domain_name },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_domain_name_short)) {
        @domains = $api->perform_action(
            type        => 'Domain',
            action      => 'list',
            parameters  => { filter_by_name => $parameters->get_domain_name_short },
            requested   => { element => 'element' }
        );
    }

    if(@domains > 1) {
        # It may happen when the short name requested occures more than once
        MonkeyMan::Exception->throwf(
            "Too many domains have been found, their IDs are: %s",
            join(', ', map({ $_->get_id } @domains))
        );
    } elsif(@domains < 1) {
        MonkeyMan::Exception->throw("The domain hasn't been found");
    }

    $elements_found{'domain'} = $domains[0];
    $deployment_parameters{'domain_id'} = $elements_found{'domain'}->get_id;

    $logger->debugf(
        "The %s domain has been found, its ID is: %s",
        $elements_found{'domain'},
        $elements_found{'domain'}->get_id
    );

} else {

    $logger->tracef("The %s domain hasn't been choosen");

}

#
# Dealing with the account (if defined)
#
if(
    $parameters->has_account_name ||
    $parameters->has_account_id
) {

    my @accounts;

    if(defined($parameters->get_account_id)) {
        # Okay, they want to find the account by the name
        @accounts = $api->perform_action(
            type        => 'Account',
            action      => 'list',
            parameters  => {
                filter_by_id        => $parameters->get_account_id,
                filter_by_domainid  => $elements_found{'domain'}->get_id
            },
            requested   => { element => 'element' }
        );
    } elsif(defined($parameters->get_account_name)) {
        @accounts = $api->perform_action(
            type        => 'Account',
            action      => 'list',
            parameters  => {
                filter_by_name      => $parameters->get_account_name,
                filter_by_domainid  => $elements_found{'domain'}->get_id
            },
            requested   => { element => 'element' }
        );
    }

    if(@accounts > 1) {
        MonkeyMan::Exception->throwf(
            "Too many accounts have been found, their IDs are: %s",
            join(', ', map({ $_->get_id } @accounts))
        );
    } elsif(@accounts < 1) {
        MonkeyMan::Exception->throw("The account hasn't been found");
    }

    $elements_found{'account'} = $accounts[0];
    $deployment_parameters{'account_name'} = $parameters->get_account_name;

    $logger->debugf(
        "The %s account has been found, its ID is: %s",
        $elements_found{'account'},
        $elements_found{'account'}->get_id
    );

} else {

    $logger->tracef("The %s domain hasn't been set");

}



#
# Deploying a VM
#
$logger->debugf(
    "Going to deploy a virtual machine, " .
    "the following parameters' set is to be used: %s",
    \%deployment_parameters
);
