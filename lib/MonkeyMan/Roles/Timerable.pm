package MonkeyMan::Roles::Timerable;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

# Use 3rd-party libraries
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

sub _build_time_started {

    shift->get_time_current;

}



has time_started_formatted => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_time_started_formatted',
    predicate   =>    'has_time_started_formatted',
    builder     => '_build_time_started_formatted',
    lazy        => 1
);

sub _build_time_started_formatted {

    my $self = shift;

    my($seconds, $microseconds) = (@{$self->get_time_started});

    sprintf(
        "%s.%06d",
        strftime("%Y.%m.%d.%H.%M.%S", localtime($seconds)),
        $microseconds
    );

}



sub get_time_current {

    my @time_current = gettimeofday;

    \@time_current;

}

sub get_time_passed {

    my $self = shift;

    tv_interval(
        $self->get_time_started,
        $self->get_time_current
    )

}


sub get_time_passed_formatted {

    my $self = shift;

    sprintf("<%.6f seconds passed for %s>",
        $self->get_time_passed,
        $self->meta->name
    );

}



1;
