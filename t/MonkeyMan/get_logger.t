#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../lib");

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

ok($monkeyman->_get_loggers->{$monkeyman->_get_default_logger_id} == $monkeyman->get_logger);
ok($monkeyman->get_logger == $monkeyman->get_logger);
ok($monkeyman->get_logger == $monkeyman->get_logger($monkeyman->_get_default_logger_id));
