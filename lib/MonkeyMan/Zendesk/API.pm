package MonkeyMan::Zendesk::API;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Zendesk::Essentials';
with 'MonkeyMan::Roles::WithTimer';



1;
