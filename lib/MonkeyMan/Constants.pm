package MonkeyMan::Constants;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use FindBin qw($Bin);



# :miscellaneous

use constant MM_DEFAULT_ACTOR   => 'PRIMARY';
use constant MM_VERSION         => '1.0.0-alpha'; # See http://semver.org/

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
my @mm_constants_directories = qw(
    MM_DIRECTORY_ROOT
);




# :ALL

my @mm_constants_all = (
    @mm_constants_miscellaneous,
    @mm_constants_directories,
);



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @mm_constants_all;
%EXPORT_TAGS        = (
    ALL                 => \@mm_constants_all,
    miscellaneous       => \@mm_constants_miscellaneous,
    directories         => \@mm_constants_directories
);



1;
