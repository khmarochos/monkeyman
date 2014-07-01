package MonkeyMan::Show;

use strict;
use warnings;
use feature "switch";

use FindBin qw($Bin);

use lib("$Bin/../lib");

use MonkeyMan::Constants;



sub help {

    my $mode = shift;

    version();

    print(<<__END_OF_GLOBAL_HELP_MESSAGE__

Usage: $0 [OPTIONS]

GLOBAL OPTIONS:
    -h,   --help
        [opt] Prints this message and exits
          --version
        [opt] Prints only verion information and exits
    -c ?, --config ?
        [opt] The main configuration file
    -v,   --verbose
        [opt] [mul] Increases verbosity
    -q,   --quiet
        [opt] [mul] Decreases verbosity

__END_OF_GLOBAL_HELP_MESSAGE__
    );

    given($mode) {
        when('runapicmd') {
            print(<<__END_OF_RUNAPICMD_HELP_MESSAGE__

MODULE'S PURPOURSE:
The purpourse of this module is to send commands to CloudStack's API and
to show their results.

MODULE-SPECIFIC OPTIONS:
    -p ?, --parameters ?
        [req] [mul] The API command and its parameters
    -w ?, --wait ?
        [opt] To wait some seconds for an async job: if the number is
        omitted, it will wait for the result as much as it's needed, but
        it won't wait for the result bu default, jobid it to be returned
    -x ?, --xpath ?
        [opt] [mul] To apply some XPath-queries
    -s,   --short
        [opt] [mul] To get the result in a short form

__END_OF_RUNAPICMD_HELP_MESSAGE__
            );
        } when('vminfo') {
            print(<<__END_OF_VMINFO_HELP_MESSAGE__

MODULE'S PURPOURSE:
The purpourse of this module is to get information about virtual machines
finding them by multiple criterias.

MODULE-SPECIFIC OPTIONS:
    -o ?, --conditions ?
        [opt] [mul] To find virtual machine(s) by certain conditions. You
        can use anything you wish as a valid condition. Conditions are being
        logically ANDed, so the expression
            -o has_ipaddress=10.1.1.13 -o has_domain=CUSTOMER666
        will find the virtual machine having the given IP-address belonging
        to the given domain
    -x ?, --xpath ?
        [opt] [mul] To apply some XPath-queries
    -s,   --short
        [opt] [mul] To get the result in a short form

__END_OF_VMINFO_HELP_MESSAGE__
            );
        }
    }
}



sub version {
    my $version = MMVersion ? MMVersion : 'X.3.9E6Y';
    print(<<__END_OF_VERSION_MESSAGE__
MonkeyMan v$version by Vladimir Melnik <v.melnik\@tucha.ua>
__END_OF_VERSION_MESSAGE__
    );
}



1;
