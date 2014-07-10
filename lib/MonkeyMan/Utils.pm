package MonkeyMan::Utils;

use strict;
use warnings;

use feature qw(switch);

use Exporter;
use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
   $Data::Dumper::Indent = 0;
   $Data::Dumper::Terse = 1;

use FindBin qw($Bin);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

my @MM_utils_all = qw(
    mm_object_info
    mm_sprintify
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_utils_all;
@EXPORT_OK          = @MM_utils_all;

sub mm_sprintify {

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
