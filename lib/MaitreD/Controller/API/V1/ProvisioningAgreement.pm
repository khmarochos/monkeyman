package MaitreD::Controller::API::V1::ProvisioningAgreement;

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
use MaitreD::Extra::API::V1::TemplateSettings;

method list {
    my $settings         = $MaitreD::Extra::API::V1::TemplateSettings::settings;
    my $json             = {};
    my $mask_permitted_d = 0b000111; # FIXME: implement HyperMosuse::Schema::PermissionCheck and define the PC_* constants
    my $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $mask_permitted_f = 0b000111;
    my $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $tmpl_rs;
    my $datatable_params = $self->datatable_params;

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
                ($self->stash->{'related_id'} ne '@') ?
                 $self->stash->{'related_id'} :
                 $self->stash->{'authorized_person_result'}->id;

            $tmpl_rs =
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ 'me.id' => $person_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'ProvisioningAgreement',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ '@Person->-((((@->-@Corporation->-@Contractor)-&-(@->-@Contractor))-[client|provider]>-@ProvisioningAgreement)-&-(@->-@ProvisioningAgreement))' => { } ]
                    );
            
        
        } case('contractor') {
        
            my $person_id =
                ($self->stash->{'related_id'} ne '@') ?
                 $self->stash->{'related_id'} :
                 $self->stash->{'authorized_person_result'}->id;

            $tmpl_rs =
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ 'me.id' => $person_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'ProvisioningAgreement',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        #callout => [ '@Contractor-[client|provider] > @ProvisioningAgreement' => { } ]
                        callout => ['@ProvisioningAgreement-[client|provider]>-@Contractor' => { } ]
                    );
        
        }
    }
    
    $json->{'data'} = [
            $tmpl_rs->search({},
                {
                    page         => $datatable_params->{'page'},
                    rows         => $datatable_params->{'rows'},
                    order_by     => $datatable_params->{'order'},
                }
            )->all
    ];    
    
    my $columns = $settings->{'provisioning_agreement'}->{'table'}->{'columns'};
                
    @{ $json->{'data'} } = map {
        my $hash = {};
        
        for my $col ( keys %$columns ){
            my $name  = $columns->{$col}->{'db_name'};
            my $value = $columns->{$col}->{'db_value'};
#                   
            if(defined($name) && defined($value)) {
                $hash->{ $name } = ref($value) eq 'CODE'
                    ? $value->($self, $_)
                    : $_->{ $name };
            } else {
                # TODO: Something should happen here
                next;
            }
            
        }
        
        $hash;
    }
    @{ $json->{'data'} };
    
    $json->{'pos'}         = $datatable_params->{'start'};
    $json->{'total_count'} = $tmpl_rs->count;
            
    $self->render( json => $json );      
}

method form_load {
    my $data = $self->datatable_params();

    my $json = { success => \1 };

    $json->{'data'} =
        $self
            ->hm_schema
            ->resultset('ProvisioningAgreement')
            ->find({
                'me.id' => $self->stash->{'id'}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            });
    
    $self->render(json => $json);
}


method form_add {
    my $data          = $self->datatable_params()->{'origin_data'};
    my $snippet       = {};
    my $snippet_link  = {
        'person_x_provisioning_agreement' => {
            table          => 'PersonXProvisioningAgreement',
            col_not_empty  => ['person_id']
        },
    };  

    my $json = {
        success  => \1,
        redirect => "/provisioning_agreement/list/all"
    };
    
    ( $snippet, $data ) = $self->snippet( $snippet_link, $data );

    try {
                                
        $self->hm_schema->txn_do( sub {
            my $rs_data =
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->create( {
                        name                   => $data->{'name'},
                        valid_till             => $data->{'valid_till'}  || undef,
                        valid_from             => $data->{'valid_from'} || \'NOW()',
                        client_contractor_id   => $data->{'client_contractor_id'},
                        provider_contractor_id => $data->{'provider_contractor_id'}
                    });
            
            if( $rs_data ){
            
                for my $item ( @{ $snippet->{'person_x_provisioning_agreement'} } ){
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_provisioning_agreement'}->{'table'} )
                        ->create({
                            person_id   => $item->{'person_id'},
                            valid_till  => $item->{'valid_till'} || undef,
                            valid_from  => $item->{'valid_from'} || \'NOW()',
                            provisioning_agreement_id => $rs_data->id,
                            admin       => $item->{'admin'},
                            billing     => $item->{'billing'},
                            tech        => $item->{'tech'}                            
                        });                    
                }
                
            } # if
    
        });
        
    }
    catch ($e) {
        $json = {
            success => \0,
            message => $e
        };                
    }    
    
    $self->render(json => $json);
}

