package Mojolicious::Plugin::DataTableParams;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Method::Signatures;
use Hash::Merge ();
use Data::Dumper;

my $merger = Hash::Merge->new( 'RIGHT_PRECEDENT' );
our $list  = {
    page => 0,
    rows => 25,
};

method register (
    Object          $app!,
    HashRef         $configuration!
) {
    $app->helper(datatable_params => sub { $self->datatable_params(@_); });    
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
    $data->{'length'} ||= $list->{'rows'};
    
    $res->{'page'}    = ($data->{'start'} / $data->{'length'}) + 1;
    $res->{'rows'}    = $data->{'length'};
    
    # парсим данные таблицы
    for my $key ( keys %{$data} ){
        $key =~ /(\w+)\[(\d+)\]\[(\w+)\]\[*(\w*)\]*/o;
        
        if( defined $1 && $1 eq 'columns' ){
            if ( defined $2 && $3 && !$4 ){
                $table_params->[$2]->{$1}->{$3} = $data->{$key};
            }
            elsif ( defined $2 && $3 && $4 ) {
                $table_params->[$2]->{$1}->{$3}->{$4} = $data->{$key};
            }
        }
        elsif( defined $1 && $1 eq 'order' ){
            if ( defined $2 && $3 && $data->{$key} ){
                $order->[$2]->{$3} = $data->{$key};
            }
        }        
    }
    
    # order by
    map {
        $table_params->[ $_->{'column'} ]->{'order'} = $_->{'dir'};
        
        $_->{'dir'} ||= 'asc';
        
        push @{ $res->{'order'}->{ "-" . $_->{'dir'} } },
            $table_params->[ $_->{'column'} ]->{'columns'}->{'data'}
                if $table_params->[ $_->{'column'} ]->{'columns'}->{'data'};
    }
    @{$order};
    
    $res->{'table'}        = $table_params;
    $res->{'origin_data'}  = $data;
    #print Dumper( $res );

    return $res;    
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;