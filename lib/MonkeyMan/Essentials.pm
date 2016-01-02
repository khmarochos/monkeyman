package MonkeyMan::Essentials;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;



has 'monkeyman' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    reader      =>  'get_monkeyman',
    writer      => '_set_monkeyman',
    predicate   => '_has_monkeyman',
    required    => 1
);



1;
