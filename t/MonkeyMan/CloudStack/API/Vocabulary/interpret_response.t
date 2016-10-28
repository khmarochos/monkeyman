#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use MonkeyMan::Constants qw(:version);

use File::Slurp;

my $monkeyman = MonkeyMan->new(
    app_code            => undef,
    app_name            => 'interpret_response.t',
    app_description     => 'MonkeyMan::CloudStack::API::Vocabulary::interpret_response testing script',
    app_version         => MM_VERSION,
    parameters_to_get   => { 'x|xml-file=s' => 'xml_file' }
);

use Test::More (tests => 1);
use XML::LibXML;

my $logger                  = $monkeyman->get_logger;
my $cloudstack              = $monkeyman->get_cloudstack;
my $api                     = $cloudstack->get_api;

my $dom_text = $monkeyman->get_parameters->has_xml_file ?
    read_file($monkeyman->get_parameters->getxml_file) :
    <<'__END_OF_XML__';
<?xml version="1.0" encoding="UTF-8"?>
<queryasyncjobresultresponse cloud-stack-version="4.8.0">
  <accountid>e5447a8f-b0f1-4b00-9d1e-756ab3981987</accountid>
  <userid>b77f23fa-5bfa-4c05-88c3-a00b10f6f60c</userid>
  <cmd>org.apache.cloudstack.api.command.user.vm.DeployVMCmd</cmd>
  <jobstatus>1</jobstatus>
  <jobprocstatus>0</jobprocstatus>
  <jobresultcode>0</jobresultcode>
  <jobresulttype>object</jobresulttype>
  <jobresult>
    <virtualmachine>
      <id>58f6c072-12bf-46f8-9de3-a3cbda128fdd</id>
      <name>VM-58f6c072-12bf-46f8-9de3-a3cbda128fdd</name>
      <displayname>VM-58f6c072-12bf-46f8-9de3-a3cbda128fdd</displayname>
      <account>monkeyman@tucha.ua</account>
      <userid>b77f23fa-5bfa-4c05-88c3-a00b10f6f60c</userid>
      <username>monkeyman@tucha.ua</username>
      <domainid>22452f80-4af5-452c-a894-06b02db6d43c</domainid>
      <domain>demo</domain>
      <created>2016-07-21T08:58:44+0000</created>
      <state>Stopped</state>
      <haenable>true</haenable>
      <zoneid>f09fe8dd-3567-4ff6-ac3a-2f85dec2636d</zoneid>
      <zonename>las</zonename>
      <templateid>d66c1128-e255-49f2-83a8-3644fa33885a</templateid>
      <templatename>Windows-LiveCD </templatename>
      <templatedisplaytext>Windows-LiveCD </templatedisplaytext>
      <passwordenabled>false</passwordenabled>
      <isoid>d66c1128-e255-49f2-83a8-3644fa33885a</isoid>
      <isoname>Windows-LiveCD </isoname>
      <isodisplaytext>Windows-LiveCD </isodisplaytext>
      <serviceofferingid>97d74503-d609-4edb-8633-748d400aad5e</serviceofferingid>
      <serviceofferingname>Custom Compute Offering (3GHz Max)</serviceofferingname>
      <diskofferingid>a4fb67e8-62c8-4b37-b68a-a27e30fa0c63</diskofferingid>
      <diskofferingname>Basic Storage Tier</diskofferingname>
      <cpunumber>2</cpunumber>
      <cpuspeed>2000</cpuspeed>
      <memory>1024</memory>
      <guestosid>de4fb864-0b3f-11e6-893a-005056901750</guestosid>
      <rootdeviceid>0</rootdeviceid>
      <rootdevicetype>ROOT</rootdevicetype>
      <nic>
        <id>8de01670-9042-4894-a9dd-376b6c4cd82a</id>
        <networkid>a3933f8c-37c3-455f-878c-a0f48337aab2</networkid>
        <networkname>GUEST-66.209.89.128/27</networkname>
        <netmask>255.255.255.224</netmask>
        <gateway>66.209.89.129</gateway>
        <ipaddress>66.209.89.154</ipaddress>
        <isolationuri>vlan://998</isolationuri>
        <broadcasturi>vlan://998</broadcasturi>
        <traffictype>Guest</traffictype>
        <type>Shared</type>
        <isdefault>true</isdefault>
        <macaddress>06:f7:5c:00:01:3e</macaddress>
      </nic>
      <hypervisor>KVM</hypervisor>
      <isdynamicallyscalable>false</isdynamicallyscalable>
      <ostypeid>168</ostypeid>
      <jobid>44be48fa-dd32-49cb-bdb8-cc1c7cf3cbf1</jobid>
      <jobstatus>0</jobstatus>
    </virtualmachine>
  </jobresult>
  <jobinstancetype>VirtualMachine</jobinstancetype>
  <jobinstanceid>58f6c072-12bf-46f8-9de3-a3cbda128fdd</jobinstanceid>
  <created>2016-07-21T08:58:45+0000</created>
  <jobid>44be48fa-dd32-49cb-bdb8-cc1c7cf3cbf1</jobid>
</queryasyncjobresultresponse>
__END_OF_XML__

my $dom = XML::LibXML->load_xml(string => $dom_text);

ok(
    $api
        ->interpret_response(dom => $dom, requested => { element => 'element' })
            ->DOES('MonkeyMan::CloudStack::API::Roles::Element')
);
