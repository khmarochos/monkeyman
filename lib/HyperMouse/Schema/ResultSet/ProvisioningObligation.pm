package HyperMouse::Schema::ResultSet::ProvisioningObligation;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use HyperMouse::Schema::ValidityCheck::Constants qw(:ALL);

use Method::Signatures;
use DateTime;



method update_when_needed (
    DateTime        :$valid_since?,
    Int             :$provisioning_agreement_id!,
    Maybe[Int]      :$resource_piece_id?,
    Int             :$service_type_id!,
    Int             :$service_level_id!,
    Int             :$quantity!,
    Maybe[DateTime] :$applied_since?,
    Maybe[DateTime] :$applied_till?,
    DateTime        :$now?              = DateTime->now
) {


    my $dtp = $self->get_schema->storage->datetime_parser;

    my @provisioning_obligations = $self
        ->update_smart(
            record => {
                provisioning_agreement_id
                    => $provisioning_agreement_id,
                resource_piece_id
                    => $resource_piece_id,
                service_type_id
                    => $service_type_id,
                service_level_id
                    => $service_level_id,
                quantity
                    => $quantity,
                applied_since
                    => $dtp->format_datetime($applied_since),
                applied_till
                    => $dtp->format_datetime($applied_till)
            },
            update_include => {
                fields_match => [ qw(
                    provisioning_agreement_id
                    resource_piece_id
                    service_type_id
                    service_level_id
                    applied_since
                    applied_till
                ) ]
            },
            now
                => defined($valid_since) ? $valid_since : $now
        );

    if(scalar(@provisioning_obligations) > 1) {
        $self->get_logger->warnf(
            "Multiple provisioning obligations updated, expected only one: %s",
            join(', ', map({ $_->id } @provisioning_obligations))
        );
    }

    return(@provisioning_obligations);

}

method update_when_needed_multi(
    ArrayRef    :$records,
    Maybe[Int]  :$resource_piece_id?,
    DateTime    :$now? = DateTime->now
) {

    my @provisioning_obligations;
    my $applied_since = $now->clone->truncate(to => 'day');
    my $applied_till;

    # As the first step, we need to find the list of the valid provisioning
    # obligations for each resource piece

    my $dtp = $self->get_schema->storage->datetime_parser;
    my $i = 0;
    foreach my $record (
        # The record that already has the same values goest the first, because
        # it should be added as a piece of the previous record.
        sort({
            if($self
                ->filter_validated(now => $now)
                ->search({
                    provisioning_agreement_id
                        => $a->{'provisioning_agreement_id'},
                    resource_piece_id
                        => $a->{'resource_piece_id'},
                    service_type_id
                        => $a->{'service_type_id'},
                    service_level_id
                        => $a->{'service_level_id'},
                    quantity
                        => $a->{'quantity'},
                    applied_since
                        => { '<=' => $dtp->format_datetime($applied_since) }
                })
                ->count
            ) { -1 } else { 1 };
        } @{ $records })
    ) {
        $applied_till = $applied_since->clone;
        $applied_till->add(seconds => $record->{'duration'})
            if(defined($record->{'duration'}));
        push(@provisioning_obligations, $self->update_when_needed(
            provisioning_agreement_id
                => $record->{'provisioning_agreement_id'},
            resource_piece_id
                => $record->{'resource_piece_id'},
            service_type_id
                => $record->{'service_type_id'},
            service_level_id
                => $record->{'service_level_id'},
            quantity
                => $record->{'quantity'},
            resource_piece_id
                => $resource_piece_id,
            applied_since
                => $applied_since,
            applied_till
                => $applied_till,
            now
                => $now,
        ));
        $applied_since = $applied_till;
    }

    return(@provisioning_obligations);

}



=for comment

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

=cut



__PACKAGE__->meta->make_immutable;

1;

