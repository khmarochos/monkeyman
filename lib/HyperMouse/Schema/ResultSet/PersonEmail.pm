package HyperMouse::Schema::ResultSet::PersonEmail;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use MonkeyMan::Exception qw(EmailNotFound EmailNotConfirmed PersonNotFound PasswordNotFound PasswordIncorrect ConfirmationTokenNotFound);

use Method::Signatures;
use TryCatch;



method authenticate (
    Str :$email,
    Str :$password
) {
    my $db_schema   = $self->get_schema;

    my $r_person_email =
        $self
            ->search({ email => $email })
                ->filter_valid
                    ->single;

    (__PACKAGE__ . '::Exception::EmailNotFound')->throwf(
        "The %s email address isn't present",
        $email
    )
        unless(defined($r_person_email));

    (__PACKAGE__ . '::Exception::EmailNotConfirmed')->throwf(
        "The %s email address isn't confirmed",
        $email
    )
        unless(defined($r_person_email->confirmed));

    my $r_person =
        $r_person_email
            ->search_related("person")
                ->filter_valid
                    ->single;

    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf(
        "The person with the %s email isn't present",
        $email
    )
        unless(defined($r_person));

    my $r_password =
        $r_person
            ->search_related("person_passwords")
                ->filter_valid
                    ->single;

    (__PACKAGE__ . '::Exception::PasswordNotFound')->throwf(
        "The password for the person with the %s email isn't present",
        $email
    )
        unless(defined($r_password));

    (__PACKAGE__ . '::Exception::PasswordIncorrect')->throwf(
        "The password for the person with the %s email is incorrect",
        $email
    )
        unless($r_password->check_password($password));

    return($r_person_email);

}



method find_by_confirmation_token (
    Str         :$token!,
    Maybe[Int]  :$token_validity_mask?,
    Maybe[Int]  :$email_validity_mask?
) {

    my $db_schema = $self->get_schema;

    my $r_person_email_confirmation =
        $db_schema
            ->resultset('PersonEmailConfirmation')
                ->search({ code => $token })
                    ->filter_valid(mask => $token_validity_mask)
                        ->single;

    (__PACKAGE__ . '::Exception::ConfirmationTokenNotFound')->throwf(
        "The %s confirmation token isn't found in the database",
        $token
    )
        unless(defined($r_person_email_confirmation));

    my $r_person_email =
        $r_person_email_confirmation
            ->search_related('person_email')
                ->filter_valid(mask => $email_validity_mask)
                    ->single;

    (__PACKAGE__ . '::Exception::EmailNotFound')->throwf(
        "The %s confirmation token doesn't correspond to a valid email in the database",
        $token
    )
        unless(defined($r_person_email));

    return($r_person_email, $r_person_email_confirmation);

}



__PACKAGE__->meta->make_immutable;

1;
