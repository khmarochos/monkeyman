package MonkeyMan::Constants;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use FindBin qw($Bin);



# :miscellaneous

use constant MM_DEFAULT_ACTOR   => 'PRIMARY';
use constant MM_VERSION         => '1.0.0-alpha'; # See http://semver.org/

my @mm_miscellaneous = qw(
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
my @mm_directories = qw(
    MM_DIRECTORY_ROOT
);




# :ALL

my  @mm_all = (
    @mm_miscellaneous,
    @mm_directories,
);



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @mm_all;
%EXPORT_TAGS        = (
    ALL                 => \@mm_all,
    miscellaneous       => \@mm_miscellaneous,
    directories         => \@mm_directories
);



1;
