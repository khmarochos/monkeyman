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

            use Data::Dumper; Dumper($handy);
            
            my $handy_name          = defined($handy->{'name'}) ?
                                              $handy->{'name'} :
                                              confess("The name of the handy isn't defined");
            my $handy_default_val   = $handy->{'default_val'};
            my $handy_default       = $handy->{'default'};
            my $handy_initializer   = $handy->{'initializer'};
            my $handy_strict        = defined($handy->{'strict'}) ?
                                              $handy->{'strict'} :
                                              1;

            # my $handy_initializer = (defined($handy->{'initializer'}) && ref($handy->{'initializer'}) eq 'CODE') ?
            #   $handy->{'initializer'} : confess("The initializer is not a code reference");

            if($associated_class->has_method($handy->{'name'})) {
                confess(sprintf("The %s method already exists in the %s class", $handy_name, $associated_class->name));
            }

            $associated_class->add_method(
                $handy_name => Class::MOP::Method->wrap(
                    sub {

                        my $read_method_ref = $self->get_read_method_ref;
                        confess("Can't find the reader method")
                            unless(
                                    ref($read_method_ref) &&
                                    ref($read_method_ref) eq 'CODE' ||
                                blessed($read_method_ref) &&
                                        $read_method_ref->isa('Moose::Meta::Method::Accessor')
                            );

                        my $slot =
                            defined($_[1]) ? $_[1] :
                                defined($handy_default_val) ? $handy_default_val :
                                    $_[0]->can($handy_default) ? $_[0]->$handy_default :
                                        undef;
                        confess(
                            "The slot hadn't been defined when the handy was called, " .
                            "neither the default slot has been defined"
                        )
                            if(!defined($slot));

                        @_ = ($_[0]); # 8< Cut it short, or the reader will complain! 8<

                        my $hashref = &{ $read_method_ref };
                        confess("The attribute doesn't contain a HashRef as it's supposed to")
                            unless(ref($hashref) eq 'HASH');

                        $hashref->{$slot} = $_[0]->$handy_initializer($slot)
                            if(!defined($hashref->{$slot}) && defined($handy_initializer));

                        confess(sprintf("The %s slot is empty (%s)", $slot, $hashref))
                            if(!defined($hashref->{$slot}) && $handy_strict);

                        return($hashref->{$slot});

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
