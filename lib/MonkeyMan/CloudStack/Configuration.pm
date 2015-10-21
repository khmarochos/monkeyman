package MonkeyMan::CloudStack::Configuration;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::Essentials';



has 'configuration_tree' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => 'get_configuration_tree',
    writer      => '_set_configuration_tree',
    builder     => '_build_configuration_tree',
    alias       => 'tree',
    required    => 1
);



__PACKAGE__->meta->make_immutable;

1;
