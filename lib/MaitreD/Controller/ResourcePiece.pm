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
    my $mask_permitted = 0b000111;
    my $mask_validated = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    switch($self->stash->{'filter'}) {
        case('all')         { $mask_validated = VC_NOT_REMOVED & VC_NOT_PREMATURE }
        case('active')      { $mask_validated = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED }
        case('archived')    { $mask_validated = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_EXPIRED }
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
                    ->single
                    ->search_related_provisioning_agreements(mask_permitted => $mask_permitted)
                    ->search_related('provisioning_obligations')
                    ->filter_validated(mask => $mask_validated)
                    ->search_related('provisioning_obligation_x_resource_pieces')
                    ->filter_validated(mask => $mask_validated)
                    ->search_related('resource_piece', {}, { distinct => 1 })
                    ->filter_validated(mask => $mask_validated)
                    ->all
            ]);
        }
        case('provisioning_agreement') {
            my $provisioning_agreement_id = $self->stash->{'related_id'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->search({ id => $provisioning_agreement_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->single
                    ->search_related('provisioning_obligations')
                    ->filter_validated(mask => $mask_validated)
                    ->search_related('provisioning_obligation_x_resource_pieces')
                    ->filter_validated(mask => $mask_validated)
                    ->search_related('resource_piece', {}, { distinct => 1 })
                    ->filter_validated(mask => $mask_validated)
                    ->all
            ]);
        }
        case('provisioning_obligation') {
            my $provisioning_obligation_id = $self->stash->{'related_id'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningObligation')
                    ->search({ id => $provisioning_obligation_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->single
                    ->search_related('provisioning_obligation_x_resource_pieces')
                    ->filter_validated(mask => $mask_validated)
                    ->search_related('resource_piece', {}, { distinct => 1 })
                    ->filter_validated(mask => $mask_validated)
                    ->all
            ]);
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
