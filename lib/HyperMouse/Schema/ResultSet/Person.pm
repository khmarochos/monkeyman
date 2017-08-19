package HyperMouse::Schema::ResultSet::Person;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'HyperMouse::Schema::DefaultResultSet';

use HyperMouse::Exception qw(EmailNotFound PersonNotFound PersonNotConfirmed);

use Method::Signatures;
use TryCatch;
use Data::Dumper;

method filter_permission (
    Maybe[Int] : $person_id,
    Maybe[Int] : $id?,
    Str        : $action?,
){
    #print Dumper( "filter_permission", $action, $id, $person_id );
    return $self;
}


method authenticate (
    Str         :$email,
    Str         :$password,
    Maybe[Int]  :$email_validation_mask?,
    Maybe[Int]  :$password_validation_mask?,
    Maybe[Int]  :$person_validation_mask?
) {

    my $checks_failed;

    my $r_person_email = $self->get_schema
        ->resultset("PersonEmail")
        ->authenticate(
            email                       => $email,
            email_validation_mask       => $email_validation_mask,
            password                    => $password,
            password_validation_mask    => $password_validation_mask
        );

    $checks_failed = {};
    my $r_person = $r_person_email
        ->search_related("person")
        ->filter_validated(
            mask            => $person_validation_mask,
            checks_failed   => $checks_failed
        )
        ->single;

    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf_validity(
        $checks_failed, "The person with the %s email isn't found",
        $email
    )
        unless(defined($r_person));

    return($r_person);

}



method find_by_email (
    Str         :$email!,
    Maybe[Int]  :$email_validation_mask?,
    Maybe[Int]  :$person_validation_mask?
) {

    my $checks_failed;

    my $r_person_email = $self->get_schema
        ->resultset('PersonEmail')
        ->search({ email => $email })
        ->filter_validated(
            mask            => $person_validation_mask,
            checks_failed   => $checks_failed
        )
        ->single;
    (__PACKAGE__ . '::Exception::EmailNotFound')->throwf_validity(
        $checks_failed, "The %s email address isn't found",
        $email
    )
        unless(defined($r_person_email));

    my $r_person = $r_person_email
        ->search_related('person')
        ->filter_validated(
            mask            => $person_validation_mask,
            checks_failed   => $checks_failed
        )
        ->single;
    (__PACKAGE__ . '::Exception::PersonNotFound')->throwf_validity(
        $checks_failed, "The person with the %s email isn't present",
        $email
    )
        unless(defined($r_person));

    return($r_person);

}



__PACKAGE__->meta->make_immutable;

1;
