package MonkeyMan::Roles::WithTimer;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

# Use 3rd-party libraries
use Method::Signatures;
use Time::HiRes qw(gettimeofday tv_interval);
use POSIX qw(strftime);
use POSIX::strptime;



has time_started => (
    is          => 'ro',
    isa         => 'ArrayRef',
    reader      =>    'get_time_started',
    predicate   =>    'has_time_started',
    builder     => '_build_time_started',
    lazy        => 0
);

method _build_time_started {
    $self->get_time_current_precise;
}



has time_started_formatted => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_time_started_formatted',
    predicate   =>    'has_time_started_formatted',
    builder     => '_build_time_started_formatted',
    lazy        => 1
);

method _build_time_started_formatted {
    my($seconds, $microseconds) = (@{$self->get_time_started});
    sprintf(
        "%s.%06d",
        $self->format_time($seconds),
        $microseconds
    );
}



method get_time_current_rough {
    return($self->get_time_current(1));
}

method get_time_current_precise {
    return($self->get_time_current(0));
}

method get_time_current(Bool $rough = 0) {
    my @time_current = gettimeofday; return($rough ? $time_current[0] : \@time_current);
}

method get_time_passed {
    return(
        tv_interval(
            $self->get_time_started,
            $self->get_time_current
        )
    );
}

method get_time_passed_formatted {
    return(
        sprintf("%.6f seconds passed for %s",
            $self->get_time_passed,
            $self
        )
    );
}



method format_time(Int $time!) {
    return(
        POSIX::strftime(&MonkeyMan::DEFAULT_DATE_TIME_FORMAT, localtime($time)),
    );
}

method parse_time(Str $time!) {
    # FIXME: Make it considering the timezone!
    return(
        POSIX::strftime("%s", (POSIX::strptime($time, "%Y-%m-%dT%H:%M:%S%z"))[0..7])
    );
}



1;
