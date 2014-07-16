package MonkeyMan::Utils;

use strict;
use warnings;

use feature qw(switch);

use MonkeyMan::Constants;

use Exporter;

use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
use Data::Dump::XML;
use File::Path;
use POSIX qw(strftime);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

my @MM_utils_all = qw(
    mm_sprintify
    mm_dump_object
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_utils_all;
@EXPORT_OK          = @MM_utils_all;

sub mm_sprintify {

    $Data::Dumper::Indent   = 0;
    $Data::Dumper::Terse    = 1;

    my($message, @values) = @_;

    return($message) unless(@values);

    for(my $i = 0; $i < @_; $i++) {
        given($values[$i]) {
            when(undef)             { $values[$i] = "< undef >"; }
            when(ref($_) eq 'HASH') { $values[$i] = Dumper($_); }
            when(blessed($_))       { $values[$i] = sprintf("[%s\@0x%x]", blessed($_), refaddr($_)); }
        }
    }

    return(sprintf($message, @values));

}



sub mm_dump_object {

    my $data        = shift;
    my $object_type = shift;
    my $object_name = shift;
    my $depth       = shift;
    my $xml         = shift;

    die("The data reference isn't defined")
        unless(defined($data));
    $object_type = "other"
        unless(defined($object_type));
    $object_name = "nonane"
        unless(defined($object_name));
    $depth = -1
        unless(defined($depth));

    # Make a dump
    
    my $output;
    if($xml) {
        my $dumper = eval { Data::Dump::XML->new(); };
        die(mm_sprintify("Can't Data::Dump::XML->new(): %s", $@))
            if($@);
        $output = $dumper->dump_xml($data);
    } else {
        my $dumper = eval { Data::Dumper->new([$data], [[$object_name]]); };
        die(mm_sprintify("Can't Data::Dumper->new(): %s", $@))
            if($@);
        $dumper->Indent(2);
        $dumper->Maxdepth($depth) if($depth < 0);
        $output = $dumper->Dump;
    }

    # Create necessary diretories

    my $dirname     = MMDumpObjectsTo . mm_sprintify(
        "/%s/%s-%d",
            $object_type,
            strftime("%Y%m%d%H%M%S", localtime),
            $$
    );
    eval { mkpath($dirname); };
    die(mm_sprintify("Can't mkpath(): %s", $@))
        if($@);

    # Open a file and just dump all the fookin shit down there

    my $filename    = mm_sprintify("%s/%s.%s", $dirname, $object_name, ($xml ? "xml" : "dump"));
    eval { open(OUT, ">$filename"); };
    die(mm_sprintify("Can't open: %s", $@))
        if($@);
    print(OUT $output);
    close(OUT);

    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    $log->trace(mm_sprintify("Something has been dumped to %s", $filename))
        if(defined($log));

    return($filename);

}



