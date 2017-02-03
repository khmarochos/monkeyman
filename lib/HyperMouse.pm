package HyperMouse;

use 5.20.1;
use strict;
use warnings;

use utf8;
binmode(STDERR, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');

use Moose 2.1604;
use namespace::autoclean;

use HyperMouse::Schema;

use MonkeyMan;
use Method::Signatures;

our $VERSION = '0.0.1';



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
    reader      =>    'get_logger',
    writer      =>   '_set_logger',
    builder     => '_build_logger',
    lazy        => 1,
    required    => 0
);

method _build_logger {
    $self->_get_monkeyman->get_logger;
}



has 'schema' => (
    is          => 'ro',
    isa         => 'HyperMouse::Schema',
    reader      =>    'get_schema',
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



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   =>    'has_configuration',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {
    {
        password_encryption_key => 'My Amazingly Cool Encryption Key'
    };
}



__PACKAGE__->meta->make_immutable;

1;
