package HyperMouse::Schema::DefaultResultSet;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Method::Signatures;
use DateTime;



method datetime_parser {
    $self->result_source->storage->datetime_parser;
}

method format_datetime(
    DateTime $datetime!
) {
    $self->datetime_parser->format_datetime($datetime);
}

method get_schema {
    $self->result_source->schema;
}



method filter_valid (
    DateTime $now? = DateTime->now
) {
    $self->search(
        {
            -and => [
                { removed       => { '='    => undef } },
                { valid_since   => { '<='   => $self->format_datetime($now) } },
                {
                    -or => [
                        { valid_till    => { '=' => undef } },
                        { valid_till    => { '>' => $self->format_datetime($now) } }
                    ]
                }
            ]
        }
    );
}



1;
