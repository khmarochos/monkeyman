package MonkeyMan::CloudStack;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

use MonkeyMan::CloudStack::API;
use MonkeyMan::Logger;

use Method::Signatures;

our $VERSION = $MonkeyMan::VERSION;




has 'configuration' => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>   '_has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {
    return({});
}

has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      =>   '_get_logger',
    writer      =>   '_set_logger',
    predicate   =>   '_has_logger',
    builder     => '_build_logger',
    lazy        => 1
);

method _build_logger {
    return(MonkeyMan::Logger->instance);
}

has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      =>    'get_api',
    writer      =>   '_set_api',
    predicate   =>   '_has_api',
    builder     => '_build_api',
    lazy        => 1
);

method _build_api {
    return(
        MonkeyMan::CloudStack::API->new(
            cloudstack      => $self,
            configuration   => $self->get_configuration->{'api'}
        )
    );
}



#has 'cache' => (
#    is          => 'ro',
#    isa         => 'MonkeyMan::CloudStack::Cache',
#    reater      => '_get_cache',
#    writer      => '_set_cache',
#    predicate   => '_has_cache',
#    builder     => '_build_cache',
#    lazy        => 1
#);



__PACKAGE__->meta->make_immutable;

1;
