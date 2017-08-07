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
use MaitreD::Extra::API::V1::TemplateSettings;
use JSON::XS;
use Try::Tiny;


method list {

    my $settings         = $MaitreD::Extra::API::V1::TemplateSettings::settings;
    my $mask_permitted_f = 0b000111;
    my $mask_permitted_d = 0b000111; 
    my $mask_validated_f = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $mask_validated_d = VC_NOT_REMOVED & VC_NOT_PREMATURE & VC_NOT_EXPIRED;
    my $datatable_params = $self->datatable_params;    
    my $json             = {};
    my $tmpl_rs;
    
    #print Dumper( $datatable_params );
    
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
            
            $tmpl_rs =
                $self
                    ->hm_schema
                    ->resultset('Person')
                    ->search({ 'me.id' => $self->stash->{'authorized_person_result'}->id })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ '@Person [everything]> @Person' => { } ]
                    );
            
        }
        case('contractor') {
            
            $self->stash->{'title'} = "Contractor -> " . $self->stash->{'filter'};
            
            $tmpl_rs =
                $self
                    ->hm_schema
                    ->resultset('Contractor')
                    ->search({ 'me.id' => $self->stash->{'related_id'} })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_f,
                        fetch_validations_default  => $mask_validated_f,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ '@Contractor > @Person' => { } ]
                    );
            
        }
        case('provisioning_agreement') {
            
            $self->stash->{'title'} = "ProvisioningAgreement -> " . $self->stash->{'filter'};
            
            $tmpl_rs =
                $self
                    ->hm_schema
                    ->resultset('ProvisioningAgreement')
                    ->search({ 'me.id' => $self->stash->{'related_id'} })
                    ->filter_validated(mask => VC_NOT_REMOVED)
                    ->search_related_deep(
                        resultset_class            => 'Person',
                        fetch_permissions_default  => $mask_permitted_d,
                        fetch_validations_default  => $mask_validated_d,
                        search_permissions_default => $mask_permitted_d,
                        search_validations_default => $mask_validated_d,
                        callout => [ '@ProvisioningAgreement > @Person' => { } ]
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
    
    my $columns = $settings->{'person'}->{'table'}->{'columns'};
    @{ $json->{'data'} } = map({
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
        $hash->{"value"} = $_->first_name . " " . $_->last_name;
        $hash;
    } @{ $json->{'data'} });
    
    $json->{'pos'}         = $datatable_params->{'start'};
    $json->{'total_count'} = $tmpl_rs->count;
            
    $self->render(json => $json);

}

method form_load {
    my $data = $self->datatable_params();

    my $json = { success => 1 };

    $json->{'data'} =
        $self
            ->hm_schema
            ->resultset('Person')
            ->find({
                'me.id' => $self->stash->{id}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            });
                    
    $self->render(json => $json);
}

method form_add {
    my $data          = $self->datatable_params()->{'origin_data'};
    my $snippet       = {};
    my $snippet_link  = {
        'person_x_email' => 'PersonEmail',
        'person_x_phone' => 'PersonPhone',
    };

    my $json = {
        success  => \1,
        redirect => "/person/list/all"
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
    
    if( ref $snippet->{'person_x_email'} eq "ARRAY"  ){
        my $find = $self
                ->hm_schema
                ->resultset( $snippet_link->{'person_x_email'} )
                ->search({
                    email => {
                        -in => [ map {$_->{'email'}} @{$snippet->{'person_x_email'}} ]
                    }
                })->all;
        
        if( $find > 0 ){
            $json = {
                success  => \0,
                message  => "email exists"
            };              
        }
        else{
            
            try {
                
                $data->{'language_id'}        = 1;
                $data->{'datetime_format_id'} = 1;
                $data->{'timezone'}           = 'Europe/Kiev';
                                
                $self->hm_schema->txn_do( sub {
                    my $rs_data =
                        $self
                            ->hm_schema
                            ->resultset('Person')
                            ->create( {
                                first_name         => $data->{'first_name'},
                                last_name          => $data->{'last_name'},
                                valid_till         => $data->{'valid_till'}  || undef,
                                valid_since        => $data->{'valid_since'} || \'NOW()',
                                language_id        => $data->{'language_id'},
                                datetime_format_id => $data->{'datetime_format_id'},
                                timezone           => $data->{'timezone'},
                            } );
                    
                    for my $item ( @{ $snippet->{'person_x_email'} } ){
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_email'} )
                            ->create({
                                person_id   => $rs_data->id,
                                email       => $item->{'email'},
                                valid_till  => $item->{'valid_till'}  || undef,
                                valid_since => $item->{'valid_since'} || \'NOW()',
                            });
                        
                    }

                    for my $item ( @{ $snippet->{'person_x_phone'} } ){
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_phone'} )
                            ->create({
                                person_id   => $rs_data->id,
                                phone       => $item->{'phone'},
                                valid_till  => $item->{'valid_till'}  || undef,
                                valid_since => $item->{'valid_since'} || \'NOW()',
                            });
                        
                    }
                    
                    $self
                        ->hm_schema
                        ->resultset('PersonPassword')
                        ->create({
                            valid_since => \'NOW()',
                            valid_till  => undef,
                            removed     => undef,
                            password    => $data->{'password'},
                            person_id   => $rs_data->id
                        });                    

                });
                
            }
            catch {
                my $err = $_;
                $json = {
                    success  => \0,
                    message => $err
                };                
            };            
            
        }
    }
    else{
        $json = {
            success  => \0,
            message  => "not param email"
        };        
    }
        
    $self->render(json => $json);
}

method form_update {
    my $data = $self->datatable_params()->{'origin_data'};
    my $snippet       = {};
    my $snippet_link  = {
        'person_x_email' => 'PersonEmail',
        'person_x_phone' => 'PersonPhone',
    };    

    my $json = {
        success  => \1,
        redirect => "/person/list/all"
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
    
    if( $data->{'id'} ){
        
        try {
            $data->{'language_id'}        = 1;
            $data->{'datetime_format_id'} = 1;
            $data->{'timezone'}           = 'Europe/Kiev';        

            $self->hm_schema->txn_do( sub {
                #
                # Person
                #
                my $rs_find =
                    $self
                        ->hm_schema
                        ->resultset('Person')
                        ->find( { 'me.id' => $data->{'id'} } );
                
                if( $rs_find ){
                    $rs_find->update( {
                        first_name         => $data->{'first_name'}  || $rs_find->first_name,
                        last_name          => $data->{'last_name'}   || $rs_find->last_name,
                        valid_till         => $data->{'valid_till'}  || $rs_find->valid_till,
                        valid_since        => $data->{'valid_since'} || $rs_find->valid_since,
                        language_id        => $data->{'language_id'},
                        datetime_format_id => $data->{'datetime_format_id'},
                        timezone           => $data->{'timezone'},
                    } );
                }
                #
                # Password
                #
                $rs_find = 
                    $self
                        ->hm_schema
                        ->resultset('PersonPassword')
                        ->find({'me.person_id' => $data->{'id'} });

                if( $rs_find && $data->{'password'} ){
                    $rs_find->update({
                        valid_since => $data->{'valid_since'} || $rs_find->valid_since,,
                        valid_till  => $data->{'valid_till'}  || $rs_find->valid_till,
                        removed     => undef,
                        password    => $data->{'password'},
                        person_id   => $data->{'id'}
                    });
                }
                elsif( !$rs_find && $data->{'password'} ){
                    $self
                        ->hm_schema
                        ->resultset('PersonPassword')
                        ->create({
                            valid_since => \'NOW()',
                            valid_till  => undef,
                            removed     => undef,
                            password    => $data->{'password'},
                            person_id   => $data->{'id'}
                        });                    
                }
                #
                # Phone
                #
                $rs_find = 
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_phone'} )
                        ->search({'me.person_id' => $data->{'id'} });
                
                if( $rs_find ){
                    $rs_find->delete();
                    
                    for my $item ( @{ $snippet->{'person_x_phone'} } ){
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_phone'} )
                            ->create({
                                person_id   => $data->{'id'},
                                phone       => $item->{'phone'},
                                valid_till  => $item->{'valid_till'}  || undef,
                                valid_since => $item->{'valid_since'} || \'NOW()',
                            });
                        
                    }
                }
                #
                # Email
                #
                $rs_find = 
                    $self
                        ->hm_schema
                        ->resultset( $snippet_link->{'person_x_email'} )
                        ->search({'me.person_id' => $data->{'id'} });
                
                if( $rs_find ){
                    $rs_find->delete();
                    
                    for my $item ( @{ $snippet->{'person_x_email'} } ){
                        $self
                            ->hm_schema
                            ->resultset( $snippet_link->{'person_x_email'} )
                            ->create({
                                person_id   => $data->{'id'},
                                email       => $item->{'email'},
                                valid_till  => $item->{'valid_till'}  || undef,
                                valid_since => $item->{'valid_since'} || \'NOW()',
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
        
    }
    else{
        $json = {
            success => \0,
            message => 'Server error'
        };
    }
    
    $self->render(json => $json);
}

method form_remove {
    my $data = $self->datatable_params();

    my $json = {
        success  => \1,
        redirect => "/person/list/all"
    };
    $self->render(json => $json);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
