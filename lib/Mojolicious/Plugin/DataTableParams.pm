package Mojolicious::Plugin::DataTableParams;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Method::Signatures;
use Hash::Merge ();
use JSON::XS;

use Data::Dumper;

my $merger = Hash::Merge->new( 'RIGHT_PRECEDENT' );
our $list  = {
    page => 0,
    rows => 50,
};

method register (
    Object          $app!,
    HashRef         $configuration!
) {
    $app->helper(datatable_params => sub { $self->datatable_params(@_); });
    $app->helper(snippet => sub { $self->snippet(@_); });
}

method datatable_params (
    Object          $controller!,
) {    
    
    my ($res, $table_params, $order) = ({},[],[]);
    # Параметры
    my $json_params =
        $controller->req->json
            || {};

    my $data_params =
        $controller->req->params
            ? $controller->req->params->to_hash
            : {}
            ;

    my $data     =
        $merger->merge( $json_params, $data_params );

    $controller->{'args'} = $data;
    $data->{'start'}  ||= $list->{'page'};
    $res->{'start'}   = $data->{'start'} == 1 ? $data->{'start'} - 1 : $data->{'start'};
    $data->{'count'}  ||= $list->{'rows'};
    
    $res->{'page'}    = ($data->{'start'} / $data->{'count'}) + 1;
    $res->{'rows'}    = $data->{'count'};
    
    # парсим данные таблицы  
    for my $key ( keys %{$data} ){
        if( $key =~ /sort\[(\w+)\]/i ){
            $res->{'order'} = { "-" . $data->{ $key } => $1 };
        }
    }
    
    $res->{'table'}        = $table_params;
    $res->{'origin_data'}  = $data;

    return $res;    
}

method snippet (
    Object  $controller!,
    HashRef $snippet_link!,
    HashRef $data!,
){
    my $snippet = {};
    my $res     = {};
    for my $snippet_link_key ( keys %{ $snippet_link }) {
        my $cols =
            join( "|", @{$snippet_link->{ $snippet_link_key }->{'col_not_empty'}} );
        
        if ( $data->{ $snippet_link_key } ) {
            
            my $snippet->{ $snippet_link_key } = decode_json( $data->{ $snippet_link_key } );
            
            delete $data->{ $snippet_link_key };
        
            if( ref $snippet->{ $snippet_link_key } eq "ARRAY" ){
                
                for my $i ( 0 .. $#{ $snippet->{ $snippet_link_key } }  ){
                    
                    my $row  = $snippet->{ $snippet_link_key }->[$i];
                    # col_not_empty
                    if( ref $row eq "HASH" ){
                        ROW: for my $row_key ( keys %{ $row } ){
                            if( $row_key =~/$cols/ && !$row->{$row_key} ){
                                $row = {};
                                last ROW;
                            }
                        }                        
                    }
                    else{
                        $row = {};
                    }
                    
                    if( %{ $row } ) {
                        push @{ $res->{ $snippet_link_key } }, $row;
                    }
                    
                } # for
            }
            else{
                $res->{ $snippet_link_key } = ();
            }
        }        
    }
    
    return $res, $data;
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;