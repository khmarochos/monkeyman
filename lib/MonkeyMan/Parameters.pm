package MonkeyMan::Parameters;

=head1 NAME

MonkeyMan::Parameters - options passed to a MonkeyMan-driven application

=cut

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

# Use 3rd-party libraries
use TryCatch;
use Getopt::Long;



has 'parameters' => (
    is          => 'ro',
    isa         => 'HashRef',
    init_arg    => undef,
    predicate   =>   '_has_parameters',
    reader      =>   '_get_parameters',
    builder     => '_build_parameters',
    lazy        => 1
);



sub _build_parameters {

    return({});

}



sub BUILD {

    my $self    = shift;
    my $mm      = $self->get_monkeyman;

    my $parameters_got = $self->_get_parameters;

    # Parsing options
    my %options;
    while(my($option, $parameter_name) = each(%{$mm->_get_parameters_to_get})) {
        $options{$option} = \($parameters_got->{$parameter_name});
    }
    GetOptions(%options) ||
        MonkeyMan::Exception->throw("Can't get command-line options");

    # Adding methods
    my $meta = $self->meta;
    foreach my $parameter_name (keys(%{$parameters_got})) {
        my $reader    =  "get_$parameter_name";
        my $writer    = "_set_$parameter_name";
        my $predicate =  "has_$parameter_name";
        $meta->add_attribute(
            Class::MOP::Attribute->new(
                $parameter_name => (
                    reader      => $reader,
                    writer      => $writer,
                    predicate   => $predicate,
                    is          => 'ro'
                )
            )
        );
        $meta->add_method(
            $parameter_name => sub { shift->$reader(@_); }
        );
        $self->$writer($parameters_got->{$parameter_name});
    }

}



#__PACKAGE__->meta->make_immutable;

1;
