package HyperMouse::Schema::ResultSet::Corporation;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'HyperMouse::Schema::DefaultResultSet';



__PACKAGE__->meta->make_immutable;

1;