package HyperMouse::Schema::ResultSet::Person;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use MonkeyMan::Exception qw(EmailNotFound PersonNotFound PersonNotConfirmed);

use Method::Signatures;
use TryCatch;



method authenticate (
    Str :$email,
    Str :$password
) {

    my $db_schema = $self->get_schema;

    my $r_person_email = $db_schema->resultset("PersonEmail")->authenticate(
        email       => $email,
        password    => $password
    );

    my $r_person = $r_person_email->search_related("person")->filter_valid->single;

    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf(
        "The person with the %s email isn't present",
        $email
    )
        unless(defined($r_person));

    (__PACKAGE__ . '::Exception::PersonNotConfirmed')->throwf(
        "The person with the %s email address isn't confirmed",
        $email
    )
        unless(defined($r_person->confirmed));

    return($r_person);

}



method find_by_email (
    Str         :$email!,
    Maybe[Int]  :$email_validity_mask?,
    Maybe[Int]  :$person_validity_mask?
) {

    my $db_schema = $self->get_schema;

    my $r_email =
        $db_schema
            ->resultset("PersonEmail")
                ->search({ email => $email })
                    ->filter_valid(mask => $email_validity_mask)
                        ->single;

    (__PACKAGE__ . '::Exception::EmailNotFound')->throwf(
        "The %s email address isn't present",
        $email
    )
        unless(defined($r_email));

    my $r_person =
        $r_email
            ->search_related("person")
                ->filter_valid(mask => $person_validity_mask)
                    ->single;

    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf(
        "The person with the %s email isn't present",
        $email
    )
        unless(defined($r_person));

    return($r_person);

}



__PACKAGE__->meta->make_immutable;

1;
