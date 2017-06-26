package MaitreD::Controller::Contractor;

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
    my $key      = $self->stash->{'related_element'} || 'person';
    $key .= '->list'; 
    $self->stash->{'extra_settings'} =
        $settings->{ $key };
    
    $self->stash->{'title'} = "Contractor -> " . $self->stash->{'filter'};
    $self->render( template => 'person/list' )
    
}

method list_old {
    my $mask_permitted_d = 0b000111; # FIXME: implement HyperMosuse::Schema::PermissionCheck and define the PC_* constants
    my $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    switch($self->stash->{'filter'}) {
        case('all')         {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE;
        }
        case('active')      {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
        }
        case('archived')    {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_EXPIRED;
        }
    }
    switch($self->stash->{'related_element'}) {
        case('person') {
            my $person_id =
                ($self->stash->{'related_id'} ne '@') ?
                 $self->stash->{'related_id'} :
                 $self->stash->{'authorized_person_result'}->id;
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $person_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ]
                    )
                    ->all
            ]);
        } case('provisioning_agreement') {
            my $provisioning_agreement_id = $self->stash->{'related_id'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->search({ id => $provisioning_agreement_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningAgreement-[client|provider]>-Contractor' => { } ]
                    )
                    ->all
            ]);
        } case('provisioning_obligation') {
            my $provisioning_obligation_id = $self->stash->{'related_id'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningObligation')
                    ->search({ id => $provisioning_obligation_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningObligation->-Contractor' => { } ]
                    )
                    ->all
            ]);
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
