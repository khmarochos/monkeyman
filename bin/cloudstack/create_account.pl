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



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'create_account.pl',
    app_description     => 'Creates an account in the CloudStack domain',
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    -C, --create-domain
        [opt] [mul] The domain needs to be created if it doesn't exist,
                    set it twice if we shall create all parent domains!
    -a <name>, --account-name <name>
        [req]       The account's name
    -t <type>, --account-type <type>
        [req]       The account's type ("admin" or "user")
    -e <address>, --e-mail <address>
        [opt]       The account's e-mail address

    -d <name>, --domain-name <name>
        [req*]      The domain's full name (includung "ROOT")
    -D <name>, --domain-name-short <name>
        [req*]      The domain's short name (the last chunk)
    --domain-id <id>
        [req*]      The domain's ID
  * You can set only 1 of these 3 parameters, but it's mandatory to set one.

    -p <password>, --password <password>
        [opt*,**]   The account's password
    -P, --password-prompt
        [opt*]      The account's password needs to be entered
  * You can set only 1 of these 2 parameters. You can omit them, and the
    password will be generated automatically.
 ** We don't recommend you to use this option, as it may lead to password leak.
__END_OF_USAGE_HELP__
    parameters_to_get   => {
        'C|create-domain'       => 'create_domain',
        'a|account-name=s'      => 'account_name',
        't|account-type=s'      => 'account_type',
        'e|email-address=s'     => 'e_mail',
        'd|domain-name=s'       => 'domain_name',
        'D|domain-name-short=s' => 'domain_name_short',
        'domain-id=s'           => 'domain_id',
        'p|password=s'          => 'password',
        'P|password-prompt'     => 'password_prompt',
    }
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;

#
# First of all, let's make sure that no parameters given are redundant
#

foreach (
    [ qw(   domain_id   domain_name     domain_name_short   ) ],
    [ qw(   domain_id   create_domain                       ) ],
    [ qw(   password    password_prompt                     ) ],
) {
    $parameters->check_loneliness(fatal => 1, attributes_alone => $_);
}

#
# Now let's find (or create) the domain
#

my @domains;

if($parameters->get_domain_id) {
    # The ID is defined, so it will be easy to find the domain
    @domains = $api->get_elements(
        type        => 'Domain',
        criterions  => { id => $parameters->get_domain_id }
    );
} elsif($parameters->get_domain_name) {
    # Okay, they want to find the domain by the "full name", so let's make sure
    # that the path matches
    @domains = $api->get_elements(
        type        => 'Domain',
        criterions  => {
            name => basename($parameters->get_domain_name)
        },
        xpaths      => [
            sprintf("/domain[path = '%s']", $parameters->get_domain_name)
        ] 
    );
} elsif($parameters->get_domain_name_short) {
    @domains = $api->get_elements(
        type        => 'Domain',
        criterions  => {
            name => $parameters->get_domain_name_short,
        }
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
    # The domain doesn't exist, shall we create it?
    if(!$parameters->get_create_domain) {
        MonkeyMan::Exception->throw(
            "No domain has been found, its creation hasn't been requested"
        );
    }
}
