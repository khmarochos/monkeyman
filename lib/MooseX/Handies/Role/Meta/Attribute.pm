package MooseX::Handies::Role::Meta::Attribute;

use strict;
use warnings;

use Moose::Role;
use Carp;



has handies => (
    is          => 'ro',
    isa         => 'ArrayRef',
    predicate   => 'has_handies'
);



after install_accessors => sub {

    my $self = shift;

    if($self->has_handies) {

        my $associated_class    = $self->associated_class;
        my @handies             = @{$self->handies};

        foreach my $handy (@handies) {

            my $handy_name      = $handy->{'name'};
            confess("The name of the handy isn't defined")
                unless(defined($handy_name));

            my $handy_default   = $handy->{'default'};
            confess("The default slot of the handy isn't defined")
                unless(defined($handy_name));

            my $handy_strict    = $handy->{'strict'};
            confess("The strictness of the handy isn't defined")
                unless(defined($handy_strict));

            if($associated_class->has_method($handy->{'name'})) {
                confess(sprintf("The %s method already exists in the %s class", $handy_name, $associated_class->name));
            }

            $associated_class->add_method(
                $handy_name => Class::MOP::Method->wrap(
                    sub {

                        my $read_method_ref = $self->get_read_method_ref;
                        confess("Can't find the read method")
                            unless(
                                    ref($read_method_ref) &&
                                blessed($read_method_ref) &&
                                        $read_method_ref->isa('Moose::Meta::Method::Accessor')
                            );

                        my $slot = $_[1];
                           $slot = defined($slot) ? $slot : $handy_default;

                        @_ = ($_[0]); # Cut it short >8

                        my $hashref = &{ $read_method_ref };
                        confess("The attribute doesn't contain a HashRef as it's supposed to")
                            unless(ref($hashref) eq 'HASH');

                        my $result = $hashref->{$slot};
                        confess(sprintf("The %s slot is empty", $slot))
                            if($handy_strict && !defined($result));

                        return($result);

                    }, (
                        name            => $handy_name,
                        package_name    => __PACKAGE__
                    )
                )
            );
        }

    }

};

no Moose::Role;

1;
