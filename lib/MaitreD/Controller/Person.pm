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
        $self->stash->{'authorized_person_result'} = $self->hm_schema->resultset("Person")->find_by_email(email => $email);
        $self->stash->{'authorized_person_result'}->id;
    } else {
        $self->session->{'was_heading_to'} = $self->req->url->path;
        $self->redirect_to('/person/login');
        0;
    }
    # $self->stash->{'authorized_person_result'}->id or 0 will be returned

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
    } catch(HyperMouse::Schema::ResultSet::Person::Exception::EmailNotFound $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The email isn't registered");
        return(0);
    } catch(HyperMouse::Schema::ResultSet::Person::Exception::EmailNotConfirmed $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The email isn't confirmed");
        return(0);
    } catch(HyperMouse::Schema::ResultSet::Person::Exception::PersonNotFound $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The account isn't enabled");
        return(0);
    } catch(HyperMouse::Schema::ResultSet::Person::Exception::PasswordNotFound $e) {
        $self->stash(error_title    => "Authentication Error");
        $self->stash(error_message  => "The account isn't enabled");
        return(0);
    } catch(HyperMouse::Schema::ResultSet::Person::Exception::PasswordIncorrect $e) {
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
        my $hm_schema   = $self->hm_schema;
        my $v           = $self->validation;
        $v->required(qw/ full_name  trim /);
        $v->required(qw/ email      trim /);
        $v->required(qw/ language   trim /);
        $v->required(qw/ timezone   trim /);
        if($v->has_error) {
            $self->stash(error_message  => "The data entered isn't valid");
            $self->stash(error_title    => "Registration Error");
            return;
        } elsif($hm_schema->resultset('PersonEmail')->find({ email => $v->param('email') })) {
            $v->error('email' => 'Already registered');
            $self->stash(error_message  => "The email entered is already registered");
            $self->stash(error_title    => "Registration Error");
            return;
        }
        my $now = DateTime->now;
        my $name;
        (
            $name->{'first'},
            $name->{'middle'},
            $name->{'last'}
        ) = $v->param('full_name')      =~ /^(?:(\S+)?\s+)?(?:(\S.+\S)?\s+)?(\S+)$/;
        my $person_id = ($hm_schema->resultset('Person')->populate([ {
            valid_since         => $now,
            valid_till          => undef,
            removed             => undef,
            confirmed           => undef,
            first_name          => $name->{'first'},
            middle_name         => $name->{'middle'},
            last_name           => $name->{'last'},
            language_id         => $hm_schema->resultset('Language')->find({ code => $v->param('language') })->id,
            datetime_format_id  => 1, # FIXME: Fetch a real row from the datetime_format table!
            timezone            => $v->param('timezone')
        } ]))[0]->id;
        my $person_email_id = ($hm_schema->resultset('PersonEmail')->populate([ {
            valid_since         => $now,
            valid_till          => undef,
            removed             => undef,
            email               => $v->param('email'),
            confirmed           => undef,
            person_id           => $person_id
        } ]))[0]->id;
        my $code = lc(Data::UUID->new->create_from_name_str(NameSpace_URL, 'https://maitre-d.tucha.ua/')); # FIXME: declare a constant!
        $hm_schema->resultset('PersonEmailConfirmation')->create({
            valid_since         => $now,
            valid_till          => $now->add(DateTime::Duration->new(hours => 12)), # FIXME: declare a constant!
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
                first_name          => $name->{'first'},
                confirmation_code   => $code,
                confirmation_href   => 'https://maitre-d.tucha.ua/person/confirm/' . $code # FIXME: use url_for()
            }
        );
        $self->redirect_to('person.confirm');
    }
}



method confirm {
    my $now         = DateTime->now;
    my $hm_schema   = $self->hm_schema;
    my $v           = $self->validation;
    my $method      = $self->req->method;
    if($method eq 'POST') {
        $v->optional(qw/ update_person_data trim /);
        $v->required(qw/ token              trim /);
        if(defined(my $token = $v->param('token'))) {
            if($v->param('update_person_data')) {

                $v->required(qw/ first_name         trim /);
                $v->optional(qw/ middle_name        trim /);
                $v->required(qw/ last_name          trim /);
                $v->required(qw/ password           trim /);
                $v->required(qw/ password_repeat    trim /);
                # TODO: validate other fields

                my $r_person_email = (
                    $hm_schema
                        ->resultset('PersonEmail')
                            ->find_by_confirmation_token(token => $token, token_validity_mask => 0b001110)
                )[0];

                unless(defined($r_person_email->confirmed)) {
                    $self->stash(error_title    => "Confirmation Error");
                    $self->stash(error_message  => "The email isn't confirmed");
                    return;
                }

                # TODO: use TryCatch here
                my $r_person =
                    $hm_schema
                        ->resultset('Person')
                            ->find_by_email(email => $r_person_email->email);

                unless(defined($r_person)) {
                    $self->stash(error_title    => "Confirmation Error");
                    $self->stash(error_message  => "The person isn't found");
                    return;
                }

                $r_person->update({
                    confirmed           => $now,
                    first_name          => $v->param('first_name'),
                    middle_name         => $v->param('middle'),
                    last_name           => $v->param('last'),
                });

                $hm_schema
                    ->resultset('PersonPassword')
                        ->create({
                            valid_since => $now,
                            valid_till  => undef,
                            removed     => undef,
                            password    => $v->param('password'),
                            person_id   => $r_person->id
                        });

                $self->redirect_to('person.login');

            } else {

                $self->redirect_to('person.confirm', token => $token);

            }
        }

    } elsif($method eq 'GET') {
        # TODO: It seems to be a Mojolicious' bug, so it needs to be reported:
        # xxx::Controller->param() works fine with placeholder-parameters, but
        # xxx::Validation->param() doesn't :-(
        my $token = $self->param('token');

        # If there is no token, just show the confirmation form
        return
            unless(defined($token));

        my $r_person_email;
        my $r_person_email_confirmation;
        try {
            (
                $r_person_email,
                $r_person_email_confirmation
            ) =
                $hm_schema
                    ->resultset('PersonEmail')
                        ->find_by_confirmation_token(token => $token);
        } catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::ConfirmationTokenNotFound $e) {
            $self->stash(error_title    => "Confirmation Error");
            $self->stash(error_message  => "The confirmation token isn't found");
            return;
        } catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::EmailNotFound $e) {
            $self->stash(error_title    => "Confirmation Error");
            $self->stash(error_message  => "The email isn't found");
            return;
        } catch($e) {
            MonkeyMan::Exception->throw($e);
        }
        if(defined($r_person_email->confirmed)) {
            $self->stash(error_title    => "Confirmation Error");
            $self->stash(error_message  => "The email is already confirmed");
            # TODO: Propose them to authenticate with the same email
            $self->stash(email_address  => $r_person_email->email)
                if(defined($r_person_email));
            return;
        }
        $r_person_email_confirmation->update({
            confirmed   => $now,
            valid_till  => $now
        });
        $r_person_email->update({
            confirmed   => $now,
            valid_since => $now
        });
        my $r_person = $r_person_email->search_related('person')->single;
        $self->stash->{'person_data'} = {
            first_name      =>   $r_person->first_name,
            middle_name     =>   $r_person->middle_name,
            last_name       =>   $r_person->last_name,
            email           => [ $r_person->search_related('person_emails')->filter_valid->get_column('email')->all ],
            language        =>   $r_person->search_related('language')->filter_valid->single->code,
            timezone        =>   $r_person->timezone
        };
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
