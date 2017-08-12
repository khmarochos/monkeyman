package HyperMouse::ResourceCounter;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use Method::Signatures;
use DateTime;
use JSON::XS;



has '_collection' => (
    is          => 'ro',
    isa         => 'HashRef',
    init_arg    => undef,
    reader      => '_get_collection',
    writer      => '_set_collection',
    builder     => '_let_collection'
);

method _let_collection { { } };



method add_resources(
        HashRef $resources!,
       DateTime $from!,
       DateTime $till!
) {
    my @present_periods = $self->find_periods($from, $till);
    if(@present_periods) {
        my $split;
        foreach my $present_period (@present_periods) {
            my $present_from = $present_period->[0]->epoch;
            my $present_till = $present_period->[1]->epoch;
            my $desired_from = $from->epoch;
            my $desired_till = $till->epoch;
            if($present_from < $desired_from) {
                if($present_till == $desired_from) {
                    # ...(...[)++++++++++].......
                    $self->add_resources($resources, $from, $till);
                } elsif($present_till < $desired_till) {
                    # ...(...[+++)+++++++].......
                    $self->split_period($present_period->[0], $from, $present_period->[1]);
                    $self->add_resources($resources, $from, $present_period->[1]);
                    $self->add_resources($resources, $present_period->[1], $till);
                } elsif($present_till == $desired_till) {
                    # ...(...[++++++++++)].......
                    $self->split_period($present_period->[0], $from, $present_period->[1]);
                    $self->add_resources($resources, $from, $till);
                } elsif($present_till > $desired_till) {
                    # ...(...[+++++++++++]...)...
                    $self->split_period($present_period->[0], $from, $present_period->[1]);
                    $self->split_period($from, $till, $present_period->[1]);
                    $self->add_resources($resources, $from, $till);
                }
            } elsif($present_from == $desired_from) {
                if($present_till < $desired_till) {
                    # .......[(+)++++++++].......
                    # .......[(+++)++++++].......
                    $self->add_resources($resources, $present_period->[0], $present_period->[1]);
                    $self->add_resources($resources, $present_period->[1], $till);
                } elsif($present_till == $desired_till) {
                    # .......[(+++++++++)].......
                    my $resources_target = $self->get_resources($from, $till, 1);
                    while(my($resource_key, $resource_value) = each(%{ $resources })) {
                        $resources_target->{ $resource_key } = exists($resources_target->{ $resource_key })
                            ? $resource_value + $resources_target->{ $resource_key }
                            : $resource_value;
                    }
                } elsif($present_till > $desired_till) {
                    # .......[(++++++++++]...)...
                    $self->split_period($present_period->[0], $till, $present_period->[1]);
                    $self->add_resources($resources, $from, $till);
                }
            } elsif($present_from > $desired_from) {
                if($present_from == $desired_till) {
                    # .......[++++++++++(]...)...
                    $self->add_resources($resources, $from, $till);
                } elsif($present_till < $desired_till) {
                    # .......[++++(+)++++].......
                    # .......[+++(+++)+++].......
                    $self->add_resources($resources, $from, $present_period->[0]);
                    $self->add_resources($resources, $present_period->[0], $present_period->[1]);
                    $self->add_resources($resources, $present_period->[1], $till);
                } elsif($present_till == $desired_till) {
                    # .......[+++(++++++)].......
                    # .......[++++++++(+)].......
                    $self->add_resources($resources, $from, $present_period->[0]);
                    $self->add_resources($resources, $present_period->[0], $till);
                } elsif($present_till > $desired_till) {
                    # .......[+++(+++++++]...)...
                    $self->split_period($present_period->[0], $till, $present_period->[1]);
                    $self->add_resources($resources, $from, $present_period->[0]);
                    $self->add_resources($resources, $present_period->[0], $till);
                }
            }
        }
    } else {
        $self->init_period($resources, $from, $till, 2, 1);
    }
}

method sub_resources(
        HashRef $resources!,
       DateTime $from!,
       DateTime $till!
) {
    my $i = 0;
    $self->add_resources({
        map({ $_ = ($i++ % 2) ? 0 - $_ : $_; } each(%{ $resources }))
        # ^^^ Each second element (the value) is being reverted
    }, $from, $till);
}

method get_resources(
       DateTime $from!,
       DateTime $till!,
           Bool $fatal?
) {
    return(
        $self->_get_collection->{ $from->epoch }->{ $till->epoch } //
            ($fatal ?
                die(sprintf("No such period in collection: %s - %s", $from, $till)) :
                undef
            )
    );
}

method find_periods(
       DateTime $from!,
       DateTime $till!,
           Bool $exact?
) {
    my @found;
    my $from_epoch = $from->epoch;
    my $till_epoch = $till->epoch;
    if($exact) {
        if(exists($self->_get_collection->{ $from_epoch }->{ $till_epoch })) {
            push(@found, [ $from, $till ]);
        }
    } else {
        OVERLAP_CHECKS:
        foreach my $from_maybe (keys(%{ $self->_get_collection })) {
            next if($from_maybe >= $till_epoch);
            foreach my $till_maybe (keys(%{ $self->_get_collection->{ $from_maybe } })) {
                next if($till_maybe <= $from_epoch);
                if(
                    ($from_maybe < $till_epoch) &&
                    ($from_epoch < $till_maybe)
                ) {
                    push(@found, [
                        DateTime->from_epoch(epoch => $from_maybe),
                        DateTime->from_epoch(epoch => $till_maybe)
                    ]);
                    last(OVERLAP_CHECKS);
                }
            }
        }
    }
    return(@found);
}

method init_period(
        HashRef $resources!,
       DateTime $from!,
       DateTime $till!,
     Maybe[Int] $check? where [ undef, 0..2 ],
           Bool $fatal?
) {
    if      (($check eq 2) && $self->find_periods($from, $till, 0)) {
        return($fatal ?
            die(sprintf("The period overlaps with the existing one(s): %s - %s", $from, $till)) :
            undef
        );
    } elsif(($check eq 1) && $self->find_periods($from, $till, 1)) {
        return($fatal ?
            die(sprintf("The period is already initialized: %s - %s", $from, $till)) :
            undef
        );
    }
    $self->_get_collection->{ $from->epoch }->{ $till->epoch } = { %{ $resources } };
}

method delete_period(
       DateTime $from!,
       DateTime $till!,
           Bool $fatal?
) {
    if($self->find_periods($from, $till, 1)) {
        delete($self->_get_collection->{ $from->epoch }->{ $till->epoch });
    } elsif($fatal) {
        die(sprintf("Can't find the period to delete it: %s - %s", $from, $till));
    }
}

method split_period(
       DateTime $from!,
       DateTime $at!,
       DateTime $till!
) {
    my $resources = $self->get_resources($from, $till, 1);
    $self->delete_period($from, $till, 1);
    $self->init_period({ %{ $resources } }, $from, $at, 1);
    $self->init_period({ %{ $resources } }, $at, $till, 1);
}

method dump_collection {
    encode_json($self->_get_collection);
}



__PACKAGE__->meta->make_immutable;

1;
