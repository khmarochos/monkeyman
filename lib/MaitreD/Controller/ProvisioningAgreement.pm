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
    my $key      = $self->stash->{'related_element'} || 'person';

    $self->stash->{'extra_settings'} =
        $settings->{ $key };
    
    $self->stash->{'title'} = "ProvisioningAgreement -> " . $self->stash->{'filter'};
    
    $self->render( template => 'person/list' );    
}

method list_old {
    my $mask_permitted_d = 0b000111; # FIXME: implement HyperMosuse::Schema::PermissionCheck and define the PC_* constants
    my $mask_permitted_f = $mask_permitted_d;
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
            $self->stash->{'tables'} = [ {
                title   => 'Provisioning Agreements',
                name    => 'provisioning_agreements_1',
                data    => [
                    $self
                        ->hm_schema
                        ->resultset('Person')
                        ->search({ id => $person_id })
                        ->filter_validated(mask => VC_NOT_REMOVED)
                        ->search_related_deep(
                            resultset_class            => 'ProvisioningAgreement',
                            fetch_permissions_default  => $mask_permitted_f,
                            fetch_validations_default  => $mask_validated_f,
                            search_permissions_default => $mask_permitted_d,
                            search_validations_default => $mask_validated_d,
                            callout => [ 'Person->-((((@->-Corporation->-Contractor)-&-(@->-Contractor))-[client|provider]>-ProvisioningAgreement)-&-(@->-ProvisioningAgreement))' => { } ]
                        )
                        ->all
                ]
            } ];
        } case('contractor') {
            my $person_id =
                ($self->stash->{'related_id'} ne '@') ?
                 $self->stash->{'related_id'} :
                 $self->stash->{'authorized_person_result'}->id;
            $self->stash->{'tables'} = [ {
                title   => 'Provisioning Agreements',
                data    => [
                    $self
                        ->hm_schema
                        ->resultset('Person')
                        ->search({ id => $person_id })
                        ->filter_validated(mask => VC_NOT_REMOVED)
                        ->search_related_deep(
                            resultset_class            => 'ProvisioningAgreement',
                            fetch_permissions_default  => $mask_permitted_f,
                            fetch_validations_default  => $mask_validated_f,
                            search_permissions_default => $mask_permitted_d,
                            search_validations_default => $mask_validated_d,
                            callout => [ 'Contractor-[client|provider]>-ProvisioningAgreement' => { } ]
                        )
                        ->all
                ]
            } ]
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
