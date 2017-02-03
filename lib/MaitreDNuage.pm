package MaitreDNuage;

use strict;
use warnings;

use Mojo::Base qw(Mojolicious);

use HyperMouse;
use Method::Signatures;



our $HYPER_MOUSE;



has hypermouse => sub {
    $HYPER_MOUSE = defined($HYPER_MOUSE) ? $HYPER_MOUSE : HyperMouse->new unless(defined($HYPER_MOUSE));
};



method startup {

    $self->helper(hypermouse    => sub { $self->app->hypermouse });
    $self->helper(hm_schema     => sub { $self->app->hypermouse->get_schema });
    $self->helper(hm_logger     => sub { $self->app->hypermouse->get_logger });

    my $routes = $self->routes;
       $routes->any('/person/login')->to('person#login');

    my $routes_authenticated = $routes->under('/')->to('person#is_authenticated');
       $routes_authenticated->get('/')->to('dashboard#welcome');
       $routes_authenticated->get('/person/logout')->to('person#logout');

}



1;
