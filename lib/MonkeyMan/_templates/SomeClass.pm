package MonkeyMan::_templates::SomeClass;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;
use MonkeyMan::Utils;

# Use 3rd party libraries
use TryCatch;

# Use Moose
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);



__PACKAGE__->meta->make_immutable;

1;
