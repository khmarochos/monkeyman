package MonkeyMan::Error;

use strict;
use warnings;

use Carp qw(longmess);

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



has 'text' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   => 'has_text',
    writer      => 'set_text',
);
has 'caller' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => 'has_caller',
    writer      => 'set_caller'
);
has 'backtrace' => (
    is          => 'ro',
    predicate   => 'has_backtrace',
    writer      => '_set_backtrace',
    builder     => '_build_backtrace',
    lazy        => 1
);



sub _build_backtrace {
    longmess("[BACKTRACE]");
}
    


__PACKAGE__->meta->make_immutable;

1;
