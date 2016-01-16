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



has time_started => (
    is          => 'ro',
    isa         => 'ArrayRef',
    reader      =>    'get_time_started',
    predicate   =>    'has_time_started',
    builder     => '_build_time_started',
    lazy        => 0
);

method _build_time_started {

    $self->get_time_current;

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
        strftime("%Y.%m.%d.%H.%M.%S", localtime($seconds)),
        $microseconds
    );

}



method get_time_current_rough {

    return(${$self->get_time_current}[0]);

}



method get_time_current {

    my @time_current = gettimeofday;

    return(\@time_current);

}

method get_time_passed {

    tv_interval(
        $self->get_time_started,
        $self->get_time_current
    )

}


method get_time_passed_formatted {

    sprintf("%.6f seconds passed for %s",
        $self->get_time_passed,
        $self->meta->name
    );

}



1;
