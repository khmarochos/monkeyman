package MonkeyMan::CloudStack::API::Essentials;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use MooseX::Aliases;
use namespace::autoclean;



has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      =>  'get_api',
    writer      => '_set_api',
    predicate   => '_has_api',
    required    => 1,
);



1;
