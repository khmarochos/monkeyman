package MonkeyMan::CloudStack::Cache;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);
has api => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      => '_get_api',
    writer      => '_set_api',
    predicate   => 'has_api',
    initializer => 'init_api'
);
has configuration => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => '_get_configuration',
    writer      => '_set_configuration',
    predicate   => 'has_configuration',
    required    => 'yes'
);
has memory_pool => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => '_get_memory_pool',
    writer      => '_set_memory_pool',
    predicate   => '_has_memory_pool',
    init_arg    => undef
);



sub get_list {
    
    my $self    = shift;
    my $caller  = shift;

    return($self->error("The caller's object hasn't been defined"))
        unless(defined($caller));
    my $api = $self->_get_api;
    return($self->error("API hasn't been initialized"))
        unless(defined($api));

    $self->trace(
        "Going to look up for the full list of " .
        $caller->element_type . "s"
    );

    my $result = $self->api->run_command(
        parameters => $caller->_load_full_list_command
    );
    return($self->error($caller->error_message)) unless(defined($result));

    return($result);

}



sub init_api {

    my $self    = shift;
    my $value   = shift;

    if(defined($value)) {
        return($value);
    } else {
        return($self->mm->cloudstack_api);
    }

}




__PACKAGE__->meta->make_immutable;

1;
