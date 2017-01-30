package HyperMouse::Roles::Element;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

use MonkeyMan::Logger;
use Method::Signatures;
use Scalar::Util;



has 'hypermouse' => (
    is          => 'ro',
    isa         => 'HyperMouse',
    reader      => '_get_hypermouse',
    writer      => '_set_hypermouse',
    lazy        => 0,
    required    => 1
);



has 'db_schema' => (
    is          => 'ro',
    isa         => 'HyperMouse::Schema',
    reader      =>   '_get_db_schema',
    writer      =>   '_set_db_schema',
    builder     => '_build_db_schema',
    lazy        => 1,
    required    => 0
);

method _build_db_schema {
    $self->_get_hypermouse->_get_db_schema;
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
    $self->_get_hypermouse->_get_logger;
}



method valid_only {
    {
        -and => [
            { removed       => { '='    => undef } },
            { valid_since   => { '<='   => \'NOW()' } },
            {
                -or => [
                    { valid_till    => { '=' => undef } },
                    { valid_till    => { '>' => \'NOW()' } }
                ]
            }
        ]
    }
}



has 'type' => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_type',
    writer      =>   '_set_type',
    builder     => '_build_type',
    lazy        => 1,
    required    => 0
);

method _build_type {
    if((my $type = blessed($self)) =~ s/^HyperMouse::Element::(.+)$/$1/) { $type; };
}



has 'db_result_set' => (
    is          => 'ro',
    isa         => 'DBIx::Class::ResultSet',
    reader      =>   '_get_db_result_set',
    writer      =>   '_set_db_result_set',
    builder     => '_build_db_result_set',
    lazy        => 1,
    required    => 0
);

method _build_db_result_set {
    $self->_get_db_schema->resultset($self->get_type);
}


has 'db_result' => (
    is          => 'ro',
    isa         => 'Object',            # FIXME!
    reader      =>   '_get_db_result',
    writer      =>   '_set_db_result',
    builder     => '_build_db_result',
    lazy        => 1,
    required    => 0
);

method _build_db_result {
    $self->_get_db_result_set->search({ id => $self->get_db_id, $self->valid_only })->single;
}


has 'db_id' => (
    is          => 'ro',
    isa         => 'Maybe[Int]',
    reader      =>    'get_db_id',
    writer      =>   '_set_db_id',
    predicate   =>   '_has_db_id',
    builder     => '_build_db_id',
    lazy        => 1,
    required    => 0
);

method _build_db_id {
    undef;
}



method BUILD (...) {
    $self->_get_db_result if($self->_has_db_id);
    $self;
}


1;
