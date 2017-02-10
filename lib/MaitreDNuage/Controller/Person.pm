package MaitreDNuage::Controller::Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use Method::Signatures;
use TryCatch;



method is_authenticated {

    if(defined(my $email = $self->session('authorized_person_email'))) {
        $self->stash->{'authorized_person_result'} = $self->hm_schema->resultset("Person")->person_info(email => $email);
        $self->stash->{'authorized_person_result'}->id; # It'll be returned by the method
    } else {
        $self->redirect_to('/person/login');
        0;
    }

}

method load_settings {
    $self->stash->{'language'} = $self->stash->{'authorized_person_result'}->language->code;
    $self->stash->{'timezone'} = $self->stash->{'authorized_person_result'}->timezone;
}

method authenticate (Str $email!, Str $password!) {

    try {
        $self->hm_schema->resultset("Person")->authenticate(
            email       => $email,
            password    => $password
        );
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::EmailNotFound $e) {
        $self->stash(error_message => "The email isn't registered");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::PersonNotFound $e) {
        $self->stash(error_message => "The account isn't enabled");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::PasswordNotFound $e) {
        $self->stash(error_message => "The account isn't enabled");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::PasswordIncorrect $e) {
        $self->stash(error_message => "The password isn't correct");
        return(0);
    }

    $self->session  (authorized_person_email => $email);
    return(1);

}



method login {

    my $person_email    = $self->param('person_email');
    my $person_password = $self->param('person_password');

    if(defined($self->session('authorized_person_email'))) {
        $self->redirect_to('/');
    } elsif(defined($person_email) && $self->authenticate($person_email, $person_password)) {
        $self->redirect_to('/');
    } elsif(defined($person_email)) {
        $self->render(variant => 'unsuccessful');
    } else {
        $self->render(variant => 'welcome');
    }

}



method logout {

    $self->session(authorized_person_email => undef);

    $self->redirect_to('/');

}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
