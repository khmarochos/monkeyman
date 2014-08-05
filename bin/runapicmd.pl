#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib("$Bin/../lib");

use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;

use Getopt::Long;
use XML::LibXML;
use Log::Log4perl;



my %opts;

eval { GetOptions(
    'h|help'                => \$opts{'help'},
      'version'             => \$opts{'version'},
    'c|config'              => \$opts{'config'},
    'v|verbose+'            => \$opts{'verbose'},
    'q|quiet'               => \$opts{'quiet'},
    'p|parameters=s%{,}'    => \$opts{'parameters'},
    'x|xpath=s@{,}'         => \$opts{'xpath'},
    'w|wait:0'              => \$opts{'wait'},
    's|short+'              => \$opts{'short'}
); };
die(mm_sprintify("Can't GetOptions(): %s", $@))
    if($@);

if($opts{'help'})       { MonkeyMan::Show::help('runapicmd');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;             exit; };
die("Mandatory parameters haven't been defined, see --help for more information")
    unless(defined($opts{'parameters'}));

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die(mm_sprintify("Can't MonkeyMan->new(): %s", $@))
    if($@);

my $log = eval { Log::Log4perl::get_logger("MonkeyMan") };
die(mm_sprintify("The logger hasn't been initialized", $@))
    if($@);

my $api = $mm->cloudstack_api;
$log->logdie($mm->error_message) unless(defined($api));



my $result = $api->run_command(
    parameters  => $opts{'parameters'},
    options     => {
        wait => $opts{'wait'}
    }
);
$log->logdie($api->error_message) unless(defined($result));



if(defined($opts{'xpath'})) {
    foreach my $xpath (@{ $opts{'xpath'} }) {
        my $should_i_be_short = defined($opts{'short'}) ? $opts{'short'} : 0;
        my $nodes = $api->query_xpath($result, $xpath);
        unless(defined($nodes)) {
            $log->warn($api->error_message);
            next;
        }
        foreach my $node (@{$nodes}) {
            print(
                (($should_i_be_short == 1) ? "$xpath = " : "") .
                (($should_i_be_short  < 1) ? $node->toString(1) : $node->textContent) .
                "\n"
            );
        }
    }
} else {
    print($result->toString(1));
}

