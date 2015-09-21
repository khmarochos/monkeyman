package MonkeyMan::Essentials;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use MooseX::Aliases;
use namespace::autoclean;



has 'monkeyman' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    reader      => '_get_monkeyman',
    writer      => '_set_monkeyman',
    required    => 1,
    alias       => 'mm'
);



#sub f {
#
#    sprintf(@_);
#
#}



1;
