package MaitreDNuage;

use strict;
use warnings;

use Mojo::Base qw(Mojolicious);
use Mojolicious::Plugin::AssetManager;
use HyperMouse;
use MonkeyMan::Exception qw(InvalidParameterSet);
use Method::Signatures;



our $HYPER_MOUSE;



has _hypermouse => method() {
    $HYPER_MOUSE = defined($HYPER_MOUSE) ? $HYPER_MOUSE : HyperMouse->new;
};



method startup {

    $self->plugin('AssetManager', {
        assets_library => {
            js  => {
                datatables  => [ qw# js/plugins/dataTables/datatables.min.js # ]
            },
            css => {
                toastr      => [ qw# css/plugins/toastr/toastr.min.css # ],
                datatables  => [ qw# css/plugins/dataTables/datatables.min.css # ],
                datepicker  => [ qw# css/plugins/datapicker/datepicker3.css # ],
                summernote  => [ qw# css/plugins/summernote/summernote.css
                                     css/plugins/summernote/summernote-bs3.css # ]
            }
        }
    });

    $self->helper(hypermouse    => sub { shift->app->_hypermouse });
    $self->helper(hm_schema     => sub { shift->app->_hypermouse->get_schema });
    $self->helper(hm_logger     => sub { shift->app->_hypermouse->get_logger });

    my $routes = $self->routes;
       $routes->any('/person/login')->to('person#login');

    my $routes_authenticated = $routes->under->to('person#is_authenticated')->under->to('navigation#build_menu');
       $routes_authenticated->get('/')->to('dashboard#welcome');
       $routes_authenticated->get('/service_agreement/list')->to('service_agreement#list');
       $routes_authenticated->get('/person/logout')->to('person#logout');

}



1;
