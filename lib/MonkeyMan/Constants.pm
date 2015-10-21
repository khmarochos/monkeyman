package MonkeyMan::Constants;

use strict;
use warnings;

use FindBin qw($Bin);
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



# :version

use constant MM_VERSION => '2.0.0-rc.1'; # See http://semver.org/

my @mm_constants_version = qw(
    MM_VERSION
);

# :directories

sub MM_DIRECTORY_ROOT {
    if($Bin =~ m{((/.+)?/monkeyman)/((?!monkeyman).)+$}) {
        return($1);
    } else {
        die("Can't find the root directory");
    }
}
use constant MM_DIRECTORY_CONFIG_MAIN   => MM_DIRECTORY_ROOT . '/etc';
use constant MM_DIRECTORY_DUMP          => MM_DIRECTORY_ROOT . '/var/dump/objects';

my @mm_constants_directories = qw(
    MM_DIRECTORY_ROOT
    MM_DIRECTORY_CONFIG_MAIN
    MM_DIRECTORY_DUMP
);

# :filenames

use constant MM_CONFIG_MAIN     => MM_DIRECTORY_CONFIG_MAIN . '/monkeyman.conf';
use constant MM_CONFIG_LOGGER   => MM_DIRECTORY_CONFIG_MAIN . '/logger.conf';
use constant MM_ELEMENT_MODULE  => {
    domain          => 'Domain',
    virtualmachine  => 'VirtualMachine',
    host            => 'Host',
    volume          => 'Volume',
    snapshot        => 'Snapshot',
    storagepool     => 'StoragePool'
};

my @mm_constants_filenames = qw(
    MM_CONFIG_MAIN
    MM_CONFIG_LOGGER
    MM_ELEMENT_MODULE
);

# :timeouts

use constant MM_SLEEP_WHILE_WAITING_FOR_ASYNC_JOB_RESULT => 60;

my @mm_constants_timeouts = qw(
    MM_SLEEP_WHILE_WAITING_FOR_ASYNC_JOB_RESULT
);

# :logging

use constant MM_VERBOSITY_LEVELS        => qw(OFF FATAL ERROR WARN INFO DEBUG TRACE ALL);
use constant MM_VERBOSITY_LEVEL_BASE    => 4;
use constant MM_DATE_TIME_FORMAT        => '%Y/%m/%d %H:%M:%S';

my @mm_constants_logging = qw(
    MM_VERBOSITY_LEVELS
    MM_VERBOSITY_LEVEL_BASE
    MM_DATE_TIME_FORMAT
);

# :cloudstack

use constant MM_CLOUDSTACK_PRIMARY      => 'PRIMARY';

my @mm_constants_cloudstack = qw(
    MM_CLOUDSTACK_PRIMARY
);

# :ALL

my @mm_constants_all = (
    @mm_constants_version,
    @mm_constants_directories,
    @mm_constants_filenames,
    @mm_constants_timeouts,
    @mm_constants_logging,
    @mm_constants_cloudstack
);



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @mm_constants_all;
%EXPORT_TAGS        = (
    ALL         => \@mm_constants_all,
    version     => \@mm_constants_version,
    directories => \@mm_constants_directories,
    filenames   => \@mm_constants_filenames,
    timeouts    => \@mm_constants_timeouts,
    logging     => \@mm_constants_logging,
    cloudstack  => \@mm_constants_cloudstack
);



1;
