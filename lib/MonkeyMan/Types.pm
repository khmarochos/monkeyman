package MonkeyMan::Types;

use strict;
use warnings;

use MooseX::Types -declare => [
    qw(
        ElementType
    )
];
use MooseX::Types::Moose qw(Str);

our @_types_known = qw(
    VirtualMachine
    Domain
);

subtype ElementType,
    as Str,
    where { grep(@{'::' . __PACKAGE__ . '::_types_known'}, $_); },
    message { "ElementType isn't valid" };



1;