method form_update {
    my $data          = $self->datatable_params()->{'origin_data'};
    my $snippet       = {};
    my $snippet_link  = {
        'person_x_provisioning_agreement' => {
            table          => 'PersonXProvisioningAgreement',
            col_not_empty  => ['person_id']
        },
    };
    my $provisioning_agreement_id  = $data->{'id'};
    
    my $json = {
        success  => \1,
        redirect => "/provisioning_agreement/list/all"
    };
    
    ( $snippet, $data ) = $self->snippet( $snippet_link, $data );
    

    try {

        $self->hm_schema->txn_do( sub {
            my $rs_find =
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->find( { 'me.id' => $provisioning_agreement_id } );
            
            if( $rs_find ){
                
                $rs_find->update({
                    name                   => $data->{'name'},
                    valid_till             => $data->{'valid_till'} || undef,
                    valid_from             => $data->{'valid_from'} || $rs_find->{'valid_from'},
                    client_contractor_id   => $data->{'client_contractor_id'},
                    provider_contractor_id => $data->{'provider_contractor_id'}                    
                });
                                                
            }
            else{
                $json = {
                    success => \0,
                    message => 'Server error'
                };                                
            }
            
            
            if(
                ${$json->{'success'}}
                && ref $snippet->{'person_x_provisioning_agreement'} eq "ARRAY"
                && @{ $snippet->{'person_x_provisioning_agreement'} }
            ){ 
                # Удаляем старые 
                my( @update, @new ) = ( (),() );
                
                for my $item ( @{ $snippet->{'person_x_provisioning_agreement'} } ) {
                    if( $item->{'id'} ){
                        push @update, $item;
                    }
                    elsif( $item->{'person_id'} ) {
                        push @new, $item;
                    }
                }
                
                $rs_find = 
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_provisioning_agreement'}->{'table'} )
                        ->search({
                            provisioning_agreement_id  => $provisioning_agreement_id,
                            id          => {
                                -not_in     => [                                            
                                    map{ $_->{'id'} } @update
                                ]
                            }
                        });
                                        
                if( $rs_find ){
                    $rs_find->delete();
                }
                
                # Обновляем старые
                for my $item ( @update ){
                    $rs_find = 
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_provisioning_agreement'}->{'table'} )
                            ->find({                                        
                                'me.id' => $item->{'id'}
                            });
    
                    if( $rs_find ){
                        $rs_find->update({
                            valid_from  => $item->{'valid_from'}  || $rs_find->valid_from,
                            valid_till  => $item->{'valid_till'}  || $rs_find->valid_till,
                            person_id   => $item->{'person_id'},
                            admin       => $item->{'admin'},
                            billing     => $item->{'billing'},
                            tech        => $item->{'tech'}
                            
                        });
                    }     
                }
                # Добавляем новые
                for my $item ( @new ){
                    $rs_find = 
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_provisioning_agreement'}->{'table'} )
                            ->search({
                                'me.person_id'                 => $item->{'person_id'},
                                'me.provisioning_agreement_id' => $provisioning_agreement_id,
                            })
                            ->first;
                                                        
                    if( $rs_find ){
                        
                        $json = {
                            success => \0,
                            message => "",
                        };
                        last;
                        
                    }
                    else {
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_provisioning_agreement'}->{'table'} )
                            ->create({
                                valid_from                 => $item->{'valid_from'}  || undef,
                                valid_till                 => $item->{'valid_till'}  || undef,
                                provisioning_agreement_id  => $provisioning_agreement_id,
                                person_id                  => $item->{'person_id'},
                                admin                      => $item->{'admin'},
                                billing                    => $item->{'billing'},
                                tech                       => $item->{'tech'}
                            });
                        
                    }
                }
                
            }
            elsif( ${$json->{'success'}} ) {
                # если список пустой удалем все 
            }            
        });
        
    }
    catch ($e) {
        $json = {
            success => \0,
            message => $e
        };                
    }      
    
    
    $self->render(json => $json);
}

method form_remove {
    my $data = $self->datatable_params()->{'origin_data'};
    my $id   = $self->{stash}->{'id'};


    my $json = {
        success  => \1,
        redirect => "/provisioning_agreement/list/all"
    };
    
    try {
        my $rs_find =
            $self
                ->hm_schema
                ->resultset('ProvisioningAgreement')
                ->find( { 'me.id' => $id } );
        
        if( $rs_find ){
            $rs_find->update( {
                removed => \'NOW()',
            } );
        }
    }
    catch ($e) {
        $json = {
            success => \0,
            message => $e
        };                
    };
    
    
    $self->render(json => $json);
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;