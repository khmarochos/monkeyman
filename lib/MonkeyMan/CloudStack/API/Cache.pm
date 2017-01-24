package MonkeyMan::CloudStack::API::Cache;

use strict;
use warnings;

use constant CLOUDSTACK_API_DEFAULT_CACHE_TIME                  => 300;
use constant CLOUDSTACK_API_DEFAULT_GARBAGE_COLLECTOR_FREQUENCY => 300;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Roles::WithTimer';

# Use my own modules
use MonkeyMan::Exception qw(
    InvalidParametersValue
);

# Use 3rd-party libraries
use Method::Signatures;



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
    return(MonkeyMan::Logger->instance);
}



has 'cache_pool' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_cache_pool',
    writer      =>   '_set_cache_pool',
    predicate   =>   '_has_cache_pool',
    builder     => '_build_cache_pool',
    lazy        => 1
);

method _build_cache_pool {
    return({});
}



method save_object(
    Str         $index!,
    Defined     $object!,
    Maybe[Str]  $best_before?   = '+' . $self->get_cache_time,
    Int         $now?           = $self->get_time_current_rough
) {
    $self->_get_logger->tracef(
        "Saving the %s object as %s, best before %s, it's %s now",
        ref($object) ? $object : \$object, $index, $best_before, $now
    );
    $self->_get_cache_pool->{ $index } = {
        object      => $object,
        stored      => $now,
        best_before => $self->calculate_time($best_before, $now)
    };

    $self->_garbage_collector;
}

method restore_object(
    Str         $index!,
    Maybe[Str]  $best_before?,
    Int         $now? = $self->get_time_current_rough
) {

    $self->_garbage_collector;

    my $logger = $self->_get_logger;
    my $record = $self->_get_cache_pool->{ $index };
    my $object;
    if(
        defined($record) &&
            ref($record) eq 'HASH'
    ) {
        $best_before = 
            defined($best_before)
                ? $best_before
                : defined($record->{'best_before'})
                        ? $record->{'best_before'}
                        : $self->calculate_time('+' . $self->get_cache_time);
        if($self->is_expired($record->{'stored'}, $best_before, $now)) {
            $logger->tracef(
                "Can't restore the object called %s from the cache, it had exired at %s, now it's %s",
                $index,
                $best_before,
                $now
            );
        } else {
            $logger->tracef(
                "Restoring the object called %s from the cache, it expires at %s, now it's %s",
                $index,
                $best_before,
                $now
            );
            return($record->{'object'});
        }
    } else {
        $logger->tracef("The object called %s hasn't been found in the cache", $index);
    }
    return(undef);
}



has 'cache_time' => (
    is          => 'rw',
    isa         => 'Int',
    reader      =>    'get_cache_time',
    writer      =>   '_set_cache_time',
    predicate   =>    'has_cache_time',
    builder     => '_build_cache_time',
    lazy        => 1
);

method _build_cache_time {
    return(CLOUDSTACK_API_DEFAULT_CACHE_TIME);
}



method is_expired(
    Int $stored!,
    Str $best_before?   = '+' . $self->get_cache_time,
    Int $now?           = $self->get_time_current_rough
) {
    if($now >= $self->calculate_time($best_before, $now)) {
        return(1);
    } else {
        return(0);
    }
}



method calculate_time(
    Maybe[Str] $best_before?   = '+0',
    Maybe[Int] $now?           = $self->get_time_current_rough
) {
    if($best_before =~ /^\s*(\+?)\s*(\d+)\s*$/) {
        my $sign = $1;
        my $time = $2;
        if($sign) {
            $time = $now + $time;
        }
        return($time);
    }
    (__PACKAGE__ . '::Exception::InvalidParametersValue')->throwf(
        'Invalid "best before" format (%s)', $best_before
    );
}



has 'garbage_collector_frequency' => (
    is          => 'rw',
    isa         => 'Int',
    reader      =>   '_get_garbage_collector_frequency',
    writer      =>   '_set_garbage_collector_frequency',
    predicate   =>   '_has_garbage_collector_frequency',
    builder     => '_build_garbage_collector_frequency',
    lazy        => 1
);

method _build_garbage_collector_frequency {
    return(CLOUDSTACK_API_DEFAULT_GARBAGE_COLLECTOR_FREQUENCY);
}

has 'garbage_collected' => (
    is          => 'rw',
    isa         => 'Int',
    reader      =>   '_get_garbage_collected',
    writer      =>   '_set_garbage_collected',
    predicate   =>   '_has_garbage_collected',
    builder     => '_build_garbage_collected',
    lazy        => 1
);

method _build_garbage_collected {
    return($self->get_time_current_rough);
}

method _garbage_collector (
    Int $now?       = $self->get_time_current_rough,
    Int $collected? = $self->_get_garbage_collected,
    Int $frequency? = $self->_get_garbage_collector_frequency,
) {
    if($now > $collected + $frequency) {
        my $cache_pool = $self->_get_cache_pool;
        foreach my $index (keys(%{ $cache_pool })) {
            my $stored      = $cache_pool->{ $index }->{'stored'};
            my $best_before = $cache_pool->{ $index }->{'best_before'};
            if($self->is_expired($stored, $best_before, $now)) {
                $self->_get_logger->tracef(
                    "Removing the %s record from the cache, as it had been expired at %s, now it's %s",
                    $index,
                    $best_before,
                    $now
                );
                delete($cache_pool->{ $index });
            }
        }
    }
}



__PACKAGE__->meta->make_immutable;

1;
