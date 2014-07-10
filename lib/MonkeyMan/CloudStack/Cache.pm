package MonkeyMan::CloudStack::Cache;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;

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
    return($self->error(mm_sprintify("The logger hasn't been initialized: %s", $@)))
        if($@);

    my $memory_pool = $self->_get_memory_pool;
    my $cached_list = $memory_pool->{'lists'}->{$element_type};

    unless(defined($cached_list)) {
        $log->trace(mm_sprintify("Don't have a list of %ss cached", $element_type));
        return(undef);
    }

    unless(ref($cached_list->{'dom'}) eq "XML::LibXML::Document") {
        $log->trace(mm_sprintify("The cached list of %ss looks unhealthy", $element_type));
        return(undef);
    }

    unless($cached_list->{'updated'} + $self->_get_configuration->{'ttl'} >= time) {
        $log->trace(mm_sprintify(
            "The cached list of %s is expired since %s",
                $element_type,
                strftime(MMDateTimeFormat, $cached_list->{'updated'} + $self->_get_configuration->{'ttl'})
        ));
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
    return($self->error(mm_sprintify("The %s DOM isn't valid", $dom)))
        unless(ref($dom) eq 'XML::LibXML::Document');
    $updated = time
        unless(defined($updated));
    return($self->error("The memory pool haven't been initialized"))
        unless($self->_has_memory_pool);
    my $memory_pool = $self->_get_memory_pool;
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error(mm_sprintify("The logger hasn't been initialized: %s", $@)))
        if($@);

    $memory_pool->{'lists'}->{$element_type}->{'dom'}       = $dom;
    $memory_pool->{'lists'}->{$element_type}->{'updated'}   = $updated;

    return($memory_pool->{'lists'}->{$element_type});

}
    



__PACKAGE__->meta->make_immutable;

1;
