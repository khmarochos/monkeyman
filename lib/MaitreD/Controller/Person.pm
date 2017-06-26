package MaitreD::Controller::Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use HyperMouse::Schema::ValidityCheck::Constants ':ALL';
use Mojolicious::Validator;
use Method::Signatures;
use TryCatch;
use Switch;
use DateTime;
use DateTime::Duration;
use Data::UUID;
use MaitreD::Extra::API::V1::TemplateSettings;
use Data::Dumper;



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

    my $r_person;

    try {
        $r_person = $self
            ->hm_schema
            ->resultset("Person")
            ->authenticate(
                email       => $email,
                password    => $password
            );
    } catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::PersonEmailNotFound $e) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Authentication Error',
            text        => 'The email isn\'t registered'
        );
        return(0);
    } catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::PersonNotFound $e) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Authentication Error',
            text        => 'The account isn\'t enabled'
        );
        return(0);
    } catch(HyperMouse::Schema::ResultSet::Person::Exception::PersonNotFound $e) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Authentication Error',
            text        => 'The account isn\'t enabled'
        );
        return(0);
    } catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::PersonPasswordNotFound $e) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Authentication Error',
            text        => 'The account isn\'t enabled'
        );
        return(0);
    } catch(HyperMouse::Schema::ResultSet::PersonEmail::Exception::PersonPasswordIncorrect $e) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Authentication Error',
            text        => 'The password isn\'t correct'
        );
        return(0);
    }

    $self->session(authorized_person_email => $email);

    return($r_person);

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
    $self->web_message_send(
        type        => 'INFO',
        subject     => 'Logged Out',
        text        => 'We\'ll be happy to see you soon!'
    );

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
            $self->web_message_send(
                type        => 'ERROR',
                subject     => 'Registration Error',
                text        => 'The data entered isn\'t valid'
            );
            return;
        } elsif($hm_schema->resultset('PersonEmail')->search({ email => $v->param('email') })->filter_validated->all > 0) {
            $self->web_message_send(
                type        => 'ERROR',
                subject     => 'Registration Error',
                text        => sprintf('The %s email is already registered', $v->param('email'))
            );
            return;
        }

        my $now = DateTime->now;
        my $person_name;
        (
            $person_name->{'first'},
            $person_name->{'middle'},
            $person_name->{'last'}
        ) = $v->param('full_name')      =~ /^(?:(\S+)?\s+)?(?:(\S.+\S)?\s+)?(\S+)$/;
        my $person_language_id = $hm_schema
            ->resultset('Language')
            ->search({ code => $v->param('language') })
            ->filter_validated
            ->single
            ->id;
        my $person_datetime_format_id = $hm_schema
            ->resultset('DatetimeFormat')
            ->filter_validated
            ->first
            ->id;

        my $person_id = ($hm_schema->resultset('Person')->populate([ {
            valid_since         => undef,
            valid_till          => undef,
            removed             => undef,
            first_name          => $person_name->{'first'},
            middle_name         => $person_name->{'middle'},
            last_name           => $person_name->{'last'},
            language_id         => $person_language_id,
            datetime_format_id  => $person_datetime_format_id,
            timezone            => $v->param('timezone')
        } ]))[0]->id;

        $self->_add_email(
            now                 => $now,
            email               => $v->param('email'),
            person_id           => $person_id,
            person_name         => $person_name,
            person_confirmation => 1
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

                $v->required(qw/ first-name         trim /);
                $v->optional(qw/ middle-name        trim /);
                $v->required(qw/ last-name          trim /);
                $v->required(qw/ password           trim /);
                $v->required(qw/ password-repeat    trim /);
                # TODO: validate other fields

                my($r_person, $r_person_email, $r_person_email_confirmation) =
                    $self->_find_by_confirmation_token($token, 1);
                # If an error occuried, stop processing
                unless(defined($r_person)) {
                    $self->web_message_send(
                        type        => 'ERROR',
                        subject     => 'Confirmation Error',
                        text        => 'The confirmation token isn\'t valid'
                    );
                    return;
                }

                $hm_schema->txn_begin;

                $r_person->update({
                    valid_since     => $now,
                    first_name      => $v->param('first-name'),
                    middle_name     => $v->param('middle-name'),
                    last_name       => $v->param('last-name'),
                });

                foreach my $email_field (grep(/^email-/, keys(%{ $self->req->params->to_hash }))) {
                    my $email = $v->required($email_field, 'trim')->param;
                    my $email_found;
                    foreach my $r_person_email ($hm_schema
                        ->resultset('PersonEmail')
                        ->search({ email => $email })
                        ->filter_validated(mask => 0b000101)
                        ->all
                    ) {
                        if($r_person_email->person_id != $r_person->id) {
                            $self->web_message_send(
                                type        => 'ERROR',
                                subject     => 'Confirmation Error',
                                text        => sprintf("The %s email belongs to other person", $email)
                            );
                            $self->redirect_to('person.confirm', token => $token);
                        }
                        $email_found = $r_person_email;
                    }
                    unless(defined($email_found)) {
                        $self->_add_email(
                            now                 => $now,
                            email               => $email,
                            person_id           => $r_person->id,
                            person_confirmation => 1,
                            person_name         => {
                                first   => $v->param('first-name'),
                                middle  => $v->param('middle-name'),
                                last    => $v->param('last-name')
                            }
                        );
                    }
                }

                $hm_schema
                    ->resultset('PersonPassword')
                    ->create({
                        valid_since => $now,
                        valid_till  => undef,
                        removed     => undef,
                        password    => $v->param('password'),
                        person_id   => $r_person->id
                    });

                $hm_schema->txn_commit;

                $self->web_message_send(
                    type        => 'INFO',
                    subject     => 'Confirmation Success',
                    text        => 'The account is activated'
                );
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

        my($r_person, $r_person_email, $r_person_email_confirmation) =
            $self->_find_by_confirmation_token($token, 1);
        # If an error occuried, stop processing
        return
            unless(defined($r_person));

        unless(defined($r_person_email->valid_since)) {
            $r_person_email->update({
                valid_since => $now
            });
            $self->web_message_send(
                type        => 'INFO',
                subject     => 'Confirmation Success',
                text        => sprintf('The %s email is activated', $r_person_email->email)
            );
        }

        if(defined($r_person->valid_since)) {

            # The person has been confirmed already
            $self->web_message_send(
                type        => 'INFO',
                subject     => 'Confirmation Success',
                text        => sprintf('The person is activated already')
            );
            $self->redirect_to('person.login');

        } else {

            # The person needs to be confirmed
            $self->stash->{'person_data'} = {
                first_name      =>   $r_person->first_name,
                middle_name     =>   $r_person->middle_name,
                last_name       =>   $r_person->last_name,
                email           => [ $r_person->search_related('person_emails')->filter_validated->get_column('email')->all ],
                language        =>   $r_person->search_related('language')->filter_validated->single->code,
                timezone        =>   $r_person->timezone
            };

            $self->web_message_send(
                type        => 'WARNING',
                subject     => 'Confirmation Needed',
                text        => 'Some personal data needs to be submitted and confirmed'
            );

        }

    }

}



