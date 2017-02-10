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
    DateTime :$now?           = DateTime->now(time_zone => $LocalTZ),
    Str      :$source_alias?  = $self->current_source_alias
) {
    $self->search(
        {
            -and => [
                { "$source_alias.removed"       => { '='    => undef } },
                { "$source_alias.valid_since"   => { '<='   => $self->format_datetime($now) } },
                {
                    -or => [
                        { "$source_alias.valid_till"    => { '=' => undef } },
                        { "$source_alias.valid_till"    => { '>' => $self->format_datetime($now) } }
                    ]
                }
            ]
        }
    );
}



1;
