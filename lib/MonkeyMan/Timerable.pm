package MonkeyMan::Timerable;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

# Use 3rd-party libraries
use Time::HiRes qw(gettimeofday tv_interval);



has time => (
    is      => 'rw',
    isa     => 'ArrayRef',
    reader  => '_get_time',
    writer  => '_set_time',
    builder => '_build_time',
    trigger => \&_time_set
);

sub _get_current_time {

    my @current_time = gettimeofday;

    return(\@current_time);

}

sub _build_time {

    return(shift->_get_current_time);

}

sub _time_set {

    my $self        = shift;
    my $new_time    = shift;
    my $old_time    = shift;

    return(tv_interval($old_time, $new_time));

}

sub update_time {

    my $self = shift;

    #return(tv_interval($self->_get_time, $self->_get_current_time));
    return($self->_set_time($self->_get_current_time));

}

sub tell {

    my $self = shift;

    sprintf("<%.6f seconds passed for %s>",
        $self->update_time,
        $self->meta->name
    );

}



1;
