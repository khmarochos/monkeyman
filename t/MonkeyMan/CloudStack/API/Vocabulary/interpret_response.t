#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../../../lib");

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'interpret_response.t',
    app_description     => 'MonkeyMan::CloudStack::API::Vocabulary::interpret_response testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => { 'x|xml-file=s' => 'xml_file' }
);

use Test::More;
use XML::LibXML;

my $logger                  = $monkeyman->get_logger;
my $cloudstack              = $monkeyman->get_cloudstack;
my $api                     = $cloudstack->get_api;

my $dom = XML::LibXML->load_xml(location => $monkeyman->get_parameters->get_xml_file);

#$api->interpret_response(dom => $dom, type => 'VirtualMachine', action => 'create', requested => { element => 'element' });
$api->interpret_response(dom => $dom, type => 'VirtualMachine', requested => { element => 'element' });
