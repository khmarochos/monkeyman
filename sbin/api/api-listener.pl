#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan;
use Mojolicious::Lite;

plugin 'basic_auth';

any '/api' => sub {

    my $c = shift;
    my $l = Mojo::Log->new;

    unless($c->basic_auth(realm => 'zendesk' => '********')) {
        $c->res->headers->www_authenticate('Basic');
        $c->render(text => 'Authentication required', status => 401);
        return;
    }

    $l->debug($c->dumper($c->req->json));

    $c->render('api-response');

};

app->start;

__DATA__
@@ welcome.html.ep
<!DOCTYPE html>
<html>
  <head><title>Welcome to MonkeyMan API</title></head>
  <body>Hello, world!</body>
</html>

@@ api-response.html.ep
OK, thank you!
