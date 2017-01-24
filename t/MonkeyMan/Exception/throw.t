#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Logger qw(mm_sprintf);
use MonkeyMan::Exception qw(Test);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'throw.t',
    app_description     => 'MonkeyMan::Exception::throw() testing script',
    app_version         => $MonkeyMan::VERSION
);

my $logger          = $monkeyman->get_logger;
my $cloudstack      = $monkeyman->get_cloudstack;
my $api             = $cloudstack->get_api;

use TryCatch;
use Test::More tests => 2;

my $catched;
my $thirteen = 13;
try {
    main::Exception::Test->throwf('Zaloopa%d', $thirteen);
} catch(main::Exception::Test $e) {
    $catched = $e->message;
    ok($catched, 'main::Exception::Test has been catched');
} catch(MonkeyMan::Exception $e) {
    $catched = $e->message;
    ok($catched, 'MonkeyMan::Exception has been catched');
} catch($e) {
    $catched = $e;
    fail($catched);
}

is($catched, mm_sprintf('Zaloopa%d', $thirteen), "The exception has been catched");
