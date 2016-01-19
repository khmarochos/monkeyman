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



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'create_account.pl',
    app_description     => 'Creates an account in the CloudStack domain',
    app_version         => MM_VERSION,
    app_usage_help      => sub { <<__END_OF_USAGE_HELP__; },
This application recognizes the following parameters:

    -d <name>, --domain-name <name>
        [req*]      The domain's full name (inclidung "ROOT")
    -D <name>, --domain-name-short <name>
        [req*]      The domain's short name (the last chunk)
    --domain-id <id>
        [req*]      The domain's ID
  * You can set only 1 of these 3 parameters, but it's mandatory to set one.

    -a <name>, --account-name <name>
        [req]       The account's name
    -t <type>, --account-type <type>
        [req]       The account's type ("admin" or "user")
    -e <address>, --e-mail <address>
        [opt]       The account's e-mail address

    -p <password>, --password <password>
        [opt*,**]   The account's password
    -P, --password-prompt
        [opt*]      The account's password needs to be entered
  * You can set only 1 of these 2 parameters. The password will be generated
    automatically if you don't set any of them.
 ** We don't recommend you to use this option, as it can cause password leak.
__END_OF_USAGE_HELP__
    parameters_to_get   => {
        'd|domain-name=s'       => 'domain_name',
        'D|domain-name-short=s' => 'domain_name_short',
        'domain-id=s'           => 'domain_id',
        'a|account-name=s'      => 'account_name',
        't|account-type=s'      => 'account_type',
        'e|email-address=s'     => 'e_mail',
        'p|password=s'          => 'password',
        'P|password-prompt'     => 'password_prompt'
    }
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;

