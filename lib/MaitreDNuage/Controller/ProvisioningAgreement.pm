package MaitreDNuage::Controller::ProvisioningAgreement;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use MonkeyMan::Exception qw(PersonNotFound);

use Switch;
use Method::Signatures;
use TryCatch;



method list {
    my @provisioning_agreements;
    my $person          = $self->stash->{'authorized_person_result'};
    my $mask_permitted  = 0b000111;
    my $mask_valid      = 0b000111;
    switch($self->stash->{'filter'}) {
        case('all')         { $mask_valid = 0b000101 }
        case('active')      { $mask_valid = 0b000111 }
        case('archived')    { $mask_valid = 0b001100 }
    }

    $self->stash('provisioning_agreements' => [ $person->find_provisioning_agreements(
        mask_permitted  => $mask_permitted,
        mask_valid      => $mask_valid
    ) ]);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
