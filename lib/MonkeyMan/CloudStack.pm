package MonkeyMan::CloudStack;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::API;
use MonkeyMan::CloudStack::Cache;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

use POSIX qw(strftime);

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);
has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    writer      => '_set_configuration',
    predicate   => 'has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);
has 'skip_init' => (
    is          => 'ro',
    isa         => 'HashRef',
    default     => sub {{}}
);
has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    writer      => '_set_api',
    predicate   => 'has_api',
);
has 'cache' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Cache',
    writer      => '_set_cache',
    predicate   => 'has_cache'
);



sub BUILD {

    my $self = shift;

    # Self-configuring

    unless($self->skip_init->{'api'}) {
        my $api = $self->init_api;
        die($self->error_message)
            unless(defined($api));
        $self->_set_api($api);
    }

    unless($self->skip_init->{'cache'}) {
        my $cache = $self->init_cache;
        die($self->error_message)
            unless(defined($cache));
        $self->_set_cache($cache);
    }

}



sub _build_configuration {

    my $self = shift;

    return(eval { $self->mm->configuration->{'cloudstack'} });

}



sub init_api {

    my $self = shift;

    my $api = eval { MonkeyMan::CloudStack::API->new(cs => $self); };

    return($@ ?
        $self->error(mm_sprintify("Can't MonkeyMan::CloudStack::API::new(): %s", $@)) :
        $api
    );

}



sub init_cache {

    my $self = shift;

    my $cache = eval { MonkeyMan::CloudStack::Cache->new(cs => $self); };

    return($@ ?
        $self->error(mm_sprintify("Can't MonkeyMan::CloudStack::Cache::new(): %s", $@)) :
        $cache
    );

}



__PACKAGE__->meta->make_immutable;

1;
