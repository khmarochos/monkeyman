package MaitreD::Controller::Ajax;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Mojolicious::Controller';

use Method::Signatures;
use Text::Glob qw(match_glob);
use DateTime::TimeZone::Catalog;



method i18n {
    if(defined(my $language_code = $self->param('language_code'))) {
        $self->session->{'language_code'} = $language_code;
        $self->render(json => { 'language_code' => $language_code }, status => 200);
    } else {
        $self->render(json => { 'error' => 'Zaloopa' }, status => 500);
    }
}



method list_timezones {
    my $m_category  = $self->stash('category');
    my $m_zone      = $self->stash('zone');
    my $timezones   = {};
    foreach my $category (match_glob($m_category,    @DateTime::TimeZone::Catalog::CATEGORY_NAMES)) {
        foreach my $zone (match_glob($m_zone,     @{ $DateTime::TimeZone::Catalog::CATEGORIES{ $category } })) {
            $timezones->{ $category }->{ $zone } = 1;
        }
    }
    $self->render(json => { timezones => $timezones });
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
