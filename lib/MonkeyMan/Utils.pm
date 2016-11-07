package MonkeyMan::Utils;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Exception;

# Use 3rd party libraries
use Method::Signatures;
use Module::Loaded;
use Exporter;
use TryCatch;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



my @MM_utils_all = qw(
    mm_find_package
    mm_load_package
);

@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @MM_utils_all;



func mm_find_package_file_name(Str $package_name!) {
    my $file_name = $package_name;
       $file_name =~ s#::#/#g;
       $file_name .= '.pm';
    return($file_name);
}

func mm_load_package(Str $package_name!) {

    unless(is_loaded($package_name)) {
        my $file_name = mm_find_package_file_name($package_name);
        try {
            require($file_name);
        } catch($e) {
            MonkeyMan::Exception::CanNotLoadPackage->throwf(
                "Can't load the %s package from the %s file. %s",
                $package_name,
                $file_name,
                $e
            );
        }
    }
    return($package_name);
}



1;
