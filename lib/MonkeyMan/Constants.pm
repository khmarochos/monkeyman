package MonkeyMan::Constants;

use strict;
use warnings;

use Exporter;

use FindBin qw($Bin);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# :version
use constant MMVersion          => '1.0.1';
my @MM_constants_version = qw(
    MMVersion
);

# :directories
sub MMRootDirectory {
    if($Bin =~ /^(\/.+\/monkeyman)\/bin(\/.+)?/) {
        return($1);
    }
}
use constant MMMainConfigDirectory  => MMRootDirectory . "/etc";
use constant MMDumpObjectsTo        => MMRootDirectory . "/var/dump/objects";
my @MM_constants_directories = qw(
    MMRootDirectory
    MMMainConfigDirectory
    MMDumpObjectsTo
);

# :filenames
use constant MMMainConfigFile   => MMMainConfigDirectory . "/monkeyman.conf";
use constant MMElementsModule   => {
    domain          => 'Domain',
    virtualmachine  => 'VirtualMachine',
    host            => 'Host',
    volume          => 'Volume',
    snapshot        => 'Snapshot',
    storagepool     => 'StoragePool'
};
my @MM_constants_filenames = qw(
    MMMainConfigFile
    MMElementsModule
);

# :timeouts
use constant MMSleepWhileWaitingForAsyncJobResult   => 60;
my @MM_constants_timeouts = qw(
    MMSleepWhileWaitingForAsyncJobResult
);

# :logging
use constant MMVerbosityLevels  => ('OFF', 'FATAL', 'ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE', 'ALL');
use constant MMVerbosityLevel   => 4;
use constant MMDateTimeFormat   => "%Y/%m/%d %H:%M:%S";
my @MM_constants_logging = qw(
    MMVerbosityLevels
    MMVerbosityLevel
    MMDateTimeFormat
);

my @MM_constants_all = (
    @MM_constants_version,
    @MM_constants_directories,
    @MM_constants_filenames,
    @MM_constants_timeouts,
    @MM_constants_logging
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_constants_all;
@EXPORT_OK          = @MM_constants_all;
%EXPORT_TAGS        = (
    version     => \@MM_constants_version,
    directories => \@MM_constants_directories,
    filenames   => \@MM_constants_filenames,
    timeouts    => \@MM_constants_timeouts,
    logging     => \@MM_constants_logging
);



1;
