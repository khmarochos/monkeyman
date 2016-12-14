package MonkeyMan::Constants;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use FindBin qw($Bin);



# :miscellaneous

use constant MM_DEFAULT_ACTOR   => 'PRIMARY';
use constant MM_VERSION         => '3.0.1'; # See http://semver.org/

my @mm_constants_miscellaneous = qw(
    MM_DEFAULT_ACTOR
    MM_VERSION
);

# :directories

sub MM_DIRECTORY_ROOT {
    if($FindBin::Bin =~ m{^((/.+?)?/monkeyman\b(?!.*monkeyman\b)).*}) {
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
);



1;
