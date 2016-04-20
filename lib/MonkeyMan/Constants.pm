package MonkeyMan::Constants;

use strict;
use warnings;

use FindBin;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



# :version

use constant MM_VERSION => '2.2.0'; # See http://semver.org/

my @mm_constants_version = qw(
    MM_VERSION
);

# :directories

sub MM_DIRECTORY_ROOT {
    if($FindBin::Bin =~ m{^((/.+?)?/monkeyman\b)}) {
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

use constant MM_CONFIG_MAIN         => MM_DIRECTORY_CONFIG_MAIN . '/monkeyman.conf';
use constant MM_CONFIG_LOGGER       => MM_DIRECTORY_CONFIG_MAIN . '/logger.conf';
use constant MM_CONFIG_CLOUDSTACK   => MM_DIRECTORY_CONFIG_MAIN . '/cloudstack.conf';

my @mm_constants_filenames = qw(
    MM_CONFIG_MAIN
    MM_CONFIG_LOGGER
    MM_CONFIG_CLOUDSTACK
);

# :logging

use constant MM_VERBOSITY_LEVELS        => qw(OFF FATAL ERROR WARN INFO DEBUG TRACE ALL);
use constant MM_VERBOSITY_LEVEL_BASE    => 4;
use constant MM_DATE_TIME_FORMAT        => '%Y/%m/%d %H:%M:%S';
use constant MM_LOGGER_DEFAULT_HANDY    => 'PRIMARY';

my @mm_constants_logging = qw(
    MM_VERBOSITY_LEVELS
    MM_VERBOSITY_LEVEL_BASE
    MM_DATE_TIME_FORMAT
    MM_LOGGER_DEFAULT_HANDY
);

# :cloudstack

use constant MM_CLOUDSTACK_API_WAIT_FOR_FINISH      => 3600;
use constant MM_CLOUDSTACK_API_SLEEP                => 10;
use constant MM_CLOUDSTACK_API_DEFAULT_CACHE_TIME   => 100;
use constant MM_CLOUDSTACK_DEFAULT_HANDY            => 'PRIMARY';

my @mm_constants_cloudstack = qw(
    MM_CLOUDSTACK_API_WAIT_FOR_FINISH
    MM_CLOUDSTACK_API_SLEEP
    MM_CLOUDSTACK_API_DEFAULT_CACHE_TIME
    MM_CLOUDSTACK_DEFAULT_HANDY
);

# :passwords

use constant MM_DEFAULT_PASSWORD_LENGTH             => 13;
use constant MM_DEFAULT_PASSWORD_ALL_CHARACTERS     => 1;
use constant MM_DEFAULT_PASSWORD_READABLE_ONLY      => 1;
use constant MM_PASSWORD_GENERATOR_DEFAULT_HANDY    => 'PRIMARY';

my @mm_constants_passwords = qw(
    MM_DEFAULT_PASSWORD_LENGTH
    MM_DEFAULT_PASSWORD_ALL_CHARACTERS
    MM_DEFAULT_PASSWORD_READABLE_ONLY
    MM_PASSWORD_GENERATOR_DEFAULT_HANDY
);

# :ALL

my @mm_constants_all = (
    @mm_constants_version,
    @mm_constants_directories,
    @mm_constants_filenames,
    @mm_constants_logging,
    @mm_constants_cloudstack,
    @mm_constants_passwords
);



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @mm_constants_all;
%EXPORT_TAGS        = (
    ALL         => \@mm_constants_all,
    version     => \@mm_constants_version,
    directories => \@mm_constants_directories,
    filenames   => \@mm_constants_filenames,
    passwords   => \@mm_constants_passwords,
    logging     => \@mm_constants_logging,
    cloudstack  => \@mm_constants_cloudstack
);



1;
