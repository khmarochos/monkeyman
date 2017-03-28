package MaitreD::Controller::Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Mojolicious::Controller';

use Mojolicious::Validator;
use Method::Signatures;
use TryCatch;
use Switch;
use DateTime;
use DateTime::Duration;
use Data::UUID;



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
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The email isn't registered");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::EmailNotConfirmed $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The email isn't confirmed");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::PersonNotFound $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The account isn't enabled");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::PasswordNotFound $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The account isn't enabled");
        return(0);
    } catch (HyperMouse::Schema::ResultSet::Person::Exception::PasswordIncorrect $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The password isn't correct");
        return(0);
    }

    $self->session(authorized_person_email => $email);
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



method signup {

    if($self->req->method eq 'POST') {
        if(defined(my $token = $self->param('token'))) {
            $self->redirect_to('person.confirm', token => $token);
        }
        my $v = $self->validation;
        $v->required(qw/ full_name  trim /);
        $v->required(qw/ email      trim /);
        $v->required(qw/ language   trim /);
        $v->required(qw/ timezone   trim /);
        if($v->has_error) {
            $self->stash(error_message  => "The data entered isn't valid");
            $self->stash(error_title    => "Registration Error");
        } elsif($self->hm_schema->resultset('PersonEmail')->find({ email => $v->param('email') })) {
            $v->error('email' => 'Already registered');
            $self->stash(error_message  => "The email entered is already registered");
            $self->stash(error_title    => "Registration Error");
        } else {
            my $name;
            (
                $name->{'first'},
                $name->{'middle'},
                $name->{'last'}
            ) = $v->param('full_name')      =~ /^(?:(\S+)?\s+)?(?:(\S.+\S)?\s+)?(\S+)$/;
            my $person_id = ($self->hm_schema->resultset('Person')->populate([ {
                valid_since         => undef,
                valid_till          => undef,
                removed             => undef,
                first_name          => $name->{'first'},
                middle_name         => $name->{'middle'},
                last_name           => $name->{'last'},
                language_id         => $self->hm_schema->resultset('Language')->find({ code => $v->param('language') })->id,
                datetime_format_id  => 1, # FIXME: Fetch a real row from the datetime_format table!
                timezone            => $v->param('timezone')
            } ]))[0]->id;
            my $person_email_id = ($self->hm_schema->resultset('PersonEmail')->populate([ {
                valid_since         => undef,
                valid_till          => undef,
                removed             => undef,
                email               => $v->param('email'),
                confirmed           => undef,
                person_id           => $person_id
            } ]))[0]->id;
            my $code = lc(Data::UUID->new->create_from_name_str(NameSpace_URL, 'https://maitre-d.tucha.ua/')); # FIXME: declare a constant!
            $self->hm_schema->resultset('PersonEmailConfirmation')->create({
                valid_since         => DateTime->now(),
                valid_till          => DateTime->now->add(DateTime::Duration->new(hours => 12)), # FIXME: declare a constant!
                removed             => undef,
                confirmed           => undef,
                code                => $code,
                person_email_id     => $person_email_id
            });
            $self->hypermouse->get_mailer->send_message_from_template(
                recipients      => $v->param('email'),
                subject         => 'Hello, world!',
                template_id     => 'maitre-d::person_confirmation_needed',
                template_values => {
                    first_name          => $v->param('full_name'),
                    confirmation_code   => $code,
                    confirmation_href   => 'https://maitre-d.tucha.ua/person/confirm/' . $code # FIXME: use url_for()
                }
            );
            $self->stash(confirmation_needed => 1);
        }
    }

}



method list {

    my @provisioning_agreements;
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
                            ->search({ id => $self->stash->{'related_id'} })
                                ->filter_valid
                                    ->single
                                        ->find_related_persons(
                                            mask_permitted  => $mask_permitted,
                                            mask_valid      => $mask_valid
                                        )
            ]);
        }
    }

}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
