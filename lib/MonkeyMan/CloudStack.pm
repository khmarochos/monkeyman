package MonkeyMan::CloudStack;

use strict;
use warnings;

use MonkeyMan::CloudStack::Configuration;
use MonkeyMan::CloudStack::API;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';



has 'configuration_tree' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => 'get_configuration_tree',
    writer      => '_set_configuration_tree',
    required    => 1
);

has 'configuration' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Configuration',
    reader      => 'get_configuration',
    writer      => '_set_configuration',
    builder     => '_build_configuration',
    alias       => 'configuration',
    lazy        => 1
);

sub _build_configuration {

    my $self = shift;

    MonkeyMan::CloudStack::Configuration->new(
        cloudstack  => $self,
        tree        => $self->get_configuration_tree
    );

}

has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      => '_get_api',
    writer      => '_set_api',
    builder     => '_build_api',
    alias       => 'api',
    lazy        => 1
);

sub _build_api {

    my $self = shift;

    MonkeyMan::CloudStack::API->new(
        cloudstack  => $self
    );

}

#has 'cache' => (
#    is          => 'ro',
#    isa         => 'MonkeyMan::CloudStack::Cache',
#    reater      => '_get_cache',
#    writer      => '_set_cache',
#    predicate   => '_has_cache',
#    builder     => '_build_cache',
#    lazy        => 1
#);



__PACKAGE__->meta->make_immutable;

1;
