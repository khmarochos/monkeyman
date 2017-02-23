package MaitreD::Controller::Ajax;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Mojolicious::Controller';

use Method::Signatures;



method i18n {
    if(defined(my $language_code = $self->param('language_code'))) {
        $self->session->{'language_code'} = $language_code;
        $self->render(json => { 'language_code' => $language_code }, status => 200);
    } else {
        $self->render(json => { 'error' => 'Zaloopa' }, status => 500);
    }
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
