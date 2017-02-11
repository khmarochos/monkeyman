package Mojolicious::Plugin::DateTimeDisplay;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Method::Signatures;
use DateTime;
use Switch;



method register (
    Object          $app!,
    HashRef         $configuration!
) {
    $app->helper(datetime_display => sub { $self->datetime_display(@_); });
}



method datetime_display (
    Object          $controller!,
    Maybe[DateTime] $datetime?,
    Maybe[Int]      $mask?,
    Maybe[Str]      $format?,
    Maybe[Str]      $language?,
    Maybe[Str]      $timezone?
) {
    return unless defined($datetime);
    if(defined($mask)) {
        my @what_to_display;
        if($mask & 0b10) { push(@what_to_display, $controller->stash->{'datetime_format_date'}); }
        if($mask & 0b01) { push(@what_to_display, $controller->stash->{'datetime_format_time'}); }
        $format = join(' ', @what_to_display);
    }
    $format   = 'dd-MM-YYYY HH:mm:ss'                   unless defined($format);
    $language = $controller->stash->{'language'}        unless defined($language);
    $timezone = $controller->stash->{'timezone'}        unless defined($timezone);
    $datetime->set_locale($language)->set_time_zone('local')->set_time_zone($timezone)->format_cldr($format);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
