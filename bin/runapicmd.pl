#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin qw($Bin);
use lib("$Bin/../lib");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;

# Use 3rd-party libraries
use TryCatch;
use Getopt::Long;
use XML::LibXML;
use Log::Log4perl;
use Mozilla::CA;



my %opts;

try {
    GetOptions(
        'h|help'                => \$opts{'help'},
          'version'             => \$opts{'version'},
        'c|config'              => \$opts{'config'},
        'v|verbose+'            => \$opts{'verbose'},
        'q|quiet'               => \$opts{'quiet'},
        'p|parameters=s%{,}'    => \$opts{'parameters'},
        'x|xpath=s@{,}'         => \$opts{'xpath'},
        'w|wait:0'              => \$opts{'wait'},
        's|short+'              => \$opts{'short'}
    );
} catch($e) {
    MonkeyMan::Exception->throw_f("Can't GetOptions(): %s", $e)
}

if($opts{'help'})       { MonkeyMan::Show::help('runapicmd');   exit; };
if($opts{'version'})    { MonkeyMan::Show::version;             exit; };
MonkeyMan::Exception->throw("Mandatory parameters haven't been defined, see --help for more information")
    unless(defined($opts{'parameters'}));

my $mm;

try {
    $mm = MonkeyMan->new(
        config_file => $opts{'config'},
        verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
    );
} catch(MonkeyMan::Exception $e) {
    $e->throw;
} catch($e) {
    MonkeyMan::Exception->throw_f("Can't MonkeyMan->new(): %s", $e);
}

my $log;

try {
    $log = Log::Log4perl::get_logger("MonkeyMan");
} catch($e) {
    MonkeyMan::Exception->throw_f("The logger hasn't been initialized: %s", $e);
}

my $cs = $mm->init_cloudstack;

my $api = $cs->api;



my $result;
try {
    $result = $api->run_command(
        parameters  => $opts{'parameters'},
        options     => {
            wait => $opts{'wait'}
        }
    );
} catch(MonkeyMan::Exception $e) {
    $e->throw;
} catch($e) {
    MonkeyMan::Exception->throw_f("An error has occuried while running the command: %s", $e);
}



if(defined($opts{'xpath'})) {
    foreach my $xpath (@{ $opts{'xpath'} }) {
        my $should_i_be_short = defined($opts{'short'}) ? $opts{'short'} : 0;
        my $nodes;
        try {
            $nodes = $api->query_xpath($result, $xpath);
        } catch(MonkeyMan::Exception $e) {
            $log->warn($e->message);
            next;
        } catch($e) {
            $log->warn($e);
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

