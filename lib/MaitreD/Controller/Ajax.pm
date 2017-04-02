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
        $self->render(
            json    => { language_code => $language_code },
            status  => 200
        );
    } else {
        $self->render(
            json    => { error => 'Zaloopa' },
            status  => 500
        );
    }
}



method list_timezones {
    my $m_area      = $self->stash('area');
    my $m_city      = $self->stash('city');
    my $timezones   = {};
    foreach     my $area (match_glob($m_area,    @DateTime::TimeZone::Catalog::CATEGORY_NAMES)) {
        foreach my $city (match_glob($m_city, @{ $DateTime::TimeZone::Catalog::CATEGORIES{ $area } })) {
            $timezones->{ $area }->{ $city } = 1;
        }
    }
    $self->render(json => { timezones => $timezones });
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
