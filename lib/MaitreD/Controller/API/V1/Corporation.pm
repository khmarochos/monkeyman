package MaitreD::Controller::API::V1::Corporation;

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
use JSON::XS;
use Try::Tiny;

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
    
    switch($self->stash->{'filter'}) {
        case('related_to') {
            
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
                            ->search({ id => $person_id })
                            ->filter_validated(mask => VC_NOT_REMOVED)
                            ->search_related_deep(
                                resultset_class            => 'Corporation',
                                fetch_permissions_default  => $mask_permitted_f,
                                fetch_validations_default  => $mask_validated_f,
                                search_permissions_default => $mask_permitted_d,
                                search_validations_default => $mask_validated_d,
                                callout => [ 'Person->-Corporation' => { } ]
                            );
                                                
                    
                } case('provisioning_agreement') {
                    
                    my $provisioning_agreement_id = $self->stash->{'related_id'};
                    
                    $tmpl_rs =
                        $self
                            ->hm_schema
                            ->resultset('ProvisioningAgreement')
                            ->search({ id => $provisioning_agreement_id })
                            ->filter_validated(mask => VC_NOT_REMOVED)
                            ->search_related_deep(
                                resultset_class            => 'Corporation',
                                fetch_permissions_default  => $mask_permitted_f,
                                fetch_validations_default  => $mask_validated_f,
                                search_permissions_default => $mask_permitted_d,
                                search_validations_default => $mask_validated_d,
                                callout => [ '@ProvisioningAgreement [client]> @Corporation' => { } ]
                            );
                    
                } case('provisioning_obligation') {
                    
                    my $provisioning_obligation_id = $self->stash->{'related_id'};
                    
                    $tmpl_rs =
                        $self
                            ->hm_schema
                            ->resultset('ProvisioningObligation')
                            ->search({ id => $provisioning_obligation_id })
                            ->filter_validated(mask => VC_NOT_REMOVED)
                            ->search_related_deep(
                                resultset_class            => 'Corporation',
                                fetch_permissions_default  => $mask_permitted_f,
                                fetch_validations_default  => $mask_validated_f,
                                search_permissions_default => $mask_permitted_d,
                                search_validations_default => $mask_validated_d,
                                callout => [ provisioning_obligation_TO_corporation => { } ]
                            );
                    
                }
                
            } #
        
        }
        else {
            
            $tmpl_rs = 
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ id => $self->stash->{'authorized_person_result'}->id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Corporation',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ person_TO_corporation_FULL => { } ]
                    );
        }
        
    }
    
    my $columns = $settings->{'corporation'}->{'table'}->{'columns'};
                
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
    
    my $json = { success =>\1 };
    
    $json->{'data'} =
        $self
            ->hm_schema
            ->resultset('Corporation')
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
        'person_x_corporation'     => 'PersonXCorporation',
        'corporation_x_contractor' => 'CorporationXContractor',
    };

    my $json = {
        success  => \1,
        redirect => "/corporation/list/all"
    };
    
    for my $key ( keys %{ $snippet_link }) {
        if ( $data->{ $key } ) {
            $snippet->{ $key } = decode_json( $data->{ $key } );
            delete $data->{ $key };
        }
        
        if( ref $data->{ $key } eq "ARRAY" && @{ $data->{ $key } } ) {
            $snippet->{ $key } = $data->{ $key };
        }
        
    }
    
    #try {
        
        $self->hm_schema->txn_do( sub {
            my $rs_data =
                $self
                    ->hm_schema
                    ->resultset('Corporation')
                    ->create( {
                        name               => $data->{'name'},
                        valid_till         => $data->{'valid_till'}  || undef,
                        valid_since        => $data->{'valid_since'} || \'NOW()',
                        provider           => $data->{'provider'},
                    } );

            for my $item ( @{ $snippet->{'person_x_corporation'} } ){
                $self
                    ->hm_schema
                    ->resultset( $snippet_link->{'person_x_corporation'} )
                    ->create({
                        person_id      => $item->{'person_id'},
                        corporation_id => $rs_data->id,
                        valid_till     => $item->{'valid_till'}  || undef,
                        valid_since    => $item->{'valid_since'} || \'NOW()',
                        admin          => $item->{'admin'},
                        billing        => $item->{'billing'},
                        tech           => $item->{'tech'}
                    });                
            }
            
            for my $item ( @{ $snippet->{'corporation_x_contractor'} } ){
                $self
                    ->hm_schema
                    ->resultset( $snippet_link->{'corporation_x_contractor'} )
                    ->create({
                        contractor_id  => $item->{'contractor_id'},
                        corporation_id => $rs_data->id,
                        valid_till     => $item->{'valid_till'}  || undef,
                        valid_since    => $item->{'valid_since'} || \'NOW()',
                    });                
            }              

        });

    #}
    #catch {
    #    my $err = $_;
    #    $json = {
    #        success  => \0,
    #        message => $err
    #    };          
    #};
    
    $self->render(json => $json);
}

