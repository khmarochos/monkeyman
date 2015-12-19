package MonkeyMan::Configuration;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

use MonkeyMan::Constants qw(:filenames);

# Use 3rd-party libraries
use Config::General qw(ParseConfig);



has 'tree' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>  'get_tree',
    writer      => '_set_tree',
    predicate   => '_has_tree',
    required    => 1
);



__PACKAGE__->meta->make_immutable;

1;
