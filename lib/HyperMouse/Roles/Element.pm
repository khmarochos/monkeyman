package HyperMouse::Roles::Element;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

with 'MonkeyMan::Roles::WithTimer';

use MonkeyMan::Logger;

use Method::Signatures;



has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      =>   '_get_logger',
    writer      =>   '_set_logger',
    builder     => '_build_logger',
    lazy        => 1,
    required    => 0
);

method _build_logger {
    MonkeyMan::Logger->instance;
}



has 'schema' => (
    is          => 'ro',
    isa         => 'HyperMouse::Schema',
    reader      => '_get_schema',
    writer      => '_set_schema',
    lazy        => 0,
    required    => 1
);

