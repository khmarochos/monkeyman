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
    return({});
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

    my $hm_schema = HyperMouse::Schema->connect(
        sprintf(
            'dbi:%s:%s',
            $self->get_configuration->{'database'}->{'type'},
            $self->get_configuration->{'database'}->{'database'}
        ),
        $self->get_configuration->{'database'}->{'username'},
        $self->get_configuration->{'database'}->{'password'},
        { mysql_enable_utf8 => 1 }
    );

    # We need to store the reference to the HyperMouse object inside of the
    # HyperMouse::Schema object, as we'll need to use it later
    $hm_schema->set_hypermouse($self);

    return($hm_schema);
}



has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      =>    'get_logger',
    writer      =>   '_set_logger',
    predicate   =>   '_has_logger',
    builder     => '_build_logger',
    lazy        => 1
);

method _build_logger {
    return(MonkeyMan::Logger->instance);
}




__PACKAGE__->meta->make_immutable;

1;
