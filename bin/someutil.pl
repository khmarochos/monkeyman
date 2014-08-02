#!/usr/bin/perl

use strict;
use warnings;

use feature qw(switch);

use FindBin qw($Bin);

use lib("$Bin/../lib");

use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;
use MonkeyMan::SomeClass;

use Getopt::Long;



my %opts;

eval { GetOptions(
    'h|help'        => \$opts{'help'},
      'version'     => \$opts{'version'},
    'c|config'      => \$opts{'config'},
    'v|verbose+'    => \$opts{'verbose'},
    'q|quiet'       => \$opts{'quiet'}
); };
die(mm_sprintify("Can't GetOptions(): %s", $@))
    if($@);

if($opts{'help'})       { MonkeyMan::Show::help('someutil');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;            exit; };

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die(mm_sprintify("Can't MonkeyMan->new(): %s", $@))
    if($@);

my $log = eval { Log::Log4perl::get_logger("MonkeyMan") };
die(mm_sprintify("The logger hasn't been initialized: %s", $@))
    if($@);



my $some_object = eval { MonkeyMan::SomeClass->new(mm => $mm); };
$log->logdie(mm_sprintify("Can't MonkeyMan::SomeClass->new(): %s", $@))
    if($@);

my $result = $some_object->some_method(
    something => 'cup of tea'
);
$log->logdie($some_object->error_message)
    if($some_object->has_errors);



$log->info(mm_sprintify("%s", $result));



exit 0;
