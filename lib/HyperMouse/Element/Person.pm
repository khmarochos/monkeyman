package HyperMouse::Element::Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'HyperMouse::Roles::Element';

use Method::Signatures;



method authenticate ($person_password!) {
    return($self->_get_db_result->search_related("person_passwords", { $self->valid_only })->single->check_password($person_password));
}



__PACKAGE__->meta->make_immutable;

1;
