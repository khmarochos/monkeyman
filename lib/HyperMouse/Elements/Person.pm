package Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

with 'HyperMouse::Roles::Element';

use Method::Signatures;



method authenticate (
    Str     :$username,
    Str     :$password
) {
}



__PACKAGE__->meta->make_immutable;

1;
