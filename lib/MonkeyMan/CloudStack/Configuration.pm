package MonkeyMan::CloudStack::Configuration;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::Essentials';



has 'tree' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_tree',
    writer      =>   '_set_tree',
    required    => 1
);



__PACKAGE__->meta->make_immutable;

1;
