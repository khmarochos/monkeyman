package MonkeyMan::CloudStack::API::Cache;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Roles::WithTimer';

use MonkeyMan::Constants qw(:cloudstack);
use MonkeyMan::Utils;
use MonkeyMan::Exception;

use Method::Signatures;



mm_register_exceptions qw(
    InvalidParametersValue
);



has 'cache_time' => (
    is          => 'rw',
    isa         => 'Int',
    reader      =>    'get_cache_time',
    writer      =>   '_set_cache_time',
    predicate   =>    'has_cache_time',
    builder     => '_build_cache_time'
);

method _build_cache_time {
    my $cache_time;
    $cache_time = $self
        ->get_api
            ->get_configuration
                ->{'cache'}
                    ->{'default_cache_time'};
    $cache_time = MM_CLOUDSTACK_API_DEFAULT_CACHE_TIME
        unless(defined($cache_time));
    return($cache_time);
}



method is_expired(
    Str $time_to_cmp!,
    Int $best_before = '+' . $self->get_cache_time
) {
    if($time_to_cmp =~ /^\s*([-+]?)\s*(\d+)\s*$/) {
        my $sign = $1;
        my $time = $2;
        if($sign eq '+') {
            $time = $self->get_time_current_rough + $time;
        } elsif($sign eq '-') {
            $time = $self->get_time_current_rough - $time;
        }
        $time_to_cmp = $time;
    } else {
        (__PACKAGE__ . '::Exception::InvalidParametersValue')->throwf(
            "Invalid time format (%s), please refer the code of the method",
            $time_to_cmp
        );
    }
    if($time_to_cmp >= $best_before) {
        return(1);
    } else {
        return(0);
    }

}

