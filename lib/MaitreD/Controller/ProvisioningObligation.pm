package MaitreD::Controller::ProvisioningObligation;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use Method::Signatures;
use TryCatch;
use Switch;



method list {
    my $mask_permitted  = 0b000111;
    my $mask_valid      = 0b000111;
    switch($self->stash->{'filter'}) {
        case('all')         { $mask_valid = 0b000101 }
        case('active')      { $mask_valid = 0b000111 }
        case('archived')    { $mask_valid = 0b001100 }
    };
    switch($self->stash->{'related_element'}) {
        case('provisioning_agreement') {
            my $provisioning_agreement_id = $self->stash->{'related_id'};
            $self->stash('rows' => [
                $self
                    ->hm_schema
                    ->resultset("ProvisioningAgreement")
                    ->search({ id => $provisioning_agreement_id })
                    ->filter_valid
                    ->single
                    ->provisioning_obligations
                    ->filter_valid(mask => $mask_valid)
                    ->all
            ]);
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
