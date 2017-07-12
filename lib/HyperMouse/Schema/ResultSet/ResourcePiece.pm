package HyperMouse::Schema::ResultSet::ResourcePiece;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use Method::Signatures;
use DateTime;



method update_when_needed (
    Maybe[Int]  :$parent_resource_piece_id? = undef,
    Int         :$resource_type_id!,
    Int         :$resource_group_id!,
    Str         :$resource_handle!,
    HashRef     :$provisioning_obligation_update?,
    Bool        :$provisioning_obligation_bind?,
    DateTime    :$now? = DateTime->now
) {

    my @resource_pieces = $self
        ->update_smart(
            record => {
                parent_resource_piece_id
                    => $parent_resource_piece_id,
                resource_type_id
                    => $resource_type_id,
                resource_group_id
                    => $resource_group_id,
                resource_handle
                    => $resource_handle
            },
            update_include => {
                fields_match => [ qw(resource_type_id resource_group_id resource_handle) ],
            },
            now => $now
        );

    if(scalar(@resource_pieces) > 1) {
        $self->get_logger->warnf(
            "Multiple resource pieces found, expected only one: %s",
            join(', ', map({ $_->id } @resource_pieces))
        );
    }

    if(defined($provisioning_obligation_update)) {

        my @provisioning_obligations = $self
            ->get_schema
            ->resultset('ProvisioningObligation')
            ->update_when_needed(
                provisioning_agreement_id
                    => $provisioning_obligation_update
                        ->{'provisioning_agreement_id'},
                service_type_id
                    => $provisioning_obligation_update
                        ->{'service_type_id'},
                service_level_id
                    => $provisioning_obligation_update
                        ->{'service_level_id'},
                quantity
                    => $provisioning_obligation_update
                        ->{'quantity'},
                excluded_ids
                    => [ map({
                        $_
                            ->provisioning_obligations
                            ->filter_validated(mask => 0b000111)
                            ->all
                    } @resource_pieces) ],
                now
                    => $now
            );
        if($provisioning_obligation_bind) {
            foreach my $resource_piece (@resource_pieces) {
                foreach my $provisioning_obligation (@provisioning_obligations) {
                    $self
                        ->get_schema
                        ->resultset('ProvisioningObligationXResourcePiece')
                        ->update_smart(
                            record => {
                                provisioning_obligation_id
                                    => $provisioning_obligation->id,
                                resource_piece_id
                                    => $resource_piece->id
                            },
                            update_include => {
                                fields_match => [ qw(provisioning_obligation_id resource_piece_id) ],
                            }
                        );
                }
            }
        }

    }

    return(@resource_pieces);

}



__PACKAGE__->meta->make_immutable;

1;

