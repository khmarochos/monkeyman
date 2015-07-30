#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);

use lib "$Bin/lib";

use Mojolicious::Commands;



Mojolicious::Commands->start_app('WebMug');
