package MonkeyMan::Zendesk;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

use MonkeyMan::Zendesk::API;

use Method::Signatures;




has 'configuration' => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    required    => 0
);

has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Zendesk::API',
    reader      =>    'get_api',
    writer      =>   '_set_api',
    builder     => '_build_api',
    lazy        => 1
);

method _build_api {

    MonkeyMan::Zendesk::API->new(
        zendesk         => $self,
        configuration   => $self->get_configuration->{'api'}
    );

}



__PACKAGE__->meta->make_immutable;

1;
