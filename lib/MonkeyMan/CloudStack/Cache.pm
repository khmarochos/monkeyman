package MonkeyMan::CloudStack::Cache;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);
has configuration => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => '_get_configuration',
    writer      => '_set_configuration',
    predicate   => 'has_configuration',
    required    => 'yes'
);
has memory_pool => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => '_get_memory_pool',
    writer      => '_set_memory_pool',
    predicate   => '_has_memory_pool',
    init_arg    => undef
);



sub BUILD {

    my $self = shift;

    $self->_set_memory_pool({
        lists       => {},
        initialized => time
    });

}



sub get_full_list {

    my $self = shift;
    my $element_type = shift;

    return($self->error("The element's type isn't defined"))
        unless(defined($element_type));
    return($self->error("The memory pool haven't been initialized"))
        unless($self->_has_memory_pool);
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error("The logger hasn't been initialized: $@"))
        if($@);

    my $memory_pool = $self->_get_memory_pool;
    my $cached_list = $memory_pool->{'lists'}->{$element_type};

    unless(defined($cached_list)) {
        $log->trace("Don't have a list of ${element_type}s in the memory pool");
        return(undef);
    }

    unless(ref($cached_list->{'dom'}) eq "XML::LibXML::Document") {
        $log->trace("The cached list of ${element_type}s looks unhealthy");
        return(undef);
    }

    unless($cached_list->{'updated'} + $self->_get_configuration->{'ttl'} > time) {
        $log->trace("The cached list of ${element_type}s is expired");
        return(undef);
    }
 
    return($cached_list);

}



sub store_full_list {

    my $self            = shift;
    my $element_type    = shift;
    my $dom             = shift;
    my $updated         = shift;

    return($self->error("The element's type isn't defined"))
        unless(defined($element_type));
    return($self->error("The DOM isn't defined"))
        unless(defined($dom));
    return($self->error("The DOM isn't valid: $dom"))
        unless(ref($dom) eq 'XML::LibXML::Document');
    $updated = time
        unless(defined($updated));
    return($self->error("The memory pool haven't been initialized"))
        unless($self->_has_memory_pool);
    my $memory_pool = $self->_get_memory_pool;
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error("The logger hasn't been initialized: $@"))
        if($@);

    $memory_pool->{'lists'}->{$element_type}->{'dom'}       = $dom;
    $memory_pool->{'lists'}->{$element_type}->{'updated'}   = $updated;

}
    



__PACKAGE__->meta->make_immutable;

1;
