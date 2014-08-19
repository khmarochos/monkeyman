#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib("$Bin/../lib");

use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::Show;
use MonkeyMan::CloudStack::API;

use Getopt::Long;
use XML::LibXML;



my %opts;

eval { GetOptions(
    'h|help'                    => \$opts{'help'},
      'version'                 => \$opts{'version'},
    'c|config'                  => \$opts{'config'},
    'v|verbose+'                => \$opts{'verbose'},
    'q|quiet'                   => \$opts{'quiet'},
    'o|cond|conditions=s%{,}'   => \$opts{'conditions'},
    'x|xpath=s@'                => \$opts{'xpath'},
    's|short+'                  => \$opts{'short'}
); };
die(mm_sprintify("Can't GetOptions(): %s", $@))
    if($@);

if($opts{'help'})       { MonkeyMan::Show::help('vminfo');  exit; };
if($opts{'version'})    { MonkeyMan::Show::version;         exit; };
die("Mandatory conditions haven't been defined, see --help for more information")
    unless(defined($opts{'conditions'}));

my $mm = eval { MonkeyMan->new(
    config_file => $opts{'config'},
    verbosity   => $opts{'quiet'} ? 0 : ($opts{'verbose'} ? $opts{'verbose'} : 0) + 4
); };
die(mm_sprintify("Can't MonkeyMan->new(): %s", $@))
    if($@);

my $log = eval { Log::Log4perl::get_logger("MonkeyMan") };
die(mm_sprintify("The logger hasn't been initialized: %s", $@)) if($@);

my $cs = $mm->init_cloudstack;
die($mm->error_message) unless(defined($cs));

my $api = $cs->api;
die($cs->error_message) unless(defined($api));



my $virtualmachines = $api->run_command(
    parameters  => {
        command     => 'listVirtualMachines',
        listall     => 'true'
    }
);
$log->logdie($api->error_message) unless(defined($virtualmachines));



foreach my $condition (keys(%{ $opts{'conditions'} })) {

    $log->trace(mm_sprintify(
        "Checking for the condition: %s = %s",
            $condition,
            $opts{'conditions'}->{$condition}
    ));

    my $result = eval { XML::LibXML::Document->createDocument("1.0", "UTF-8"); };
    $log->logdie(mm_sprintify("Can't XML::LibXML::Document->createDocument(): %s", $@))
        if($@);

    my $result_main_node = eval { $result->createElement("listvirtualmachinesresponse"); };
    $log->logdie(mm_sprintify("Can't %s->createElement(): %s", $result, $@))
        if($@);

    eval { $result->addChild($result_main_node); };
    $log->logdie(mm_sprintify("Can't %s->addChild(): %s", $result, $@))
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
        $log->logdie(mm_sprintify("The %s condition isn't valid", $condition));
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


