package MonkeyMan::CloudStack;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Utils;
use MonkeyMan::Exception;
use MonkeyMan::CloudStack::API;
use MonkeyMan::CloudStack::Cache;

# Use 3rd-party libraries
use TryCatch;
use POSIX qw(strftime);

# Use Moose :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



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
        my $api;
        try {
            $api = $self->init_api;
        } catch(MonkeyMan::Exception $e) {
            $e->throw;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't %s->init_api(): %s", $self, $e);
        }
        $self->_set_api($api);
    }

    unless($self->skip_init->{'cache'}) {
        my $cache;
        try {
            $cache = $self->init_cache;
        } catch(MonkeyMan::Exception $e) {
            $e->throw;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't %s->init_cache(): %s", $self, $e);
        }
        $self->_set_cache($cache);
    }

}



sub _build_configuration {

    my $self = shift;

    $self->mm->configuration->{'cloudstack'};

}



sub init_api {

    my $self = shift;
    my $api;

    try {
        $api = MonkeyMan::CloudStack::API->new(cs => $self);
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't MonkeyMan::CloudStack::API->new(): %s", $e);
    }

    return($api);

}



sub init_cache {

    my $self = shift;
    my $cache;

    try {
        $cache = MonkeyMan::CloudStack::Cache->new(cs => $self);
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch(Moose::Exception $e) {
        MonkeyMan::Exception->throw($e->message);
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't MonkeyMan::CloudStack::Cache->new(): %s", $e);
    }

    return($cache);

}



__PACKAGE__->meta->make_immutable;

1;
