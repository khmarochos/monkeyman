#!/usr/bin/env perl

# Use pragmas
use strict;
use warnings;

# Find the libraries-directory
use FindBin qw($Bin);
use lib("$Bin/../lib");

# Use my own modules
use MonkeyMan;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::API::Element::Domain;

use Method::Signatures;



MonkeyMan->new(
    app_name            => 'vminfo',
    app_description     => 'The utility to get information about a virtual machine',
    app_version         => '2.0.0-rc.1',
    app_usage_help      => \&vminfo_usage,
    app_code            => \&vminfo_app,
    parameters_to_get   => {
        'o|cond|conditions=s%{,}'   => 'conditions',
        'x|xpath=s@'                => 'xpath',
        's|short+'                  => 'short'
    }
);



func vminfo_app(MonkeyMan $mm!) {

#    $mm->get_cloudstack->get_api->run_command(
#        parameters => {
#            command     => 'disableUser',
#            id          => '2741357e-7ea9-4dfc-b3ff-43e2efd94736'
#        },
#        wait => 1
#    );

#    my $result = $mm->get_cloudstack->get_api->run_command(
#        parameters => {
#            command     => 'listVirtualMachines',
#            domainid    => '6cd7f13c-e1c7-437d-95f9-e98e55eb200d'
#        }
#    );
#    print(mm_sprintf("%s\n", $result->toString(1)));

    foreach my $d ($mm->get_cloudstack->get_api->get_elements(
        type        => 'Domain',
        criterions  => { id  => '6cd7f13c-e1c7-437d-95f9-e98e55eb200d' }
    )) {
        print(mm_sprintf("The %s %s's ID is %s\n", $d, $d->get_type(noun => 1), $d->get_id));
        foreach my $vm ($d->get_related(type => 'VirtualMachine')) {
            $vm->refresh_dom;
            print(mm_sprintf("The %s %s's ID is %s\n", $vm, $vm->get_type(noun => 1), $vm->get_id));
        }
    }



}



func vminfo_usage {

    return(<<__END_OF_USAGE_HELP__
This application recognizes the following parameters:

    -o <condition>, --condition <condition>
        [mul]       Look up for virtual machines by certain conditions
    -x <query>, --xpath <query>
        [opt] [mul] Apply some XPath-queries
    -s, --short
        [opt] [mul] Get the result in a short form
__END_OF_USAGE_HELP__
    );

}