method _find_by_confirmation_token(Str $token!, Bool $email_confirmed!) {

    my $checks_failed;
    
    $checks_failed = {};
    my $r_person_email_confirmation = $self->hm_schema
        ->resultset('PersonEmailConfirmation')
        ->search({ token => $token })
        ->filter_validated(
            mask            => 0b000111,
            checks_failed   => $checks_failed
        )
        ->single;
    unless(defined($r_person_email_confirmation)) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Confirmation Error',
            text        => $checks_failed->{ 0b000001 }
                ? 'The confirmation token is expired'
                : 'The confirmation token isn\'t found'
        );
        return;
    }

    $checks_failed = {};
    my $r_person_email = $r_person_email_confirmation
        ->search_related('person_email')
        ->filter_validated(
            mask            => 0b000101,
            checks_failed   => $checks_failed
        )
        ->single;
    unless(defined($r_person_email)) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Confirmation Error',
            text        => 'The email isn\'t found'
        );
        return;
    }

    $checks_failed = {};
    my $r_person = $r_person_email
        ->search_related('person')
        ->filter_validated(
            mask            => 0b000101,
            checks_failed   => $checks_failed
        )
        ->single;
    unless(defined($r_person)) {
        $self->web_message_send(
            type        => 'ERROR',
            subject     => 'Confirmation Error',
            text        => 'The person isn\'t found'
        );
        return;
    }

    return($r_person, $r_person_email, $r_person_email_confirmation);

}



