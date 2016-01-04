package MonkeyMan::CloudStack;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

use MonkeyMan::CloudStack::API;

use Method::Signatures;



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    required    => 1
);



has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      =>    'get_api',
    writer      =>   '_set_api',
    builder     => '_build_api',
    lazy        => 1
);

method _build_api {

    MonkeyMan::CloudStack::API->new(
        cloudstack      => $self,
        configuration   => $self->get_configuration->{'api'}
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
