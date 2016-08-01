#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../lib");

use MonkeyMan;
use Mojolicious::Lite;

plugin 'basic_auth';

get '/welcome' => sub {

    my $self = shift;

    $self->render('welcome');
};

put '/api' => sub {

    my $self = shift;

    $self->redirect_to('/welcome')
        unless($self->basic_auth(realm => 'zendesk' => '********'));
};

app->start;

__DATA__
@@ welcome.html.ep
<!DOCTYPE html>
<html>
  <head><title>Welcome to MonkeyMan API</title></head>
  <body>Hello, world!</body>
</html>
