package MaitreD::Controller::Client;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Mojolicious::Controller';

use Method::Signatures;
use Data::UUID;
use DateTime;
use DateTime::Duration;



method sesh {

    my $now = DateTime->now;
    my $session_uuid_given = $self->session('session_uuid');
    my $session_uuid;

    while(1) {
        $session_uuid = defined($session_uuid_given)
                              ? $session_uuid_given
                              : lc(Data::UUID->new->create_str());
        if(defined($self
            ->md_schema
            ->resultset('Session')
            ->search({ uuid => $session_uuid })
            ->filter_validated
            ->single
        )) {
            last if (defined($session_uuid_given));
            # If the session with the new UUID has is found AND this UUID had
            # been given to us by the client (as a session variable), we will
            # state that the given session is found. But if the UUID had been
            # generated by ourselves, we'll have to generate a new one now...
        } else {
            last if(!defined($session_uuid_given));
            # If the session wuth the new UUID is NOT found AND this UUID had
            # been generated by ourselves, everything seems to be correct, so
            # we will bail out the loop. But if the UUID had been given to us
            # by the client, it may mean that their session has been expired,
            # so we'll have to generate a new one.
            $session_uuid_given = undef;
        }
    }

    unless(defined($session_uuid_given)) {
        # We had to generate a new UUID, so now we need to update the DB now.
        $self
            ->md_schema
            ->resultset('Session')
            ->populate([ {
                valid_since => $now,
                valid_till  => $now->add(DateTime::Duration->new(hours => 12)), # FIXME: declare a constant!
                uuid        => $session_uuid
            } ]);
        $self->session(session_uuid => $session_uuid);
    }

    return($session_uuid);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
