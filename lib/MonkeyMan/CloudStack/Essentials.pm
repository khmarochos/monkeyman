package MonkeyMan::CloudStack::Essentials;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use MooseX::Aliases;
use namespace::autoclean;



has 'cloudstack' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack',
    reader      => '_get_cloudstack',
    writer      => '_set_cloudstack',
    predicate   => '_has_cloudstack',
    required    => 1,
    alias       => 'cs'
);



1;
