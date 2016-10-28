#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Constants qw(:version :logging);

use Test::More (tests => 2);
use Method::Signatures;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_logger.t',
    app_description     => 'MonkeyMan::get_logger() testing script',
    app_version         => MM_VERSION
);

ok($monkeyman->get_logger == $monkeyman->get_logger);
ok($monkeyman->get_logger == $monkeyman->get_logger($monkeyman->get_logger_plug->get_actor_default));
