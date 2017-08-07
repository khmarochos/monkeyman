package ResourceCounter;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use Method::Signatures;
use DateTime;



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
       DateTime $since!,
       DateTime $till!
) {
    my @affected_periods = $self->find_periods($since, $till);
    if(@affected_periods) {
        my $split;
        foreach my $affected_period (@affected_periods) {
            warn('Desired:  ', $since, '-', $till);
            warn('Affected: ', $affected_period->[0], '-', $affected_period->[1]);
            if(
                ($affected_period->[0]->epoch == $since->epoch) &&
                ($affected_period->[1]->epoch == $till->epoch)
            ) {
                    # .......[(......)].......
                my $resources_target = $self->get_resources($since, $till, 1);
                while(my($resource_key, $resource_value) = each(%{ $resources })) {
                    $resources_target->{ $resource_key } = exists($resources_target->{ $resource_key })
                        ? $resource_value + $resources_target->{ $resource_key }
                        : $resource_value;
                }
            } elsif($affected_period->[0]->epoch < $since->epoch) {
                if($affected_period->[1]->epoch == $since->epoch) {
                    # ...(...[).......].......
                } elsif($affected_period->[1]->epoch <= $till->epoch) {
                    # ...(...[...)....].......
                    # ...(...[.......)].......
                    $self->split_period($affected_period->[0], $since, $affected_period->[1]);
                    $self->add_resources($resources, $since, $affected_period->[1]);
                } else {
                    # ...(...[........]...)...
                    $self->split_period($affected_period->[0], $since, $affected_period->[1]);
                    $self->split_period($since, $till, $affected_period->[1]);
                    $self->add_resources($resources, $since, $till);
                }
            } elsif($affected_period->[1]->epoch > $till->epoch) {
                if($affected_period->[0]->epoch eq $till->epoch) {
                    # .......[.......(]...)...
                } elsif($affected_period->[0]->epoch >= $since->epoch) {
                    # .......[(.......]...)...
                    # .......[....(...]...)...
                    $self->split_period($affected_period->[0], $till, $affected_period->[1]);
                    $self->add_resources($resources, $since, $affected_period->[0]);
                    $self->add_resources($resources, $affected_period->[0], $till);
                } else {
                    $self->split_period($affected_period->[0], $affected_period->[1], $since);
                    $self->split_period($since, $affected_period->[1], $till);
                    $self->add_resources($resources, $since, $till);
                }
            } else {
                    # .......[..(...)..].......
                $self->add_resources($resources, $since, $affected_period->[0]);
                $self->add_resources($resources, $affected_period->[0], $affected_period->[1]);
                $self->add_resources($resources, $affected_period->[1], $till);
            }
        }
    } else {
        $self->init_period($resources, $since, $till, 2, 1);
    }
}

method get_resources(
       DateTime $since!,
       DateTime $till!,
           Bool $fatal?
) {
    return(
        $self->_get_collection->{ $since->epoch }->{ $till->epoch } //
            ($fatal ?
                die(sprintf("No such period in collection: %s - %s", $since, $till)) :
                undef
            )
    );
}

method find_periods(
       DateTime $since!,
       DateTime $till!,
           Bool $exact?
) {
    my @found;
    if($exact) {
        if(exists($self->_get_collection->{ $since->epoch }->{ $till->epoch })) {
            push(@found, [ $since, $till ]);
        }
    } else {
        foreach my $maybe_since (keys(%{ $self->_get_collection })) {
            my $push;
            if(($maybe_since >= $since->epoch) && ($maybe_since <= $till->epoch)) {
                $push = 1;
            }
            foreach my $maybe_till (keys(%{ $self->_get_collection->{ $maybe_since } })) {
                if(($maybe_till >= $since->epoch) && ($maybe_till <= $till->epoch)) {
                    $push = 1;
                }
                push(@found, [
                    DateTime->from_epoch(epoch => $maybe_since, time_zone => 'Europe/Kiev'),    #FIXME
                    DateTime->from_epoch(epoch => $maybe_till, time_zone => 'Europe/Kiev')      #FIXME
                ])
                    if($push);
            }
        }
    }
    return(@found);
}

method init_period(
        HashRef $resources!,
       DateTime $since!,
       DateTime $till!,
     Maybe[Int] $check? where [ undef, 0..2 ],
           Bool $fatal?
) {
    if      (($check eq 2) && $self->find_periods($since, $till, 0)) {
        return($fatal ?
            die(sprintf("The period overlaps with the existing one(s): %s - %s", $since, $till)) :
            undef
        );
    } elsif(($check eq 1) && $self->find_periods($since, $till, 1)) {
        return($fatal ?
            die(sprintf("The period is already initialized: %s - %s", $since, $till)) :
            undef
        );
    }
    $self->_get_collection->{ $since->epoch }->{ $till->epoch } = { %{ $resources } };
    warn("Created: $since-$till");
}

method delete_period(
       DateTime $since!,
       DateTime $till!,
           Bool $fatal?
) {
    if($self->find_periods($since, $till, 1)) {
        delete($self->_get_collection->{ $since->epoch }->{ $till->epoch });
    } elsif($fatal) {
        die(sprintf("Can't find the period to delete it: %s - %s", $since, $till));
    }
}

method split_period(
       DateTime $since!,
       DateTime $at!,
       DateTime $till!
) {
    my $resources = $self->get_resources($since, $till, 1);
    $self->delete_period($since, $till, 1);
    $self->init_period({ %{ $resources } }, $since, $at, 1);
    $self->init_period({ %{ $resources } }, $at, $till, 1);
}



__PACKAGE__->meta->make_immutable;

1;
