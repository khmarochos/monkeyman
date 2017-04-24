package HyperMouse::Schema::ResultSet::PersonEmail;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'HyperMouse::Schema::DefaultResultSet';

use HyperMouse::Exception qw(
    PersonEmailNotFound
    PersonPasswordNotFound
    PersonPasswordIncorrect
    PersonNotFound
    ConfirmationTokenNotFound
);

use Method::Signatures;
use TryCatch;



method authenticate (
    Str         :$email,
    Str         :$password,
    Maybe[Int]  :$email_validation_mask?,
    Maybe[Int]  :$password_validation_mask?
) {

    my $checks_failed;

    $checks_failed = {};
    my $r_person_email = $self
        ->search({ email => $email })
        ->filter_validated(
            mask            => $email_validation_mask,
            checks_failed   => $checks_failed
        )
        ->single;
    unless(defined($r_person_email)) {
        (__PACKAGE__ . '::Exception::PersonEmailNotFound')->throwf_validity(
            $checks_failed, "The %s email address isn't found",
            $email,
        );
    }

    $checks_failed = {};
    my $r_person = $r_person_email
        ->search_related('person')
        ->filter_validated(
            mask            => $email_validation_mask,
            checks_failed   => $checks_failed
        )
        ->single;
    unless(defined($r_person_email)) {
        (__PACKAGE__ . '::Exception::PersonNotFound')->throwf_validity(
            $checks_failed, "The %s email's person isn't found",
            $email
        );
    }

    $checks_failed = {};
    my $r_person_password = $r_person
        ->search_related('person_passwords')
        ->filter_validated(
            mask            => $password_validation_mask,
            checks_failed   => $checks_failed
        )
        ->single;
    unless(defined($r_person_password)) {
        (__PACKAGE__ . '::Exception::PersonPasswordNotFound')->throwf_validity(
            $checks_failed, "The %s email's person's password isn't found",
            $email
        );
    }
    (__PACKAGE__ . '::Exception::PersonPasswordIncorrect')->throwf(
        "The password for the person with the %s email is incorrect",
        $email
    )
        unless($r_person_password->check_password($password));

    return($r_person_email);

}



__PACKAGE__->meta->make_immutable;

1;
