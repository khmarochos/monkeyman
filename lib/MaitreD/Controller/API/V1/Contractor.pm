package MaitreD::Controller::API::V1::Contractor;

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
    
    switch($self->stash->{'related_element'}) {
        case('person') {
            my $person_id =
                ($self->stash->{'related_id'} ne '@')
                    ? $self->stash->{'related_id'}
                    : $self->stash->{'authorized_person_result'}->id
                    ;
            
            $tmpl_rs = 
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ 'me.id' => $person_id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ '@Person->-((@->-@Corporation->-@Contractor)-&-(@->-@Contractor))' => { } ]
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
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningAgreement-[client|provider]>-Contractor' => { } ]
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
                        resultset_class            => 'Contractor',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ 'ProvisioningObligation->-Contractor' => { } ]
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
        
    my $columns = $settings->{'contractor'}->{'table'}->{'columns'};
                
    @{$json->{'data'}} = map {
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
        $hash->{"value"} = $_->name;
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
            ->resultset('Contractor')
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
        'person_x_contractor' => 'PersonXContractor',
    };

    my $json = {
        success  => \1,
        redirect => "/contractor/list/all"
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
                    ->resultset('Contractor')
                    ->create( {
                        name               => $data->{'name'},
                        valid_till         => $data->{'valid_till'}  || undef,
                        valid_since        => $data->{'valid_since'} || \'NOW()',
                        contractor_type_id => $data->{'contractor_type_id'},
                        provider           => $data->{'provider'},
                    } );

            for my $item ( @{ $snippet->{'person_x_contractor'} } ){
                $self
                    ->hm_schema
                    ->resultset( $snippet_link->{'person_x_contractor'} )
                    ->create({
                        person_id      => $item->{'person_id'},
                        contractor_id  => $rs_data->id,
                        valid_till     => $item->{'valid_till'}  || undef,
                        valid_since    => $item->{'valid_since'} || \'NOW()',
                        admin          => $item->{'admin'},
                        billing        => $item->{'billing'},
                        tech           => $item->{'tech'}
                    });
                
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

method form_update {
    my $data          = $self->datatable_params()->{'origin_data'};
    my $snippet       = {};
    my $snippet_link  = {
        'person_x_contractor' => 'PersonXContractor',
    };

    my $json = {
        success  => \1,
        redirect => "/contractor/list/all"
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
                    ->resultset('Contractor')
                    ->find({ 'me.id' => $data->{'id'} });
            
            if( $rs_data ){

                $rs_data->update( {
                    name               => $data->{'name'}        || $rs_data->name,
                    valid_till         => $data->{'valid_till'}  || $rs_data->valid_till,
                    valid_since        => $data->{'valid_since'} || $rs_data->valid_since,
                    contractor_type_id => $data->{'contractor_type_id'} || $rs_data->contractor_type_id,
                    provider           => $data->{'provider'}    || $rs_data->provider,
                } );
                
                my $rs_find =
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_contractor'} )
                        ->search({ 'me.contractor_id' => $data->{'id'} });
                
                if( $rs_find ){
                    $rs_find->delete;    
                }

                for my $item ( @{ $snippet->{'person_x_contractor'} } ){
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_contractor'} )
                        ->create({
                            person_id      => $item->{'person_id'},
                            contractor_id  => $data->{'id'},
                            valid_till     => $item->{'valid_till'}  || undef,
                            valid_since    => $item->{'valid_since'} || \'NOW()',
                            admin          => $item->{'admin'},
                            billing        => $item->{'billing'},
                            tech           => $item->{'tech'}
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
    my $data = $self->datatable_params()->{'origin_data'};
    my $id   = $self->{stash}->{'id'};

    my $json = {
        success  => \1,
        redirect => "/contractor/list/all"
    };
    
    try {
        my $rs_find =
            $self
                ->hm_schema
                ->resultset('Contractor')
                ->find({ 'me.id' => $id });        
        
        if( $rs_find ){
            $rs_find->update( {
                removed => \'NOW()',
            } );
        }
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

__PACKAGE__->meta->make_immutable(inline_constructor => 0);    
