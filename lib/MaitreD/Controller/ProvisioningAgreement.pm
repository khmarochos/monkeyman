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



method list {
    my @provisioning_agreements;
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
                    ->search_related_provisioning_agreements(
                        mask_permitted  => $mask_permitted,
                        mask_validated  => $mask_validated
                    )
                    ->all
            ]);
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
