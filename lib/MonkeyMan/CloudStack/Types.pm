package MonkeyMan::CloudStack::Types;

use strict;
use warnings;

our @_types_known = qw(
    VirtualMachine
    Domain
);

use MooseX::Types -declare => [
    qw(
        ElementType
    )
];
use MooseX::Types::Moose qw(Str);

no strict 'refs';

subtype ElementType,
    as Str,
    where { grep(@{'::' . __PACKAGE__ . '::_types_known'}, $_); },
    message { "ElementType isn't valid" };



1;
