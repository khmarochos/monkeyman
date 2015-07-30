package MonkeyMan::CloudStack::Cache;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Utils;

# Use 3rd party libraries
use TryCatch;
use Scalar::Util qw(blessed);
use POSIX qw(strftime);

# Use Moose :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



has 'cs' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack',
    predicate   => 'has_cs',
    writer      => '_set_cs',
    required    => 'yes'
);
has configuration => (
    is          => 'ro',
    isa         => 'HashRef',
    writer      => '_set_onfiguration',
    predicate   => 'has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);
has memory_pool => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => '_get_memory_pool',
    writer      => '_set_memory_pool',
    predicate   => '_has_memory_pool',
    builder     => '_build_memory_pool',
    lazy        => 1,
    init_arg    => undef
);



sub _build_configuration {

    my $self = shift;

    return(eval { $self->cs->configuration->{'cache'} });

}



sub _build_memory_pool {

    return({
        lists       => {},
        initialized => time
    });

}



sub get_full_list {

    my($self, $element_type) = @_;
    my($log, $cs, $configuration);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                'cs'            => { variable   => \$cs },
                'configuration' => { variable   => \$configuration },
                '$element_type' => { value      =>  $element_type }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    }
    
    my $never_cache = $configuration->{'never'};
    if(defined($never_cache)) {
        foreach (split(/,\s*/, $never_cache)) {
            if(lc($element_type) eq lc($_)) {
                $log->trace(mm_sprintf("%ss are never being cached", $element_type));
                return(undef);
            }
        }
    }

    MonkeyMan::Exception->throw("The memory pool haven't been initialized")
        unless($self->_has_memory_pool);
    my $memory_pool = $self->_get_memory_pool;
    my $cached_list = $memory_pool->{'lists'}->{$element_type};

    unless(defined($cached_list)) {
        $log->trace(mm_sprintf("Don't have a list of %ss cached", $element_type));
        return(undef);
    }

    unless(blessed($cached_list->{'dom'}) && $cached_list->{'dom'}->isa("XML::LibXML::Document")) {
        $log->warn(mm_sprintf("The cached list of %ss isn't an XML::LibXML::Document object", $element_type));
        return(undef);
    }

    unless($cached_list->{'updated'} + $configuration->{'ttl'} >= time) {
        $log->trace(mm_sprintf(
            "The cached list of %ss is expired since %s",
                $element_type,
                strftime(MM_DATE_TIME_FORMAT, localtime($cached_list->{'updated'} + $configuration->{'ttl'}))
        ));
        return(undef);
    }
 
    return($cached_list);

}



sub store_full_list {

    my($self, $element_type, $dom, $updated) = @_;
    my($log);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                '$dom'          => {
                    value           => $dom,
                    isaref          => "XML::LibXML::Document",
                    error           => mm_sprintf("The %s DOM isn't valid", $dom)
                },
                '$element_type' => { value      =>  $element_type }
            });
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    }

    MonkeyMan::Exception->throw("The memory pool haven't been initialized")
        unless($self->_has_memory_pool);

    my $memory_pool = $self->_get_memory_pool;

    $memory_pool->{'lists'}->{$element_type}->{'dom'}       = $dom;
    $memory_pool->{'lists'}->{$element_type}->{'updated'}   = defined($updated) ? $updated : time;

    return($memory_pool->{'lists'}->{$element_type});

}
    



__PACKAGE__->meta->make_immutable;

1;
