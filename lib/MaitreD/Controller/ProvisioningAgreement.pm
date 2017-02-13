package MaitreD::Controller::ProvisioningAgreement;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use MonkeyMan::Exception qw(PersonNotFound);

use Method::Signatures;
use TryCatch;
use Switch;



method list {
    my @provisioning_agreements;
    my $person          = $self->stash->{'authorized_person_result'};
    my $mask_permitted  = 0b000111;
    my $mask_valid      = 0b000111;
    switch($self->stash->{'filter'}) {
        case('all')         { $mask_valid = 0b000101 }
        case('active')      { $mask_valid = 0b000111 }
        case('archived')    { $mask_valid = 0b001100 }
    };
    switch($self->stash->{'related_element'}) {
        case('person') {
            $self->stash('rows' => [ $person->find_provisioning_agreements(
                mask_permitted  => $mask_permitted,
                mask_valid      => $mask_valid
            ) ]);
        }
    }
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
