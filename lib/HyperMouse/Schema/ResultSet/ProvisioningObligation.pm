package HyperMouse::Schema::ResultSet::ProvisioningObligation;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use Method::Signatures;



method update_obligations (
    HyperMouse::Schema::Result::ProvisioningAgreement
        :$provisioning_agreement,
    HyperMouse::Schema::Result::ResourcePiece
        :$resource_piece,
    Int
        :$service_type_id,
    Int
        :$service_level_id,
    Int
        :$quantity,
    DateTime
        :$now = DateTime->now
) {
    my $provisioning_obligation_found = 0;
    my $provisioning_obligations = $resource_piece
        ->provisioning_obligation_x_resource_pieces
        ->filter_validated(mask => 0b000111)
        ->search_related('provisioning_obligation', {
            provisioning_agreement_id   => $provisioning_agreement->id,
            service_type_id             => $service_type_id,
            service_level_id            => $service_level_id,
        })
        ->filter_validated(mask => 0b000111);
    foreach my $provisioning_obligation ($provisioning_obligations->all) {
        if($provisioning_obligation->quantity == $quantity) {
            $provisioning_obligation_found++;
        } else {
            $provisioning_obligation->update({ valid_till => $now });
            $provisioning_obligation
                ->provisioning_obligation_x_resource_pieces
                ->update({ valid_till => $now });
        }
    }
    unless($provisioning_obligation_found) {
        my $provisioning_obligation = $self->get_schema
            ->resultset('ProvisioningObligation')
            ->create({
                valid_since                 => $now,
                valid_till                  => undef,
                removed                     => undef,
                provisioning_agreement_id   => $provisioning_agreement->id,
                service_type_id             => $service_type_id,
                service_level_id            => $service_level_id,
                quantity                    => $quantity
            });
        $self->get_schema
            ->resultset('ProvisioningObligationXResourcePiece')
            ->create({
                valid_since                 => $now,
                valid_till                  => undef,
                removed                     => undef,
                provisioning_obligation_id  => $provisioning_obligation->id,
                resource_piece_id           => $resource_piece->id
            });
    } elsif($provisioning_obligation_found > 1) {
        $self->get_logger->warnf("A group of possible dupes has been found: %s",
            join(', ',
                map(
                    { $_->id }
                        $provisioning_obligations
                            ->search({ quantity => $quantity })
                )
            )
        );
    }
}



__PACKAGE__->meta->make_immutable;

1;

