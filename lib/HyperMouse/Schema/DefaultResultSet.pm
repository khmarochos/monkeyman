package HyperMouse::Schema::DefaultResultSet;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Method::Signatures;
use DateTime;
use DateTime::TimeZone;

our $LocalTZ = DateTime::TimeZone->new(name => 'local');



method get_schema {
    $self->result_source->schema;
}



method datetime_parser {
    $self->result_source->storage->datetime_parser;
}

method format_datetime(
    DateTime $datetime!
) {
    $self->datetime_parser->format_datetime($datetime);
}



method filter_valid (
    Str         :$source_alias? = $self->current_source_alias,
       DateTime :$now?          = DateTime->now(time_zone => $LocalTZ),
    Bool        :$removed       = 0,
    Bool        :$premature     = 0,
    Bool        :$expired       = 0,
    Bool        :$not_removed   = 1,
    Bool        :$not_premature = 1,
    Bool        :$not_expired   = 1,
    Maybe[Int]  :$mask?         = undef
) {
    $mask =
        (    $removed << 5) + (    $premature << 4) + (    $expired << 3) +
        ($not_removed << 2) + ($not_premature << 1) + ($not_expired << 0)
       unless(defined($mask));
    $self->search(
        {
            -and => [
                $mask & 32 ? ( "$source_alias.removed"       => { -not => { '=' => undef }             } ) : (),
                $mask & 16 ? ( "$source_alias.valid_since"   => { '>'  => $self->format_datetime($now) } ) : (),
                $mask & 8  ? ( "$source_alias.valid_till"    => { '<=' => $self->format_datetime($now) } ) : (),
                $mask & 4  ? ( "$source_alias.removed"       => { '='  => undef                        } ) : (),
                $mask & 2  ? ( "$source_alias.valid_since"   => { '<=' => $self->format_datetime($now) } ) : (),
                $mask & 1  ? (
                    -or => [
                             { "$source_alias.valid_till"    => { '='  => undef } },
                             { "$source_alias.valid_till"    => { '>'  => $self->format_datetime($now) } }
                    ]
                ) : ()
            ]
        }
    );
}

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
    $self->search(
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
}



1;
