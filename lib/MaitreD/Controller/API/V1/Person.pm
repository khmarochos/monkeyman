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
                            page => 0,
                            rows => 10,
                            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                        }
                    )->all
            ];
            
            @{ $json->{'data'} } =
                map {
                    #$_->{'valid_since'} = $self->datetime_display( $_->{'valid_since'}, 2);
                    #$_->{'valid_till'}  = $self->datetime_display( $_->{'valid_till'}, 2) || '∞';
                    $_;
                }
                @{ $json->{'data'} };
            
            
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