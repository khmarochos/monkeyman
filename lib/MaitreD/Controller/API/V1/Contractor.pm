package MaitreD::Controller::API::V1::Contractor;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use HyperMouse::Schema::ValidityCheck::Constants ':ALL';
use Method::Signatures;
use TryCatch;
use Switch;
use DateTime;
use Data::Dumper;
use MaitreD::Extra::API::V1::TemplateSettings;

my $settings = $MaitreD::Extra::API::V1::TemplateSettings::settings;

method list {
    my $json = {};
    my $mask_permitted_d = 0b000111; # FIXME: implement HyperMosuse::Schema::PermissionCheck and define the PC_* constants
    my $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    
    switch($self->stash->{'filter'}) {
        case('all')         {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE;
        }
        case('active')      {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
        }
        case('archived')    {
            $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE;
            $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_EXPIRED;
        }
    }
    
    switch($self->stash->{'related_element'}) {
        case('person') {
            my $person_id =
                ($self->stash->{'related_id'} ne '@')
                    ? $self->stash->{'related_id'}
                    : $self->stash->{'authorized_person_result'}->id
                    ;
            
            $json->{'data'} = [
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $person_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ]
                    )
                    ->search({},
                        {
                            page         => $datatable_params->{'page'},
                            rows         => $datatable_params->{'rows'},
                            order_by     => $datatable_params->{'order'},
                        }
                    )->all
            ];
            
            $json->{'recordsTotal'} =            
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $person_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ]
                    )->count;
                    
        } case('provisioning_agreement') {
            
            my $provisioning_agreement_id = $self->stash->{'related_id'};
            
            $json->{'data'} = [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->search({ id => $provisioning_agreement_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningAgreement-[client|provider]>-Contractor' => { } ]
                    )
                    ->search({},
                        {
                            page         => $datatable_params->{'page'},
                            rows         => $datatable_params->{'rows'},
                            order_by     => $datatable_params->{'order'},
                        }
                    )->all
            ];
            
            $json->{'recordsTotal'} =
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->search({ id => $provisioning_agreement_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningAgreement-[client|provider]>-Contractor' => { } ]
                    )
                    ->count;
            
        } case('provisioning_obligation') {
            
            my $provisioning_obligation_id = $self->stash->{'related_id'};
            
            $json->{'data'} = [
                $self
                    ->hm_schema
                    ->resultset('ProvisioningObligation')
                    ->search({ id => $provisioning_obligation_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningObligation->-Contractor' => { } ]
                    )
                    ->search({},
                        {
                            page         => $datatable_params->{'page'},
                            rows         => $datatable_params->{'rows'},
                            order_by     => $datatable_params->{'order'},
                        }
                    )->all
            ];
            
            $json->{'recordsTotal'} =
                $self
                    ->hm_schema
                    ->resultset('ProvisioningObligation')
                    ->search({ id => $provisioning_obligation_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningObligation->-Contractor' => { } ]
                    )->count;            
        }
    }
    
    my $columns =
        $settings->{'person->list'}
            ->{'snippets->table_json'}
                ->{'columns'};
                
    @{$json->{'data'}} = map {
        my $hash = {};
        
        for my $col ( keys %$columns ){
            my $name = $columns->{$col}->{'db_name'};
            my $fh   = $columns->{$col}->{'db_value'};
#                   
            if ( $name && $fh && ref $fh eq 'CODE' ) {
                $hash->{ $name } =
                    $fh->( $self, $_ );                        
            }
            elsif( $name ){
                $hash->{'name'} = $_->$name;
            }
        }
        
        $hash;
    }
    @{ $json->{'data'} };
    
    $json->{'recordsFiltered'} = $json->{'recordsTotal'};    
    
    $self->render( json => $json );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);    