method form_update {
    my $data          = $self->datatable_params()->{'origin_data'};
    my $snippet       = {};
    my $snippet_link  = {
        'person_x_corporation'     => 'PersonXCorporation',
        'corporation_x_contractor' => 'CorporationXContractor',
    };

    my $json = {
        success  => \1,
        redirect => "/corporation/list/all"
    };
    
    for my $key ( keys %{ $snippet_link }) {
        if ( $data->{ $key } ) {
            $snippet->{ $key } = decode_json( $data->{ $key } );
            delete $data->{ $key };
        }
        
        if( ref $data->{ $key } eq "ARRAY" && @{ $data->{ $key } } ) {
            $snippet->{ $key } = $data->{ $key };
        }        
    }
    
    try {
        
        $self->hm_schema->txn_do( sub {
            my $rs_data =
                $self
                    ->hm_schema
                    ->resultset('Corporation')
                    ->find({ 'me.id' => $data->{'id'} });
            
            if( $rs_data ){

                $rs_data->update( {
                    name               => $data->{'name'}        || $rs_data->name,
                    valid_till         => $data->{'valid_till'}  || $rs_data->valid_till,
                    valid_since        => $data->{'valid_since'} || $rs_data->valid_since,
                    provider           => $data->{'provider'}    || $rs_data->provider,
                } );
                
                my $rs_find =
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_corporation'} )
                        ->search({ 'me.contractor_id' => $data->{'id'} });
                
                if( $rs_find ){
                    $rs_find->delete;    
                }

                for my $item ( @{ $snippet->{'person_x_corporation'} } ){
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_corporation'} )
                        ->create({
                            person_id      => $item->{'person_id'},
                            corporation_id => $data->{'id'},
                            valid_till     => $item->{'valid_till'}  || undef,
                            valid_since    => $item->{'valid_since'} || \'NOW()',
                            admin          => $item->{'admin'},
                            billing        => $item->{'billing'},
                            tech           => $item->{'tech'}
                        });                    
                }
                
                $rs_find =
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'corporation_x_contractor'} )
                        ->search({ 'me.corporation_id' => $data->{'id'} });
                
                if( $rs_find ){
                    $rs_find->delete;    
                }

                for my $item ( @{ $snippet->{'corporation_x_contractor'} } ){
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'corporation_x_contractor'} )
                        ->create({
                            contractor_id  => $item->{'contractor_id'},
                            corporation_id => $data->{'id'},
                            valid_till     => $item->{'valid_till'}  || undef,
                            valid_since    => $item->{'valid_since'} || \'NOW()',
                        });                
                }                  
                
            }
        });

    }
    catch {
        my $err = $_;
        $json = {
            success  => \0,
            message => $err
        };          
    };     
    
    $self->render(json => $json);
}

method form_remove {
    my $data = $self->datatable_params();

    my $json = {
        success  => \1,
        redirect => "/corporation/list/all"
    };
    $self->render(json => $json);
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);  
