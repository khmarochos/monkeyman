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
use Term::ReadKey;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'create_account.pl',
    app_description     => 'Creates domains, accounts and users',
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
        [opt*]      The account's type ("user", "domain-admin", "root-admin")
  * If you need to create an account, all 3 parameters shall be provided, but
    the account name is required in any case.

    -U, --create-user
        [opt*]      The user needs to be created and bound to the account
    -u <name>, --user-name <name>
        [opt*]      The user's name
    -e <address>, --e-mail <address>
        [opt*]      The account's e-mail address
    -f <first name>, --first-name <first name>
        [opt*]      The first name
    -l <last name>, --last-name <last name>
        [opt*]      The last name
  * If you're creating an account or a user, you should provide some data.

    -p <password>, --password <password>
        [opt*,**]   The user's password
    -G <length>, --password-generate <length>
        [opt*]      The user's password needs to be generated
    -S, --password-stdin
        [opt*]      The user's password needs to be got from STDIN
    -P, --password-prompt
        [opt*]      The user's password needs to be entered twice
  * If you're creating an account or a user, you should provide the password.
    You can set only 1 of these 3 parameters. You can omit them, in that case
    the password will be generated automatically.
 ** We don't recommend you to use this option, it may lead to password leak!
__END_OF_USAGE_HELP__
    parameters_to_get_validated => <<__END_OF_PARAMETERS_TO_GET_VALIDATED__
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
    conflicts_any:
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
A|create-account:
  create_account:
    requires_each:
      - account_name
      - account_type
      - first_name
      - last_name
      - email_address
    requires_any.domain:
      - domain_name
      - domain_name_short
      - domain_id
    requires_any.password:
      - password
      - password_generate
      - password_stdin
      - password_prompt
t|account-type=s:
  account_type:
    requires_each:
      - create_account
    matches_any:
      - ^(user|root-admin|domain-admin)\$
      - ^[012]\$
a|account-name=s:
  account_name:
    requires_any:
      - create_account
      - create_user
U|create_user:
  create_user:
    requires_each:
      - user_name
      - account_name
      - first_name
      - last_name
      - email_address
    requires_any:
      - password
      - password_generate
      - password_stdin
      - password_prompt
u|user-name=s:
  user_name:
    requires_each:
      - create_user
e|email-address=s:
  email_address:
    requires_any:
      - create_account
      - create_user
f|first-name=s:
  first_name:
    requires_any:
      - create_account
      - create_user
l|last-name=s:
  last_name:
    requires_any:
      - create_account
      - create_user
p|password=s:
  password:
    requires_any:
      - create_account
      - create_user
    conflicts_any:
      - password_generate
      - password_stdin
      - password_prompt
G|password-generate:
  password_generate:
    requires_any:
      - create_account
      - create_user
    conflicts_any:
      - password
      - password_stdin
      - password_prompt
S|password-stdin:
  password_stdin:
    requires_any:
      - create_account
      - create_user
    conflicts_any:
      - password
      - password_generate
      - password_prompt
P|password-prompt:
  password_prompt:
    requires_any:
      - create_account
      - create_user
    conflicts_any:
      - password
      - password_generate
      - password_stdin
__END_OF_PARAMETERS_TO_GET_VALIDATED__
);
my $logger      = $monkeyman->get_logger;
my $api         = $monkeyman->get_cloudstack->get_api;
my $parameters  = $monkeyman->get_parameters;

my $password;

if(defined($parameters->get_password)) {
    # They want me to get it from the command-line parameters (insecure)
    $password = $parameters->get_password;
} elsif(defined($parameters->get_password_generate)) {
    # They want me to generate the password by myself
    $password = $monkeyman->get_password_generator->generate;
} elsif(defined($parameters->get_password_stdin)) {
    # They want me to receive it from STDIN (secure)
    chomp($password = <STDIN>);
} elsif(defined($parameters->get_password_prompt)) {
    # They want me to ask the operator to enter it twice
    PASSWORD_LOOP: for(1..3) {
        my @passwords;
        for(1..2) {
            printf(STDERR "Please, enter the desired password%s: ", (@passwords) ? ' again' : '');
            ReadMode('noecho');
            chomp(my $_password = <STDIN>);
            ReadMode('normal');
            if(!length($_password)) {
                print(STDERR "Sorry, the password shouldn't be empty\n");
                next(PASSWORD_LOOP);
            } else {
                push(@passwords, $_password);
            }
        }
        if($passwords[0] ne $passwords[1]) {
            print(STDERR "Sorry, the passwords you entered are different\n");
            next(PASSWORD_LOOP);
        } else {
            print(STDERR "Thanks!\n");
            $password = shift(@passwords);
            last(PASSWORD_LOOP);
        }
    }
    unless(defined($password)) {
        MonkeyMan::Exception->throwf(
            "The user haven't entered the password after 3 attempts, " .
            "someone should consider replacing the faulty one before to go next"
        );
    }
}

#
# Now let's find (or create) the domain
#

