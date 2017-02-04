package MaitreDNuage;

use strict;
use warnings;

use Mojo::Base qw(Mojolicious);
use HyperMouse;
use MonkeyMan::Exception qw(InvalidParameterSet);
use Method::Signatures;



our $HYPER_MOUSE;



has _hypermouse => method() {
    $HYPER_MOUSE = defined($HYPER_MOUSE) ? $HYPER_MOUSE : HyperMouse->new;
};



method _assets_needed (
    Str             $asset_type!,
    Maybe[Str]      $asset_name?,
    Maybe[Bool]     $needed?,
) {
    $self->stash('assets_needed' => {})
        unless (defined($self->stash('assets_needed')));
    my $assets_needed = $self->stash('assets_needed');
    my $assets_library  = {
        css => {
            toastr      => [ qw# css/plugins/toastr/toastr.min.css # ],
            datepicker  => [ qw# css/plugins/datapicker/datepicker3.css # ],
            summernote  => [ qw# css/plugins/summernote/summernote.css
                                 css/plugins/summernote/summernote-bs3.css # ]
        },
        js => {
        }
    };
    if(defined($needed)) {
        unless(defined($asset_name)) {
            (__PACKAGE__ . '::Exception::InvalidParameterSet')->throw; # FIXME: Add the explaination
        }
        $assets_needed->{ $asset_type }->{ $asset_name } = $needed;
    }
    if(defined($asset_name)) {
        if(
            defined($assets_needed->{ $asset_type }->{ $asset_name }) &&
                   ($assets_needed->{ $asset_type }->{ $asset_name }) &&
            defined($assets_library->{ $asset_type }->{ $asset_name }) &&
                ref($assets_library->{ $asset_type }->{ $asset_name }) eq 'ARRAY'
        ) {
            return(@{ $assets_library->{ $asset_type }->{ $asset_name } });
        } else {
            return();
        }
    } else {
        return(keys(%{ $assets_needed->{ $asset_type} }));
    }
};

method _assets_render(Str $asset_type!) {
    my @result;
    foreach my $asset_needed ($self->assets_needed($asset_type)) {
        foreach my $asset ($self->assets_needed($asset_type, $asset_needed)) {
            push(@result, '<link href="' . $asset . '" rel="stylesheet">');
        }
    }
    return(join("\n", @result));
}


method startup {

    $self->helper(hypermouse    => sub { shift->app->_hypermouse });
    $self->helper(hm_schema     => sub { shift->app->_hypermouse->get_schema });
    $self->helper(hm_logger     => sub { shift->app->_hypermouse->get_logger });
    $self->helper(assets_needed => sub { my $self = shift; _assets_needed($self, @_) });
    $self->helper(assets_render => sub { my $self = shift; _assets_render($self, @_) });

    my $routes = $self->routes;
       $routes->any('/person/login')->to('person#login');

    my $routes_authenticated = $routes->under('/')->to('person#is_authenticated');
       $routes_authenticated->get('/')->to('dashboard#welcome');
       $routes_authenticated->get('/person/logout')->to('person#logout');

}



1;
