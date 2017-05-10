package HyperMouse::Schema::DefaultResult::HyperMouse;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use Method::Signatures;



method get_schema {
    $self->result_source->schema;
}

method get_hypermouse {
    $self->get_schema->get_hypermouse;
}

method get_logger {
    $self->get_hypermouse->get_logger;
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

