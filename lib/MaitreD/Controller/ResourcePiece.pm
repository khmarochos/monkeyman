package MaitreD::Controller::ResourcePiece;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use HyperMouse::Schema::ValidityCheck::Constants ':ALL';
use Method::Signatures;
use TryCatch;
use Switch;

method list {
    my $settings = $MaitreD::Extra::API::V1::TemplateSettings::settings;

    $self->stash->{'extra_settings'} = $settings->{ 'resource_piece' };
    
    $self->stash->{'title'} = "ResourcePiece -> " . $self->stash->{'filter'};
    
    # person/list - пока универсальный шаблон...
    $self->render( template => 'person/list' )     
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
