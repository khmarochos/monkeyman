package MonkeyMan::CloudStack::Types;
#FIXME: MonkeyMan::CloudStack::API::Types?

use strict;
use warnings;

use MooseX::Types -declare => [
    qw(
        ElementType
        ReturnAs
    )
];
use MooseX::Types::Moose qw(Str);



our @_ElementType_values = qw(
    Zone
    Domain
    Account
    User
    VirtualMachine
    ServiceOffering
    DiskOffering
    Template
    ISO
    Network
    Host
);
subtype ElementType,
    as Str,
    where { my $v = $_; grep({ $_ eq $v} @_ElementType_values); },
    message { "This ElementType isn't valid" };


our @_ReturnAs_regexps = qw(
    dom
    value
    element
    id
);
subtype ReturnAs,
    as Str,
#    where { my $v = $_; grep({ $v =~ qr/$_/ } @_ReturnAs_regexps); },
    where { my $v = $_; grep({ $_ eq $v } @_ReturnAs_regexps); },
    message { "This ReturnAs isn't valid" };



1;
