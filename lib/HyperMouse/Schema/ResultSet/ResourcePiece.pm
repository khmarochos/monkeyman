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
    Int         :$resource_set_id!,
    Str         :$resource_handle!,
    Ref         :$provisioning_obligation_update?,
    Bool        :$provisioning_obligation_bind?,
    DateTime    :$now? = DateTime->now
) {

    $self->get_schema->txn_begin;

    my @resource_pieces = $self
        ->update_smart(
            record => {
                parent_resource_piece_id
                    => $parent_resource_piece_id,
                resource_type_id
                    => $resource_type_id,
                resource_set_id
                    => $resource_set_id,
                resource_handle
                    => $resource_handle
            },
            update_include => {
                fields_match => [ qw(resource_type_id resource_set_id resource_handle) ],
            },
            now => $now
        );

    if(scalar(@resource_pieces) > 1) {
        $self->get_logger->warnf(
            "Multiple resource pieces updated, expected only one: %s",
            join(', ', map({ $_->id } @resource_pieces))
        );
    }

    if(defined($provisioning_obligation_update)) {

        my $provisioning_obligation_records = [ (ref($provisioning_obligation_update) eq 'ARRAY')
            ? @{ $provisioning_obligation_update }
            :  ( $provisioning_obligation_update )
        ];

        my @provisioning_obligations = $self
            ->get_schema
            ->resultset('ProvisioningObligation')
            ->update_when_needed_multi(
                records
                    => $provisioning_obligation_records,
                resource_piece_id
                    => $provisioning_obligation_bind ? $resource_pieces[$[]->id : undef,
                now
                    => $now
            );

    }

    $self->get_schema->txn_commit;

    return(@resource_pieces);

}



__PACKAGE__->meta->make_immutable;

1;

