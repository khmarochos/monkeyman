package MaitreD::Controller::ProvisioningObligation;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use HyperMouse::Schema::ValidityCheck::Constants ':ALL';
use Method::Signatures;
use TryCatch;
use Switch;
use MaitreD::Extra::API::V1::TemplateSettings;

method list {
    my $settings = $MaitreD::Extra::API::V1::TemplateSettings::settings;
    my $key      = $self->stash->{'related_element'} || 'person';

    $self->stash->{'extra_settings'} =
        $settings->{ $key };
    
    $self->stash->{'title'} = "ProvisioningObligation -> " . $self->stash->{'filter'};
    
    # person/list - пока универсальный шаблон...
    $self->render( template => 'person/list' )     
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
