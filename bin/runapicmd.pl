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
if($@) {
    die("Can't GetOptions(): $@");
}

if($opts{'help'})       { MonkeyMan::Show::help('runapicmd');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;             exit; };
unless(defined($opts{'parameters'})) {
    die("Mandatory parameters haven't been defined, see --help for more information");
}

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die("Can't MonkeyMan::new(): $@") if($@);

my $log = $mm->logger;
die($mm->error_message) unless(defined($log));

my $api = $mm->init_cloudstack_api;
die($mm->error_message) unless(defined($api));

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
        my @nodes = $api->query_xpath($result, $xpath);
        foreach my $node (@nodes) {
            print(
                ($should_i_be_short > 0 ? "" : "$xpath = ") .
                $node->textContent .
                ($should_i_be_short < 2 ? "\n" : " ")
            );
        }
    }
} else {
    print($result->toString(1));
}



