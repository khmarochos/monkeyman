package MonkeyMan::Constants;

use strict;
use warnings;

use Exporter;

use FindBin qw($Bin);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# :version
use constant MMVersion          => '0.2.1';
my @MM_version = qw(
    MMVersion
);

# :filenames
use constant MMMainConfigFile   => "$Bin/../etc/monkeyman.conf";
my @MM_filenames = qw(
    MMMainConfigFile
);

# :timeouts
use constant MMSleepWhileWaitingForAsyncJobResult   => 60;
my @MM_timeouts = qw(
    MMSleepWhileWaitingForAsyncJobResult
);

# :logging
use constant MMVerbosityLevels  => ('OFF', 'FATAL', 'ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE', 'ALL');
use constant MMVerbosityLevel   => 4;
use constant MMDateTimeFormat   => "%Y/%m/%d %H:%M:%S";
my @MM_logging = qw(
    MMVerbosityLevels
    MMVerbosityLevel
    MMDateTimeFormat
);

my @MM_all = (
    @MM_version,
    @MM_filenames,
    @MM_timeouts,
    @MM_logging
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_all;
@EXPORT_OK          = @MM_all;
%EXPORT_TAGS        = (
    version     => \@MM_version,
    filenames   => \@MM_filenames,
    timeouts    => \@MM_timeouts,
    logging     => \@MM_logging
);



1;
