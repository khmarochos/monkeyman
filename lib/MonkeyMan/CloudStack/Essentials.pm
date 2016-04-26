package MonkeyMan::CloudStack::Essentials;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;



has 'cloudstack' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack',
    reader      =>  'get_cloudstack',
    writer      => '_set_cloudstack',
    required    => 1
);



1;
