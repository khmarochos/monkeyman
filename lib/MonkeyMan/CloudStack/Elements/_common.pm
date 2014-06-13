package MonkeyMan::CloudStack::Elements::_common;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose::Role;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);



sub load_dom {
    
    my($self, $id) = @_;

    return($self->error("The object's ID hasn't been defined"))
        unless(defined($id));
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($self->mm->has_cloudstack_api);

}



1;

