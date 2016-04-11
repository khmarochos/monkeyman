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
use MonkeyMan::CloudStack::API::Element::Domain;

# Use some third-party libraries
use Method::Signatures;
use File::Basename;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'create_account.pl',
    app_description     => 'Creates an account in the CloudStack domain',
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    -D, --create-domain
        [opt] [mul] The domain needs to be created if it doesn't exist,
                    just add this parameter more than once if we shall
                    create all the parent domains recursively
    -d <name>, --domain-name <name>
        [req*]      The domain's full name and path (includung "ROOT")
    -s <name>, --domain-name-short <name>
        [req*]      The domain's short name (the last chunk)
    -i <id>, --domain-id <id>
        [req*]      The domain's ID
  * You can set only 1 of these 3 parameters, but it's mandatory to set at
    least one of them.

    -A, --create-account
        [opt*]      The account needs to be created
    -a <name>, --account-name <name>
        [req*]       The account's name
    -t <type>, --account-type <type>
        [req*]      The account's type ("user", "domain-admin", "root-admin")
  * If you need to create an account, all 3 parameters shall be provided, but
    the account name is required in any case.

    -u <name>, --user-name <name>
        [opt]       The user's name (if differs from the account's name)
    -e <address>, --e-mail <address>
        [opt]       The account's e-mail address

    -f <first name>, --first-name <first name>
        [req*]      The first name
    -l <last name>, --last-name <last name>
        [req*]      The last name
  * You can set only 1 of these 3 parameters, but it's mandatory to set at
    least one of them.

    -p <password>, --password <password>
        [opt*,**]   The account's password
    -S, --password-stdin
        [opt*]      The account's password needs is to be got from STDIN
    -P, --password-prompt
        [opt*]      The account's password needs to be entered twice
  * You can set only 1 of these 3 parameters. You can omit them, in that case
    the password will be generated automatically.
 ** We don't recommend you to use this option, it may lead to password leak!
__END_OF_USAGE_HELP__
    parameters_to_get_and_check => <<__END_OF_PARAMETERS_TO_GET_AND_CHECK__
---
D|create-domain+:
  create_domain:
    requires_each:
      - domain_name
    conflicts_any:
      - domain_id
      - domain_name_short
d|domain-name=s:
  domain_name:
    conflicts:
      - domain_id
      - domain_name_short
s|domain-name-short=s:
  domain_name_short:
    conflicts_any:
      - domain_id
      - domain_name
      - create_domain
i|domain-id=s:
  domain_id:
    conflicts_any:
      - create_domain
      - domain_name
      - domain_name_short
A|create-account+:
  create_account:
    requires_each:
      - account_name
      - account_type
      - first_name
      - last_name
      - email_address
    requires_any:
      - password
      - password_stdin
      - password_prompt
t|account-type=s:
  account_type:
    requires_each:
      - create_account
a|account-name=s:
  account_name:
    requires_each:
      - account_name
    matches_any:
      - /.*/
u|user-name=s:
  user_name:
    requires_each:
      - account_name
      - first_name
      - last_name
      - email_address
    requires_any:
      - password
      - password_stdin
      - password_prompt
e|email-address=s:
  email_address:
    requires_any:
      - create_account
      - user_name
f|first-name=s:
  first_name:
    requires_any:
      - create_account
      - user_name
l|last-name=s:
  last_name:
    requires_any:
      - create_account
      - user_name
p|password=s:
  password:
    requires_any:
      - create_account
      - user_name
    conflicts_any:
      - password_stdin
      - password_prompt
S|password-stdin:
  password_stdin:
    requires_any:
      - create_account
      - user_name
    conflicts_any:
      - password
      - password_prompt
P|password-prompt:
  password_prompt:
    requires_any:
      - create_account
      - user_name
    conflicts_any:
      - password
      - password_stdin
__END_OF_PARAMETERS_TO_GET_AND_CHECK__
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_and_check_parameters;

#
# Now let's find (or create) the domain
#

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
} else {
    MonkeyMan::Exception->throw("No domain has been defined");
}

if(@domains > 1) {
    # It may happen when the short name requested occures more than once
    MonkeyMan::Exception->throwf(
        "Too many domains have been found, their IDs are: %s",
        join(', ', map({ $_->get_id } @domains))
    );
} elsif(@domains < 1) {
    # The domain doesn't exist, so shall we create it?
    if(!defined($parameters->get_create_domain)) {
        MonkeyMan::Exception->throw(
            "No domain has been found, but its creation hasn't been requested"
        );
    }
    if(!defined($parameters->get_domain_name)) {
        MonkeyMan::Exception->throw(
            "Domain creation has been requested, but its name hasn't been set"
        );
    }
    $logger->infof("Going to create the %s domain", $parameters->get_domain_name);
    @domains = MonkeyMan::CloudStack::API::Element::Domain::create_domain(
        desired_name    => $parameters->get_domain_name,
        api             => $api,
        recursive       => ($parameters->get_create_domain > 1) ? 1 : 0
    );
}

my $domain_id = shift(@domains)->get_id;
$logger->debugf("The domain has the following ID: %s", $domain_id);

#
# And now we can create the account if it's needed
#

my $account = $api->perform_action(
    type        => 'Account',
    action      => 'create',
    parameters  => {
        
    },
    requested   => { 'element' => 'element' },
);
$logger->debugf("The account has the following ID: %s", $account->get_id);
