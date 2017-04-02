package Mojolicious::Plugin::WebMessages;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Method::Signatures;



has 'mojo_app' => (
    is          => 'ro',
    isa         => 'Object',
    reader      => '_get_mojo_app',
    writer      => '_set_mojo_app',
    predicate   => '_has_mojo_app',
    lazy        => 0
);

has schema => (
    is          => 'ro',
    isa         => 'MaitreD::Schema',
    reader      => '_get_schema',
    writer      => '_set_schema',
    predicate   => '_has_schema',
    required    => 0
);



method register(
    Object          $app!,
    HashRef         $configuration!
) {
    $self->_set_mojo_app($app);
    $self->_set_schema($configuration->{'schema'});

    $app->helper(web_message_send => sub { my $c = shift; $self->web_message_send(@_, controller => $c) });

}



method web_message_send(
    Object      :$controller!,
    Str         :$type?,
    DateTime    :$valid_since?,
    DateTime    :$valid_till?,
    Str         :$subject?,
    Str         :$text!,
    ArrayRef    :$recipients
) {
    $type = 'INFO'
        unless(defined($type));
    $valid_since = DateTime->now
        unless(defined($valid_since));
    $recipients = [ $controller->session('session_uuid') ]
        unless(defined($recipients) && @{ $recipients });
    $self
        ->_get_schema
        ->resultset('Message')
        ->create({
            type        => $type,
            valid_since => $valid_since,
            valid_till  => $valid_till,
            subject     => $subject,
            text        => $text,
            message_x_sessions => [
                map({
                    {
                        valid_since => $valid_since,
                        valid_till  => $valid_till,
                        session_id  => $_
                    }
                } $self->_recipients(@{ $recipients }))
            ]
        });
}

method _recipients(@recipients_uuid) {
    my @recipients_id;
    foreach my $recipient_uuid (@recipients_uuid) {
        if(defined(my $r_recipient = $self
            ->_get_schema
            ->resultset('Session')
            ->search({ uuid => $recipient_uuid })
            ->filter_valid
            ->single
        )) {
            push(@recipients_id, $r_recipient->id);
        } else {
            push(@recipients_id, undef);
        }
    }
    return(@recipients_id);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
