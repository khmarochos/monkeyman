package MaitreDNuage::Controller::Person;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Method::Signatures;
use TryCatch;



method is_authenticated {

    if(defined(my $email = $self->session('authorized_person_email'))) {
        return(1);
    } else {
        $self->redirect_to('/person/login');
        return(0);
    }

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

    return(1);

}



method login {

    my $person_email    = $self->param('person_email');
    my $person_password = $self->param('person_password');

    if(defined($self->session('authorized_person_email'))) {
        $self->redirect_to('/');
    } elsif(defined($person_email) && $self->authenticate($person_email, $person_password)) {
        $self->session(authorized_person_email => $person_email);
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

1;
