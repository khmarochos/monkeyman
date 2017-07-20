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
    rows => 50,
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
    print Dumper( $res );

    return $res;    
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;