package Mojolicious::Plugin::DateTimeDisplay;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Method::Signatures;
use DateTime;



method register (
    Object          $app!,
    HashRef         $configuration!
) {
    $app->helper(datetime_display => sub { $self->datetime_display(@_); });
}



method datetime_display (
    Object          $controller!,
    Maybe[DateTime] $datetime?,
    Str             $format?,
    Str             $language?,
    Str             $timezone?
) {
    return unless defined($datetime);
    $format   = $controller->stash->{'datetime_format'} unless defined($format);
    $format   = 'dd-MM-YYYY HH:mm:ss'                   unless defined($format);
    $language = $controller->stash->{'language'}        unless defined($language);
    $timezone = $controller->stash->{'timezone'}        unless defined($timezone);
    $datetime->set_locale($language)->set_time_zone('local')->set_time_zone($timezone)->format_cldr($format);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
