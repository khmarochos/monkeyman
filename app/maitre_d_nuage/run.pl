#!/usr/bin/env perl

use strict;
use warnings;

use MonkeyMan::Constants qw(:directories);
use Mojolicious::Commands;

Mojolicious::Commands->start_app('MaitreDNuage');
