package MaitreD::Controller::ProvisioningAgreement;

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

    $self->stash->{'extra_settings'} = $settings->{ 'provisioning_agreement' };
    
    $self->stash->{'title'} = "ProvisioningAgreement -> " . $self->stash->{'filter'};
    
    $self->render( template => 'person/list' );    
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
