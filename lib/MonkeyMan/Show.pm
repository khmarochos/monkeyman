package MonkeyMan::Show;

use strict;

use FindBin qw($Bin);

use lib("$Bin/../lib");

use MonkeyMan::Constants;



sub help {

    my $mode = shift;

    version();

    print(<<__END_OF_GLOBAL_HELP_MESSAGE__

Usage: $0 [OPTIONS]

GLOBAL OPTIONS:
    -h,   --help          [O] Prints this message and exit
          --version       [O] Prints only verion information and exit
    -c ?, --config ?      [O] Reads configuration from the specified file
    -v,   --verbose       [O] Increasing verbosity
    -q,   --quiet         [O] Silent mode

__END_OF_GLOBAL_HELP_MESSAGE__
    );

    if($mode eq 'runapicmd') {
        print(<<__END_OF_RUNAPICMD_HELP_MESSAGE__
MODULE ($mode) OPTIONS:
    -p ?, --parameters ?  [M] The command and its parameters
    -w ?, --wait ?        [O] To wait some time for an async job:
                              if the number is omitted, I'll wait forever,
                              but won't wait for anything by default
    -x ?, --xpath ?       [O] To apply some XPath-queries
    -s,   --short         [O] To get the result in a short form

The purpourse of this module is to send commands to CloudStack's API and
to show their results.

__END_OF_RUNAPICMD_HELP_MESSAGE__
        );
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
