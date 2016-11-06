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
use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
use Exporter;
use TryCatch;
use Digest::MD5 qw(md5_hex);
use File::Path qw(make_path);

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

func mm_showref(Ref $ref!) {

    my $ref_id_short = sprintf(
        "%s\@0x%x",
        blessed($ref) ? blessed($ref) : ref($ref),
        refaddr($ref)
    );

    my $monkeyman;
    my $monkeyman_started;
    my $logger;
    my $conftree;
    my $dumped;
    my $dumpdir;
    my $dumpxml;
    my $dumpfile;

    try {
        MonkeyMan->initialize;
    } catch($e) {
        try {
            $monkeyman  = MonkeyMan->instance;
            $monkeyman_started = $monkeyman->get_time_started_formatted;
            $logger     = $monkeyman->get_logger;
            $conftree   = $logger->get_configuration;
            $dumped     = $conftree->{'dump'}->{'enabled'};
            $dumpxml    = $conftree->{'dump'}->{'add_xml'};
            $dumpdir    = $conftree->{'dump'}->{'directory'};
        } catch($e) {
            warn($e);
        }
    }

    unless(defined($monkeyman)) {
        warn(
            "Can't determine if I should really dump the data structure. " .
            "It seems that MonkeyMan hasn't been initialized properly yet."
        );
        return("[$ref_id_short]");
    }

    my $result;

    if(defined($dumped) && defined($dumpdir)) {

        my $dump = Data::Dumper->new([$ref])->Indent(1)->Terse(0)->Dump;
        $dump .= ("\n" . $ref->toString(1)) if(
            $dumpxml &&
                ref($ref) &&
                    blessed($ref) &&
                        $ref->DOES('XML::LibXML::Node'));

        my $ref_id_long = md5_hex($dump);

        $dumpfile = ($dumpdir = sprintf(
            '%s/%s/%d/%s',
                $dumpdir,
                $monkeyman_started,
                $$,
                $ref_id_short
        )) . "/$ref_id_long";

        try {
            make_path($dumpdir);
            open(my($filehandle), '>', $dumpfile) ||
                MonkeyMan::Exception->throwf(
                    "Can't open the %s file for writing: %s",
                        $dumpfile,
                        $!
                );
            print({$filehandle} $dump);
            close($filehandle) ||
                MonkeyMan::Exception->throwf(
                    "Can't close the %s file: %s",
                        $dumpfile,
                        $!
                );
        } catch($e) {
            $logger->warnf("Can't dump: %s", $e);
            $ref_id_long='...CORRUPTED...';
        }

        $result = sprintf("%s/%s", $ref_id_short, $ref_id_long);

    } else {

        $result = sprintf("%s", $ref_id_short);

    }

    if(blessed($ref) && $ref->DOES('MonkeyMan::Exception')) {
        $result = sprintf('%s - %s', $result, $ref->message);
    }

    return(sprintf("[%s]", $result));

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
