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
use Data::Dumper;
use Exporter;
use TryCatch;
### vvv mm_showref vvv ###
use Scalar::Util qw(blessed refaddr);
use Digest::MD5 qw(md5_hex);
use File::Path qw(make_path);
### ^^^ mm_showref ^^^ ###

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



my @MM_utils_all = qw(
    mm_sprintf
    mm_showref
    mm_find_package
    mm_load_package
);

@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @MM_utils_all;



sub mm_sprintf {

    my($message, @values) = @_;

    for(my $i = 0; $i < scalar(@_); $i++) {
        my $value = $values[$i];
        if(!defined($value)) {
            $values[$i] = "[UNDEF]";
        } elsif(ref($value)) {
            $values[$i] = mm_showref($values[$i]);
        }
    }

    return(sprintf($message, @values));

}

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
