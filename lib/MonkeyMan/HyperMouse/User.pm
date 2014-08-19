package MonkeyMan::HyperMouse::User;

use strict;
use warnings;

use feature "switch";

use MonkeyMan::Constants;
use MonkeyMan::Utils;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'hm' => (
    is          => 'ro',
    isa         => 'MonkeyMan::HyperMouse',
    predicate   => 'has_hm',
    writer      => '_set_hm',
    required    => 'yes'
);



__PACKAGE__->meta->make_immutable;

1;

