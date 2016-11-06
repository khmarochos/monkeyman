package MonkeyMan::Constants;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use FindBin qw($Bin);



# :miscellaneous

use constant MM_DEFAULT_ACTOR => 'PRIMARY';
# MonkeyMan
use constant MM_VERSION => '3.0.0'; # See http://semver.org/
# MonkeyMan

my @mm_constants_miscellaneous = qw(
    MM_DEFAULT_ACTOR
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
use constant MM_DIRECTORY_LIB           => MM_DIRECTORY_ROOT . '/lib';
# ^^^ MonkeyMan
use constant MM_DIRECTORY_CONFIG_MAIN   => MM_DIRECTORY_ROOT . '/etc';
# ^^^ MonkeyMan::Constants
use constant MM_DIRECTORY_DUMP          => MM_DIRECTORY_ROOT . '/var/dump/objects';
# ^^^ MonkeyMan::Utils

my @mm_constants_directories = qw(
    MM_DIRECTORY_ROOT
    MM_DIRECTORY_CONFIG_MAIN
    MM_DIRECTORY_DUMP
);

# :filenames

use constant MM_CONFIG_PLUGINS      => MM_DIRECTORY_LIB . '/MonkeyMan/plugins.yaml';
# ^^^ MonkeyMan
use constant MM_CONFIG_MAIN         => MM_DIRECTORY_CONFIG_MAIN . '/monkeyman.conf';
# ^^^ MonkeyMan
use constant MM_CONFIG_LOG4PERL     => MM_DIRECTORY_CONFIG_MAIN . '/' . MM_DEFAULT_ACTOR . '/logger.conf';
# ^^^ MonkeyMan
use constant MM_CONFIG_CLOUDSTACK   => MM_DIRECTORY_CONFIG_MAIN . '/' . MM_DEFAULT_ACTOR . '/cloudstack.conf';
# ^^^ MonkeyMan

my @mm_constants_filenames = qw(
    MM_CONFIG_PLUGINS
    MM_CONFIG_MAIN
    MM_CONFIG_LOG4PERL
    MM_CONFIG_CLOUDSTACK
);



# :cloudstack

use constant MM_CLOUDSTACK_API_WAIT_FOR_FINISH      => 3600;
# ^^^ MonkeyMan::CloudStack
use constant MM_CLOUDSTACK_API_SLEEP                => 10;
# ^^^ MonkeyMan::CloudStack
use constant MM_CLOUDSTACK_API_DEFAULT_CACHE_TIME   => 100;
# ^^^ MonkeyMan::CloudStack

my @mm_constants_cloudstack = qw(
    MM_CLOUDSTACK_API_WAIT_FOR_FINISH
    MM_CLOUDSTACK_API_SLEEP
    MM_CLOUDSTACK_API_DEFAULT_CACHE_TIME
);

# :passwords

use constant MM_DEFAULT_PASSWORD_LENGTH             => 13;
# ^^^ MonkeyMan::PasswordGenerator
use constant MM_DEFAULT_PASSWORD_ALL_CHARACTERS     => 1;
# ^^^ MonkeyMan::PasswordGenerator
use constant MM_DEFAULT_PASSWORD_READABLE_ONLY      => 1;
# ^^^ MonkeyMan::PasswordGenerator

my @mm_constants_passwords = qw(
    MM_DEFAULT_PASSWORD_LENGTH
    MM_DEFAULT_PASSWORD_ALL_CHARACTERS
    MM_DEFAULT_PASSWORD_READABLE_ONLY
);



# :ALL

my @mm_constants_all = (
    @mm_constants_miscellaneous,
    @mm_constants_directories,
    @mm_constants_filenames,
    @mm_constants_cloudstack,
    @mm_constants_passwords
);



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @mm_constants_all;
%EXPORT_TAGS        = (
    ALL                 => \@mm_constants_all,
    miscellaneous       => \@mm_constants_miscellaneous,
    directories         => \@mm_constants_directories,
    filenames           => \@mm_constants_filenames,
    passwords           => \@mm_constants_passwords,
    cloudstack          => \@mm_constants_cloudstack
);



1;
