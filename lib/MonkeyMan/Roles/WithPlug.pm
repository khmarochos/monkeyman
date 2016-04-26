package MonkeyMan::Roles::WithPlug;

use strict;
use warnings;

use MonkeyMan::Exception qw(
    ActorIsListed
    ActorIsNotListed
);

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

# Use 3rd-party libraries
use Method::Signatures;
use Data::Dumper;



has 'plugin_name' => (
    isa         => 'Str',
    is          => 'ro',
    reader      =>    'get_plugin_name',
    writer      =>   '_set_plugin_name',
    predicate   =>   '_has_plugin_name',
    required    => 1
);

has 'actor_class' => (
    isa         => 'Str',
    is          => 'ro',
    reader      =>    'get_actor_class',
    writer      =>   '_set_actor_class',
    predicate   =>   '_has_actor_class',
    required    => 1
);

has 'actor_parent' => (
    isa         => 'Object',
    is          => 'ro',
    reader      =>  'get_actor_parent',
    writer      => '_set_actor_parent',
    predicate   => '_has_actor_parent',
    required    => 1
);

has 'actor_parent_to' => (
    isa         => 'Maybe[Str]',
    is          => 'ro',
    reader      =>  'get_actor_parent_to',
    writer      => '_set_actor_parent_to',
    predicate   => '_has_actor_parent_to',
);

has 'actor_name_to' => (
    isa         => 'Maybe[Str]',
    is          => 'ro',
    reader      =>  'get_actor_name_to',
    writer      => '_set_actor_name_to',
    predicate   => '_has_actor_name_to',
);

has 'actor_default' => (
    isa         => 'Maybe[Str]',
    is          => 'ro',
    reader      =>  'get_actor_default',
    writer      => '_set_actor_default',
    predicate   => '_has_actor_default'
);

has 'actor_parameters' => (
    isa         => 'Maybe[HashRef]',
    is          => 'ro',
    reader      =>  'get_actor_parameters',
    writer      => '_set_actor_parameters',
    predicate   => '_has_actor_parameters',
);

has 'configuration_index' => (
    isa         => 'Maybe[HashRef]',
    is          => 'ro',
    reader      =>  'get_configuration_index',
    writer      => '_set_configuration_index',
    predicate   => '_has_configuration_index',
);

has 'actor_auto_initialize' => (
    isa         => 'Bool',
    is          => 'ro',
    reader      =>    'get_actor_auto_initialize',
    writer      =>   '_set_actor_auto_initialize',
    predicate   =>   '_has_actor_auto_initialize',
    builder     => '_build_actor_auto_initialize'
);

method _build_actor_auto_initialize {
    return(1);
}

has 'actors' => (
    isa         => 'HashRef[Str]',
    is          => 'ro',
    reader      =>    'get_actors',
    writer      =>   '_set_actors',
    predicate   =>   '_has_actors',
    builder     => '_build_actors'
);

method _build_actors {
    return({});
}

method has_actor(Str $actor_name!) {

    return(defined($self->get_actors->{$actor_name}));

}

method add_actor(Str $actor_name!, Maybe[Object] $actor_object?) {

    (__PACKAGE__ . '::Exception::ActorIsListed')->throwf(
        "The %s actor has been requested to be added, " .
            "although it's already listed in the %s index of actors",
        $actor_name, $self->get_actors
    )
        if($self->has_actor($actor_name));

    $actor_object = $self->initialize_actor($actor_name)
        unless(defined($actor_object));

    $self->get_actors->{$actor_name} = $actor_object;

}

method remove_actor(Str $actor_name!) {

    (__PACKAGE__ . '::Exception::ActorIsNotListed')->throwf(
        "The %s actor has been requested to be removed, " .
            "although it's not listed in the %s index of actors",
        $actor_name, $self->get_actors
    )
        if($self->has_actor($actor_name));

    delete($self->get_actors->{$actor_name});

}

method get_actor(Maybe[Str] $actor_name?) {

    $actor_name = $self->get_actor_default
        unless(defined($actor_name));

    (__PACKAGE__ . '::Exception::ActorIsNotDefined')->throwf(
        "No actor has been requested to be referenced, " .
            "although the default actor's name is not defined",
    )
        unless(defined($actor_name));

    unless($self->has_actor($actor_name)) {
        (__PACKAGE__ . '::Exception::ActorIsNotListed')->throwf(
            "The %s actor has been requested to be referenced, " .
                "although it's not listed in the %s index of actors",
            $actor_name, $self->get_actors
        )
            unless($self->get_actor_auto_initialize);

        $self->add_actor($actor_name);
    }

    return($self->get_actors->{$actor_name});

}

method initialize_actor(Str $actor_name!) {

    my %actor_parameters = ();

    %actor_parameters = %{ $self->get_actor_parameters }
        if($self->_has_actor_parameters);

    $actor_parameters{$self->get_actor_parent_to} = $self->get_actor_parent
        if($self->_has_actor_parent_to);

    $actor_parameters{$self->get_actor_name_to} = $actor_name
        if($self->_has_actor_name_to);

    $actor_parameters{'configuration'} = $self->get_configuration_index->{ $actor_name }
        if($self->_has_configuration_index);

    return(($self->get_actor_class)->new(%actor_parameters));

}



1;
