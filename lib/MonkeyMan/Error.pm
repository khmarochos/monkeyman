package MonkeyMan::Error;

use strict;
use warnings;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



has 'text' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   => 'has_text',
    writer      => 'set_text'
);
has 'caller' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => 'has_caller',
    writer      => 'set_caller'
);



__PACKAGE__->meta->make_immutable;

1;
