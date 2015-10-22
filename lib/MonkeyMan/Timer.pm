package MonkeyMan::Timer;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Timerable';



__PACKAGE__->meta->make_immutable;

1;
