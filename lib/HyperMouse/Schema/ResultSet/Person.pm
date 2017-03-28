package HyperMouse::Schema::ResultSet::Person;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use MonkeyMan::Exception qw(EmailNotFound EmailNotConfirmed PersonNotFound PasswordNotFound PasswordIncorrect);

use Method::Signatures;
use TryCatch;



method authenticate (
    Str :$email,
    Str :$password
) {
    my $db_schema   = $self->get_schema;

    my $db_email    = $db_schema->resultset("PersonEmail")->search({ email => $email })->filter_valid->single;
    (__PACKAGE__ . '::Exception::EmailNotFound')->throwf(
        "The %s email address isn't present",
        $email
    )
        unless(defined($db_email));

    (__PACKAGE__ . '::Exception::EmailNotConfirmed')->throwf(
        "The %s email address isn't confirmed",
        $email
    )
        unless(defined($db_email->confirmed));

    my $db_person   = $db_email->search_related("person")->filter_valid->single;
    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf(
        "The person with the %s email isn't present",
        $email
    )
        unless(defined($db_person));

    my $db_password = $db_person->search_related("person_passwords")->filter_valid->single;
    (__PACKAGE__ . '::Exception::PasswordNotFound')->throwf(
        "The password for the person with the %s email isn't present",
        $email
    )
        unless(defined($db_password));

    (__PACKAGE__ . '::Exception::PasswordIncorrect')->throwf(
        "The password for the person with the %s email is incorrect",
        $email
    )
        unless($db_password->check_password($password));

    return($db_person->id);
}



method person_info (
    Str :$email
) {
    my $db_schema   = $self->get_schema;

    my $db_email    = $db_schema->resultset("PersonEmail")->search({ email => $email })->filter_valid->single;
    (__PACKAGE__ . '::Exception::EmailNotFound')->throwf(
        "The %s email address isn't present",
        $email
    )
        unless(defined($db_email));

    my $db_person   = $db_email->search_related("person")->filter_valid->single;
    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf(
        "The person with the %s email isn't present",
        $email
    )
        unless(defined($db_person));

    return($db_person);

}



__PACKAGE__->meta->make_immutable;

1;
