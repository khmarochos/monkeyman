package MaitreD::Controller::API::V1::WebMessage;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use Method::Signatures;



method list {

    my $result_data;
    my $result_code;
    my $session_uuid = $self->session('session_uuid');
    my $now = DateTime->now();

    if(defined(my $message_id = $self->param('message_id'))) {
        my $r_message = $self
            ->md_schema
            ->resultset('Session')
            ->search({ uuid => $session_uuid })
            ->filter_validated
            ->single
            ->messages
            ->filter_validated
            ->search({ 'message.id' => $message_id })
            ->single;
        if(defined($r_message)) {
            $result_code = 200;
            $result_data = {
                message     => {
                    date        => $r_message->valid_since,
                    type        => $r_message->type,
                    subject     => $r_message->subject,
                    text        => $r_message->text
                }
            };
            if(!$self->param('peek')) {
                $r_message->message_x_sessions->update({ received => $now });
            }
        } else {
            $result_code = 404;
            $result_data = {
                error_message   => 'No such message'
            }
        }
    } else {
        my @messages;
        foreach my $r_message ($self
            ->md_schema
            ->resultset('Session')
            ->search({ uuid => $session_uuid })
            ->filter_validated
            ->single
            ->messages
            ->filter_validated
            ->search({ received => undef })
            ->all
        ) {
            push(@messages, {
                id      => $r_message->id,
                date    => $r_message->valid_since
            });
        }
        $result_code = 200;
        $result_data = { messages => \@messages };
    }
    $self->render(
        json    => $result_data,
        status  => $result_code
    );

}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
