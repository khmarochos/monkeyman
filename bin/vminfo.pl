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



my %opts;

try {
    GetOptions(
        'h|help'                    => \$opts{'help'},
          'version'                 => \$opts{'version'},
        'c|config'                  => \$opts{'config'},
        'v|verbose+'                => \$opts{'verbose'},
        'q|quiet'                   => \$opts{'quiet'},
        'o|cond|conditions=s%{,}'   => \$opts{'conditions'},
        'x|xpath=s@'                => \$opts{'xpath'},
        's|short+'                  => \$opts{'short'}
    );
} catch($e) {
    MonkeyMan::Exception->throw_f("Can't GetOptions(): %s", $e)
}

if($opts{'help'})       { MonkeyMan::Show::help('vminfo');  exit; };
if($opts{'version'})    { MonkeyMan::Show::version;         exit; };
MonkeyMan::Exception->throw("Mandatory parameters haven't been defined, see --help for more information")
    unless(defined($opts{'conditions'}));

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
    MonkeyMan::Exception->throw_f("The logger hasn't been initialized", $e);
}

my $cs = $mm->init_cloudstack;

my $api = $cs->api;



my $virtualmachines = $api->run_command(
    parameters  => {
        command     => 'listVirtualMachines',
        listall     => 'true'
    }
);



foreach my $condition (keys(%{ $opts{'conditions'} })) {

    $log->trace(mm_sprintf(
        "Checking for the condition: %s = %s",
            $condition,
            $opts{'conditions'}->{$condition}
    ));

    my $result = eval { XML::LibXML::Document->createDocument("1.0", "UTF-8"); };
    $log->logdie(mm_sprintf("Can't XML::LibXML::Document->createDocument(): %s", $@))
        if($@);

    my $result_main_node = eval { $result->createElement("listvirtualmachinesresponse"); };
    $log->logdie(mm_sprintf("Can't %s->createElement(): %s", $result, $@))
        if($@);

    eval { $result->addChild($result_main_node); };
    $log->logdie(mm_sprintf("Can't %s->addChild(): %s", $result, $@))
        if($@);

    # Analyzing the condition

    my $xpath;
    if($condition eq 'has_ipaddress') {
        $xpath =  "/listvirtualmachinesresponse/virtualmachine[./nic/ipaddress='" .
            $opts{'conditions'}->{'has_ipaddress'} .
            "']"
    } elsif($condition eq 'has_instancename') {
        $xpath = "/listvirtualmachinesresponse/virtualmachine[instancename='" .
            $opts{'conditions'}->{'has_instancename'} .
            "']"
    } elsif($condition eq 'has_displayname') {
        $xpath = "/listvirtualmachinesresponse/virtualmachine[displayname='" .
            $opts{'conditions'}->{'has_displayname'} .
            "']"
    } elsif($condition eq 'has_id') {
        $xpath = "/listvirtualmachinesresponse/virtualmachine[id='" .
            $opts{'conditions'}->{'has_id'} .
            "']"
    } elsif($condition eq 'has_domain') {
        $xpath = "/listvirtualmachinesresponse/virtualmachine[domain='" .
            $opts{'conditions'}->{'has_domain'} .
            "']"
    } elsif($condition eq 'has_state') {
        $xpath = "/listvirtualmachinesresponse/virtualmachine[state='" .
            $opts{'conditions'}->{'has_state'} .
            "']"
    } else {
        $log->logdie(mm_sprintf("The %s condition isn't valid", $condition));
    }

    # Getting the list of matched nodes for the condition and adding them to
    # the resulting DOM

    my $nodes = $api->query_xpath($virtualmachines, $xpath);
    unless(defined($nodes)) {
        $log->warn($api->error_message);
        next;
    }
    foreach my $node (@{ $nodes }) {
        eval { $result_main_node->addChild($node); };
        if($@) {
            $log->warn("Can't %s->addChild(): %s", $result_main_node, $@);
            next;
        }
    }
    if($api->has_errors) {
        $log->warn($api->error_message);
        next;
    }

    # Now don't forget to update the list of virtual machines, so only matched
    # ones shall be left there!
 
    $virtualmachines = $result;

}



if(defined($opts{'xpath'})) {
    my $should_i_be_short = defined($opts{'short'}) ? $opts{'short'} : 0;
    foreach my $xpath (@{ $opts{'xpath'} }) {
        my $nodes = $api->query_xpath($virtualmachines, $xpath);
        unless(defined($nodes)) {
            $log->warn($api->error_message);
            next;
        }
        foreach my $node (@{ $nodes }) {
            print(
                (($should_i_be_short == 1) ? "$xpath = " : "") .
                (($should_i_be_short  < 1) ? $node->toString(1) : $node->textContent) .
                "\n"
            );
        }
        if($api->has_errors) {
            $log->warn($api->error_message);
            next;
        }
    }
} else {
    print($virtualmachines->toString(1));
}


