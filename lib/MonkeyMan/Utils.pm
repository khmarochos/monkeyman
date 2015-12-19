package MonkeyMan::Utils;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Exception;

# Use 3rd party libraries
use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
use Exporter;
use TryCatch;
use Digest::MD5 qw(md5_hex);
use File::Path qw(make_path);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



my @MM_utils_all = qw(
    mm_sprintf
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_utils_all;
@EXPORT_OK          = @MM_utils_all;



sub mm_sprintf {

    my($message, @values) = @_;

    for(my $i = 0; $i < scalar(@_); $i++) {
        my $value = $values[$i];
        if(!defined($value)) {
            $values[$i] = "[UNDEF]";
        } elsif(ref($value)) {
            $values[$i] = _showref($values[$i]);
        }
    }

    return(sprintf($message, @values));

}



sub _showref {

    my $ref = shift;
    my $ref_id_short;

    if(ref($ref)) {
        $ref_id_short = sprintf(
            "%s\@0x%x",
            blessed($ref) ? blessed($ref) : ref($ref),
            refaddr($ref));
    }

    my $monkeyman;
    my $monkeyman_started;
    my $conftree;
    my $dumped;
    my $dumpdir;
    my $dumpfile;
    try {
        $monkeyman  = MonkeyMan->instance;
        $monkeyman_started = $monkeyman->get_time_started_formatted;
        $conftree   = $monkeyman->get_configuration->get_tree;
        $dumped     = $conftree->{'log'}->{'dump'}->{'enabled'};
        $dumpdir    = $conftree->{'log'}->{'dump'}->{'directory'};
    } catch($e) {
        warn(sprintf(
            "Can't determine if I should dump the data structure. " .
            "It seems that MonkeyMan isn't initialized properly. " .
            "%s",
                $e
        ));
        return("[$ref_id_short]");
    }

    return("[$ref_id_short]") unless(defined($dumped) && defined($dumpdir));

    my $dump = Data::Dumper->new([$ref])->Indent(1)->Terse(0)->Dump;
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
        warn(sprintf('Can\'t dump: %s', $e));
        return("[$ref_id_short]");
    }

    return("[$ref_id_short/$ref_id_long]");

}



1;
