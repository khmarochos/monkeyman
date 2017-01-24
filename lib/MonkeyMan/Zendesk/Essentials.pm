package MonkeyMan::Zendesk::Essentials;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;



has 'zendesk' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Zendesk',
    reader      =>  'get_zendesk',
    writer      => '_set_zendesk',
    required    => 1
);



1;
