package MonkeyMan::Utils;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);

# Use 3rd party libraries
use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
use Exporter;

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
        } elsif(blessed($value)) {
            $values[$i] = sprintf("[%s\@0x%x]", blessed($value), refaddr($value));
        } elsif(ref($value) eq 'HASH') {
            $values[$i] = Data::Dumper->new([$value])->Indent(0)->Terse(1)->Dump;
        }
    }

    return(sprintf($message, @values));

}



1;
