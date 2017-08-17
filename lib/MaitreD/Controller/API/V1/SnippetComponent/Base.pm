package MaitreD::Controller::API::V1::SnippetComponent::Base;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use Method::Signatures;
use Data::Dumper;

method user_info {
    my $json = { 'success' => \1 };
    
    my $rs = $self->stash->{'authorized_person_result'};
    
    #print Dumper( ref $rs );
    $json->{'data'} = {
        first_name  => $rs->first_name,
        last_name   => $rs->last_name,
        valid_from  => $rs->valid_from,
        valid_till  => $rs->valid_till,
        removed     => $rs->removed,
        id          => $rs->id,
    };
                    
    $self->render(json => $json);    
};

method language {
    my $json = { 'success' => \1 };
    $json->{'data'} = [
        $self
            ->hm_schema
            ->resultset('Language')
            ->search(undef,{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            })->all        
    ];
    
    @{ $json->{'data'} } =
    map {
        $_->{'value'} = $_->{'name'};
        $_;
    } @{ $json->{'data'} };
    
    $self->render(json => $json);        
}

method corporation_x_contractor {
    my $json = { 'success' => \1 };

    $json->{'data'} = [
        $self
            ->hm_schema
            ->resultset('CorporationXContractor')
            ->search({
                'me.corporation_id' => $self->stash->{'id'}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            })->all        
    ];
        
    $self->render(json => $json);    
}

method phone {
    my $json = { 'success' => \1 };
    
    $json->{'data'} = [
        $self
            ->hm_schema
            ->resultset('PersonPhone')
            ->search({
                'me.person_id' => $self->stash->{'id'}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            })->all        
    ];
        
    $self->render(json => $json);
}

method email {
    my $json = { 'success' => \1 };

    $json->{'data'} = [
        $self
            ->hm_schema
            ->resultset('PersonEmail')
            ->search({
                'me.person_id' => $self->stash->{'id'}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            })->all        
    ];
        
    
    $self->render(json => $json);
}

method person_x_contractor {
    my $json = { 'success' => \1 };

    $json->{'data'} = [
        $self
            ->hm_schema
            ->resultset('PersonXContractor')
            ->search({
                'me.contractor_id' => $self->stash->{'id'}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            })->all
    ];
    
    $self->render(json => $json);
}

method person_x_corporation {
    my $json = {};
    
    $json->{'person_x_corporation'} = [
        $self
            ->hm_schema
            ->resultset('PersonXCorporation')
            ->search({
                'me.corporation_id' => $self->stash->{'id'}
            },{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
            })->all
    ];
    
    $self->render(json => $json);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
