#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib("$RealBin/../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version :logging);

use Test::More (tests => 3);
use Method::Signatures;



my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'get_logger.t',
    app_description     => 'MonkeyMan::get_logger() testing script',
    app_version         => MM_VERSION
);

ok($monkeyman->_get_loggers->{&MM_PRIMARY_LOGGER} == $monkeyman->get_logger);
ok($monkeyman->get_logger == $monkeyman->get_logger);
ok($monkeyman->get_logger == $monkeyman->get_logger(&MM_PRIMARY_LOGGER));
