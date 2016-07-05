package MonkeyMan::CloudStack::API::Request;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::API::Essentials';
with 'MonkeyMan::Roles::WithTimer';

#use MonkeyMan::Exception qw();

use Method::Signatures;



has type => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Types::ElementType',
    reader      =>  'get_type',
    writer      => '_set_type',
    required    => 1,
    lazy        => 0
);

has action => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>  'get_action',
    writer      => '_set_action',
    required    => 1,
    lazy        => 0
);

has parameters => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    reader      =>  'get_parameters',
    writer      => '_set_parameters',
    required    => 0,
    lazy        => 0
);

has macros => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    reader      =>  'get_macros',
    writer      => '_set_macros',
    predicate   =>  'has_macros',
    required    => 0,
    lazy        => 0
);

has command => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API::Command',
    reader      =>    'get_command',
    writer      =>   '_set_command',
    predicate   =>    'has_command',
    builder     => '_build_everything',
    required    => 0,
    lazy        => 1,
);

has filters => (
    is          => 'ro',
    isa         => 'ArrayRef[Str]',
    reader      =>    'get_filters',
    writer      =>   '_set_filters',
    predicate   =>    'has_filters',
    builder     => '_build_everything',
    required    => 0,
    lazy        => 1,
);

has async => (
    is          => 'ro',
    isa         => 'Bool',
    reader      =>    'get_async',
    writer      =>   '_set_async',
    predicate   =>    'has_async',
    builder     => '_build_everything',
    required    => 0,
    lazy        => 1,
);

has paged => (
    is          => 'ro',
    isa         => 'Bool',
    reader      =>    'get_paged',
    writer      =>   '_set_paged',
    predicate   =>    'has_paged',
    builder     => '_build_everything',
    required    => 0,
    lazy        => 1,
);

method _build_everything {

    my $r = $self->get_api->get_vocabulary($self->get_type)->compose_request(
        action              => $self->get_action,
        parameters          => $self->get_parameters,
        macros              => $self->get_macros,
        return_as_hashref   => 1
    );
    $self->_set_command($r->{'command'});
    $self->_set_filters($r->{'filters'});
    $self->_set_async(  $r->{'async'});
    $self->_set_paged(  $r->{'paged'});

}



__PACKAGE__->meta->make_immutable;

1;
