#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;

use Test::More (tests => 1);



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'send_message.t',
    app_description     => 'MonkeyMan::Mailer::send_message() testing script',
    app_version         => $MonkeyMan::VERSION
);
my $mailer = $monkeyman->get_mailer;

$mailer->send_message_from_template(
    recipients      => 'v.melnik@uplink.ua',
    subject         => 'Hello, world!',
    template_id     => 'maitre-d::person_confirmation_needed',
    template_values => {
        first_name          => 'Vasya',
        confirmation_code   => '131313',
        confirmation_href   => 'https://maitre-d.tucha.ua/...'
    }
);