method _add_email(
    DateTime    :$now!,
    Str         :$email!,
    Int         :$person_id!,
    HashRef     :$person_name,
    Bool        :$person_confirmation? = 0
) {

    my $hm_schema = $self->hm_schema;

    my $person_email_id = ($hm_schema->resultset('PersonEmail')->populate([ {
        valid_since         => undef, 
        valid_till          => undef,
        removed             => undef,
        email               => $email,
        person_id           => $person_id
    } ]))[0]->id;

    my $token = lc(Data::UUID->new->create_str());

    $hm_schema->resultset('PersonEmailConfirmation')->create({
        valid_since         => $now,
        valid_till          => $now->add(DateTime::Duration->new(hours => 12)), # FIXME: declare a constant!
        removed             => undef,
        token               => $token,
        person_email_id     => $person_email_id
    });

    $self->hypermouse->get_mailer->send_message_from_template(
        subject         => 'Hello, world!',
        recipients      => $email,
        template_id     => $person_confirmation
            ? 'maitre-d::person_confirmation_needed'
            : 'maitre-d::email_confirmation_needed',
        template_values => {
            first_name          => $person_name->{'first'},
            confirmation_code   => $token,
            confirmation_href   => 'https://maitre-d.tucha.ua/person/confirm/' . $token # FIXME: use url_for()
        }
    );

    $self->web_message_send(
        type        => 'WARNING',
        subject     => 'Confirmation Needed',
        text        => sprintf("The %s email needs to be confirmed, the message is sent", $email)
    );
}

method list {
    my $settings = $MaitreD::Extra::API::V1::TemplateSettings::settings;
    my $key      = $self->stash->{'related_element'} || 'person';
    $key .= '->list'; 
    $self->stash->{'extra_settings'} =
        $settings->{ $key };
    
    $self->stash->{'title'} = "Person -> " . $self->stash->{'filter'};
    
}

method list_old {

    my $mask_permitted_d = 0b000111; # FIXME: implement HyperMosuse::Schema::PermissionCheck and define the PC_* constants
    my $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    switch($self->stash->{'filter'}) {
        case('all') {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE;
        }
        case('active') {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
        }
        case('archived') {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_EXPIRED;
        }
    }

    switch($self->stash->{'related_element'}) {
        case('') {
            $self->stash->{'title'} = "Person -> " . $self->stash->{'filter'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $self->stash->{'authorized_person_result'}->id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Person-[everything]>-Person' => { } ]
                    )
                    ->all
             ]);
        }
        case('contractor') {
            $self->stash->{'title'} = "Contractor -> " . $self->stash->{'filter'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('Contractor')
                    ->search({ id => $self->stash->{'related_id'} })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Contractor->-Person' => { } ]
                    )
                    ->all
            ]);
        }
        case('provisioning_agreement') {
            $self->stash->{'title'} = "ProvisioningAgreement -> " . $self->stash->{'filter'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->search({ id => $self->stash->{'related_id'} })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningAgreement->-Person' => { } ]
                    )
                    ->all
            ]);
        }
    }
    
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
