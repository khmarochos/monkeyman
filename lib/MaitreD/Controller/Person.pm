package MaitreD::Controller::Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Mojolicious::Controller';

use Method::Signatures;
use TryCatch;
use Switch;



method is_authenticated {

    if(defined(my $email = $self->session('authorized_person_email'))) {
        delete($self->session->{'was_heading_to'}) if(exists($self->session->{'was_heading_to'}));
        $self->stash->{'authorized_person_result'} = $self->hm_schema->resultset("Person")->person_info(email => $email);
        $self->stash->{'authorized_person_result'}->id; # That's what will be returned by the method
    } else {
        $self->session->{'was_heading_to'} = $self->req->url->path;
        $self->redirect_to('/person/login');
        0;
    }

}

method load_settings {
    $self->stash->{'language_id'}           = $self->stash->{'authorized_person_result'}->language->id;
    $self->stash->{'language_code'}         = $self->stash->{'authorized_person_result'}->language->code;
    $self->stash->{'timezone'}              = $self->stash->{'authorized_person_result'}->timezone;
    $self->stash->{'datetime_format_date'}  = $self->stash->{'authorized_person_result'}->datetime_format->format_date;
    $self->stash->{'datetime_format_time'}  = $self->stash->{'authorized_person_result'}->datetime_format->format_time;
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
        $self->redirect_to(
            defined($self->session->{'was_heading_to'}) ?
                    $self->session->{'was_heading_to'}  :
                    '/'
        );
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



method list {
    my @provisioning_agreements;
    my $person          = $self->stash->{'authorized_person_result'};
    my $mask_permitted  = 0b000111;
    my $mask_valid      = 0b000111;
    switch($self->stash->{'filter'}) {
        case('all')         { $mask_valid = 0b000101 }
        case('active')      { $mask_valid = 0b000111 }
        case('archived')    { $mask_valid = 0b001100 }
    }
    switch($self->stash->{'related_element'}) {
        case('provisioning_agreement') {
            $self->stash('rows' => [
                $self
                    ->hm_schema
                        ->resultset("ProvisioningAgreement")
                            ->search({ id => $self->stash->{'related_id'} })        # FIXME: PERMITTED & VALID!
                                ->single
                                    ->persons                                       # FIXME: PERMITTED & VALID!
            ]);
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
