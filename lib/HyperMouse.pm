package HyperMouse;

use 5.20.1;
use strict;
use warnings;

use Moose 2.1604;
use namespace::autoclean;

use HyperMouse::Schema;

use MonkeyMan;
use Method::Signatures;

our $VERSION = '0.0.1';



has 'schema' => (
    is          => 'ro',
    isa         => 'HyperMouse::Schema',
    reader      =>   '_get_schema',
    writer      =>   '_set_schema',
    builder     => '_build_schema',
    lazy        => 1,
    required    => 0
);

method _build_schema {
    HyperMouse::Schema->connect(
        'dbi:mysql:hypermouse',
        'hypermouse',
        'WTXFa2G1uN3cpwMP',
        { mysql_enable_utf8 => 1 }
    );
}



has 'monkeyman' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    reader      =>   '_get_monkeyman',
    writer      =>   '_set_monkeyman',
    builder     => '_build_monkeyman',
    lazy        => 1,
    required    => 0
);

method _build_monkeyman {
    MonkeyMan->new(
        app_name        => 'HyperMouse',
        app_description => 'No description is available yet',
        app_version     => $VERSION
    );
}



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
    $self->get_monkeyman->get_logger;
}



__PACKAGE__->meta->make_immutable;

1;