my @domains;
my $domain_existed;

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
    $logger->debugf("Going to create the %s domain", $parameters->get_domain_name);
    @domains = MonkeyMan::CloudStack::API::Element::Domain::create_domain(
        desired_name    => $parameters->get_domain_name,
        api             => $api,
        recursive       => ($parameters->get_create_domain > 1) ? 1 : 0
        # ^ if they add "-D" twice, the domain will be created recursively,
        #   so all parents will be created too 
    );
    $domain_existed = 0;
} else {
    $domain_existed = 1;
    $logger->warn("We asked to create a domain, but it exists")
        if(defined($parameters->get_create_domain));
}

my $domain_id = $domains[0]->get_id;
$logger->debugf(
    "The domain %s, it has the following ID: %s",
    $domain_existed ? 'has been created' : 'existed',
    $domain_id
);

printf(
    " Domain >> id: %s; path: %s (%s)\n",
    $domain_id,
    $domains[0]->qxp(query => '/path', return_as => 'value'),
    $domain_existed ? 'found' : 'created'
);

# Do we need to do anything else?
exit
    unless(
        defined($parameters->get_create_account) ||
        defined($parameters->get_create_user)
    );

#
# Now let's deal with the account
#

# Does this account already exist?
my @accounts = $api->perform_action(
    type        => 'Account',
    action      => 'list',
    parameters  => {
        filter_by_domainid  => $domain_id,
        filter_by_name      => $parameters->get_account_name
    },
    requested   => { element => 'element' }
);
my $account_existed;

# If the account does exist, we should consider creating a user bound to the same
if(@accounts > 1) {
    # It's odd to find more than one account with the same name in the same domain
    MonkeyMan::Exception->throwf(
        "Too many accounts have been found, their IDs are: %s",
        join(', ', map({ $_->get_id } @accounts))
    );
} elsif(@accounts < 1) {
    # Okay, so we'll need to create any?
    if(!defined($parameters->get_create_account)) {
        MonkeyMan::Exception->throw(
            "No account has been found, though its creation hasn't been requested"
        );
    }
    $logger->debugf("Going to create the %s account", $parameters->get_account_name);
    my $account_type;
    if($parameters->get_account_type =~ /^user$/i) {
        $account_type = 0;
    } elsif($parameters->get_account_type =~ /^root-admin$/i) {
        $account_type = 1;
    } elsif($parameters->get_account_type =~ /^domain-admin$/i) {
        $account_type = 2;
    } elsif($parameters->get_account_type =~ /^[012]$/) {
        $account_type = $parameters->get_account_type;
    } else {
        # TODO: Raise an exception?
    }
    @accounts = $api->perform_action(
        type        => 'Account',
        action      => 'create',
        parameters  => {
            type        => $account_type,
            name        => $parameters->get_account_name,
            email       => $parameters->get_email_address,
            first_name  => $parameters->get_first_name,
            last_name   => $parameters->get_last_name,
            password    => $password,
            domain      => $domain_id
        },
        requested   => { 'element' => 'element' },
    );
    $account_existed = 0;
} else {
    $account_existed = 1;
    $logger->warn("We asked to create an account, but it exists")
        if(defined($parameters->get_create_account));
}

my $account_id = $accounts[0]->get_id;
$logger->debugf(
    "The account %s, it has the following ID: %s",
    $account_existed ? 'has been created' : 'existed',
    $account_id
);

printf(
    "Account >> id: %s; name: %s (%s)%s\n",
    $account_id,
    $accounts[0]->qxp(query => '/name', return_as => 'value'),
    $account_existed ? 'found' : 'created',
   !$account_existed && defined($parameters->get_password_generate) ?
        ', the password generated: ' . $password :
        ''
);

# Do we need to do anything else?
exit
    unless(defined($parameters->get_create_user));

#
# And the last, but not ever ever ever least - the user!
#

my @users = $api->perform_action(
    type        => 'User',
    action      => 'list',
    parameters  => {
        name        => $parameters->get_user_name,
        account     => $parameters->get_account_name,
        domain      => $domain_id
    },
    requested   => { 'element' => 'element' },
);
my $user_existed;

if(@users > 1) {
    MonkeyMan::Exception->throwf(
        "Too many users have been found, their IDs are: %s",
        join(', ', map({ $_->get_id } @users))
    );
} elsif(@users < 1) {
    $logger->debugf("Going to create the %s user", $parameters->get_user_name);
    @users = $api->perform_action(
        type        => 'User',
        action      => 'create',
        parameters  => {
            name        => $parameters->get_user_name,
            email       => $parameters->get_email_address,
            first_name  => $parameters->get_first_name,
            last_name   => $parameters->get_last_name,
            password    => $password,
            account     => $parameters->get_account_name,
            domain      => $domain_id
        },
        requested   => { 'element' => 'element' },
    );
    $user_existed = 0;
} else {
    $user_existed = 1;
    $logger->warn("We asked to create a user, but it exists")
        if(defined($parameters->get_create_user));
}

my $user_id = $users[0]->get_id;
$logger->debugf(
    "The user %s, it has the following ID: %s",
    $user_existed ? 'has been created' : 'existed',
    $user_id
);

printf(
    "   User >> id: %s; name: %s (%s)%s\n",
    $user_id,
    $users[0]->qxp(query => '/username', return_as => 'value'),
    $user_existed ? 'found' : 'created',
   !$user_existed && defined($parameters->get_password_generate) ?
        ', the password generated: ' . $password :
        ''
);

