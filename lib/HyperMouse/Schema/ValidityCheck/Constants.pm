package HyperMouse::Schema::ValidityCheck::Constants;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



# :vc_flags_bits

use constant VC_B_NOT_EXPIRED    => 0;
use constant VC_B_NOT_PREMATURE  => 1;
use constant VC_B_NOT_REMOVED    => 2;
use constant VC_B_EXPIRED        => 3;
use constant VC_B_PREMATURE      => 4;
use constant VC_B_REMOVED        => 5;

my @vc_flags_bits = qw(
    VC_B_NOT_EXPIRED
    VC_B_NOT_PREMATURE
    VC_B_NOT_REMOVED
    VC_B_EXPIRED
    VC_B_PREMATURE
    VC_B_REMOVED
);



# :vc_flags

use constant VC_NOT_EXPIRED      => 1 << VC_B_NOT_EXPIRED;
use constant VC_NOT_PREMATURE    => 1 << VC_B_NOT_PREMATURE;
use constant VC_NOT_REMOVED      => 1 << VC_B_NOT_REMOVED;
use constant VC_EXPIRED          => 1 << VC_B_EXPIRED;
use constant VC_PREMATURE        => 1 << VC_B_PREMATURE;
use constant VC_REMOVED          => 1 << VC_B_REMOVED;

my @vc_flags = qw(
    VC_NOT_EXPIRED
    VC_NOT_PREMATURE
    VC_NOT_REMOVED
    VC_EXPIRED
    VC_PREMATURE
    VC_REMOVED
);



# :ALL

my  @vc_all = (
    @vc_flags_bits,
    @vc_flags
);



@ISA                = qw(Exporter);
@EXPORT             = qw();
@EXPORT_OK          = @vc_all;
%EXPORT_TAGS        = (
    ALL                 => \@vc_all,
    vc_flags            => \@vc_flags,
    vc_flags_bits       => \@vc_flags_bits
);



1;
