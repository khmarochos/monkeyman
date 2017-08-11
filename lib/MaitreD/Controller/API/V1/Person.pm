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
#use Try::Tiny;


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
    
    if( $json->{'data'}->{'timezone'} ) {
        (
            $json->{'data'}->{'timezone.area'},
            $json->{'data'}->{'timezone.city'}
        )
        = split /\//,  $json->{'data'}->{'timezone'};
    }
                    
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
    
    if( $data->{'timezone.area'} && $data->{'timezone.city'} ){
        $data->{'timezone'}
            = $data->{'timezone.area'}
            . "/"
            . $data->{'timezone.city'}
            ;
    }    
    
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
                
                $data->{'language_id'}        ||= 1;
                $data->{'datetime_format_id'} = 1;
                $data->{'timezone'}           ||= 'Europe/Kiev';
                                
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
            catch ($e) {
                $json = {
                    success => \0,
                    message => $e
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
    
    if( $data->{'timezone.area'} && $data->{'timezone.city'} ){
        $data->{'timezone'}
            = $data->{'timezone.area'}
            . "/"
            . $data->{'timezone.city'}
            ;
    }
    
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
        
        #print Dumper( $data );
        if( ref $snippet->{'person_x_email'} eq "ARRAY"  ){
        
            try {
                $data->{'language_id'}        ||= 1;
                $data->{'datetime_format_id'} = 1;
    
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
                            valid_till         => $data->{'valid_till'}  || undef,
                            valid_since        => $data->{'valid_since'} || undef,
                            language_id        => $data->{'language_id'},
                            datetime_format_id => $data->{'datetime_format_id'},
                            timezone           => $data->{'timezone'},
                        });
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
                            valid_since => $data->{'valid_since'} || undef,
                            valid_till  => $data->{'valid_till'}  || undef,
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
                    if(
                       ref $snippet->{'person_x_phone'} eq "ARRAY"
                       && @{ $snippet->{'person_x_phone'} }
                    ){ 
                        # Удаляем старые номера
                        $rs_find = 
                            $self
                                ->hm_schema
                                ->resultset( $snippet_link->{'person_x_phone'} )
                                ->search({
                                    id  => {
                                         -not_in => [
                                            map{ $_->{'id'} } @{ $snippet->{'person_x_phone'} }
                                        ]
                                    }
                                });
                                                
                        if( $rs_find ){
                            $rs_find->delete();
                        }
                        
                        # Обновляем старые
                        for my $item ( @{ $snippet->{'person_x_phone'} } ){
                            $rs_find = 
                                $self
                                    ->hm_schema
                                    ->resultset( $snippet_link->{'person_x_phone'} )
                                    ->find({
                                        'me.id' => $item->{'id'}
                                    });

                            if( $rs_find ){
                                $rs_find->update({
                                    valid_since => $item->{'valid_since'} || undef,
                                    valid_till  => $item->{'valid_till'}  || undef,
                                    phone       => $item->{'phone'},
                                });
                            }                            
                        }
                        
                    }
                    else {
                        # если список пустой удалем все телефоны
                        $rs_find = 
                            $self
                                ->hm_schema
                                ->resultset( $snippet_link->{'person_x_phone'} )
                                ->search({
                                    'me.person_id' => $data->{'id'},
                                });
                        if( $rs_find ){
                            $rs_find->delete();
                        }
                    }
                    
                    #                    
                    # Email
                    #
                    if(
                       ref $snippet->{'person_x_email'} eq "ARRAY"
                       && @{ $snippet->{'person_x_email'} }
                    ){
                        # удаляем записи которых нет в $snippet->{'person_x_email'}
                        $rs_find = 
                            $self
                                ->hm_schema
                                ->resultset( $snippet_link->{'person_x_email'} )
                                ->search({
                                    'me.id'        => {
                                        -not_in  => [
                                            map { $_->{'id'} } @{ $snippet->{'person_x_email'} }
                                        ]
                                    }
                                });
                        
                        if( $rs_find ){
                            $rs_find->delete();
                        }
                        
                        # Обновляем старые
                        for my $item ( @{ $snippet->{'person_x_email'} } ){
                            $rs_find = 
                                $self
                                    ->hm_schema
                                    ->resultset( $snippet_link->{'person_x_email'} )
                                    ->find({
                                        'me.id'=> $item->{'id'}
                                    });

                            if( $rs_find ){
                                $rs_find->update({
                                    valid_since => $item->{'valid_since'} || undef,
                                    valid_till  => $item->{'valid_till'}  || undef,
                                    email       => $item->{'email'},
                                });
                            }                            
                        }
                    }
                    else {
                        $json = {
                            success => \0,
                            message => 'not param email'
                        };                        
                    }
                                        
                });
                
            }
            catch ($e) {
                $json = {
                    success => \0,
                    message => $e
                };                
            };
            
        }
        else {
            $json = {
                success  => \0,
                message  => "not param email"
            };        
        } # ref $snippet->{'person_x_email'} eq "ARRAY
        
    }
    else {
        $json = {
            success => \0,
            message => 'Server error'
        };
    } # $data->{'id'}
    
    $self->render(json => $json);
}

method form_remove {
    my $data = $self->datatable_params()->{'origin_data'};
    my $id   = $self->{stash}->{'id'};
    
    my $json = {
        success  => \1,
        redirect => "/person/list/all"
    };

    try {
        my $rs_find =
            $self
                ->hm_schema
                ->resultset('Person')
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
