package HyperMouse::Schema::PermissionCheck;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

use Method::Signatures;
use Switch;



method filter_permitted (
    Str         :$source_alias? = $self->current_source_alias,
    Bool        :$and?          = 0,
    Bool        :$not_admin?    = 0,
    Bool        :$not_billing?  = 0,
    Bool        :$not_tech?     = 0,
    Bool        :$admin?        = 1,
    Bool        :$billing?      = 1,
    Bool        :$tech?         = 1,
    Maybe[Int]  :$mask?         = undef
) {
    $mask = ($not_admin << 5) + ($not_billing << 4) + ($not_tech << 3) +
            (    $admin << 2) + (    $billing << 1) + (    $tech << 0)
       unless(defined($mask));
    my $r = $self->search_rs(
        {
            ($and ? '-and' : '-or') => [
                $mask & 32 ?         ( { "$source_alias.admin"    => 0 } ) : (),
                $mask & 16 ?         ( { "$source_alias.billing"  => 0 } ) : (),
                $mask & 8  ?         ( { "$source_alias.tech"     => 0 } ) : (),
                $mask & 4  ? ( -not => { "$source_alias.admin"    => 0 } ) : (),
                $mask & 2  ? ( -not => { "$source_alias.billing"  => 0 } ) : (),
                $mask & 1  ? ( -not => { "$source_alias.tech"     => 0 } ) : ()
            ]
        }
    );
    return($r);
}



1;
