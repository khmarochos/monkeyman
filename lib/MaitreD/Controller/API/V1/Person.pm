package MaitreD::Controller::API::V1::Person;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use HyperMouse::Schema::ValidityCheck::Constants ':ALL';
use Method::Signatures;
use TryCatch;
use Switch;
use DateTime;
use Data::Dumper;

method list {
    my $json             = {};
    my $mask_permitted_d = 0b000111; 
    my $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    
    switch($self->stash->{'filter'}) {
        case('all') {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE;
        }
        case('active') {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
        }
        case('archived') {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_EXPIRED;
        }
    }

    my $datatable_params = $self->datatable_params;

    switch($self->stash->{'related_element'}) {
        case('') {
            $self->stash->{'title'} = "Person -> " . $self->stash->{'filter'};
            
            $json->{'data'} = [
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $self->stash->{'authorized_person_result'}->id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Person-[everything]>-Person' => { } ]
                    )
                    ->search({},
                        {
                            page         => $datatable_params->{'page'},
                            rows         => $datatable_params->{'rows'},
                            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                            order_by     => $datatable_params->{'order'},
                        }
                    )->all
            ];
            
            @{ $json->{'data'} } = map {
                $_->{"DT_RowId"} = "row_" . $_->{'id'};
                $_;
            } @{ $json->{'data'} };
            
            $json->{'recordsTotal'} =
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $self->stash->{'authorized_person_result'}->id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Person-[everything]>-Person' => { } ]
                    )
                    ->count;
            
            $json->{'recordsFiltered'} = $json->{'recordsTotal'} = 100;
        }
    }
            
    $self->render( json => $json );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;