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

    my($self, $element_type) = @_;
    my($mm, $log);

    eval { mm_method_checks(
        'object' => $self,
        'checks' => {
            'mm'                => { variable   => \$mm },
            'log'               => { variable   => \$log },
            '$element_type'     => { value      =>  $element_type }
        }
    ); };
    return($self->error($@))
        if($@);

    my $never_cache = $mm->{'configuration'}->{'cloudstack'}->{'cache'}->{'never'};
    if(defined($never_cache)) {
        foreach (split(/,\s*/, $never_cache)) {
            if(lc($element_type) eq lc($_)) {
                $log->trace(mm_sprintify("%ss are never being cached", $element_type));
                return(undef);
            }
        }
    }

    return($self->error("The memory pool haven't been initialized"))
        unless($self->_has_memory_pool);
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
            "The cached list of %ss is expired since %s",
                $element_type,
                strftime(MMDateTimeFormat, localtime($cached_list->{'updated'} + $self->_get_configuration->{'ttl'}))
        ));
        return(undef);
    }
 
    return($cached_list);

}



sub store_full_list {

    my($self, $element_type, $dom, $updated) = @_;
    my($mm, $log);

    eval { mm_method_checks(
        'object' => $self,
        'checks' => {
            'mm'            => { variable   => \$mm },
            'log'           => { variable   => \$log },
            '$dom'          => {
                value           => $dom,
                isaref          => "XML::LibXML::Document",
                error           => mm_sprintify("The %s DOM isn't valid", $dom)
            },
            '$element_type' => { value      =>  $element_type }
        });
    };
    return($self->error($@))
        if($@);

    return($self->error("The memory pool haven't been initialized"))
        unless($self->_has_memory_pool);
    my $memory_pool = $self->_get_memory_pool;

    $memory_pool->{'lists'}->{$element_type}->{'dom'}       = $dom;
    $memory_pool->{'lists'}->{$element_type}->{'updated'}   = defined($updated) ? $updated : time;

    return($memory_pool->{'lists'}->{$element_type});

}
    



__PACKAGE__->meta->make_immutable;

1;
