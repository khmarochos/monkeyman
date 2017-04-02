package HyperMouse::Schema::Validation::Constants;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use FindBin qw($Bin);



# :ALL

my @hm_constants_all = ();



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @mm_constants_all;
%EXPORT_TAGS        = (
    ALL                 => \@mm_constants_all,
);



1;
