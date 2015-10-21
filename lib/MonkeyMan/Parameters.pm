package MonkeyMan::Parameters;

=head1 NAME

MonkeyMan::Parameters - options passed to a MonkeyMan-driven application

=cut

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
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
    builder     => '_build_parameters',
    reader      => '_get_parameters',
    predicate   => '_has_parameters',
    lazy        => 1
);



sub _build_parameters {

    return({});

}



sub BUILD {

    my $self    = shift;
    my $mm      = $self->mm;

    my $parameters = $self->_get_parameters;

    # Parsing options
    my %options;
    while(my($option, $parameter_name) = each(%{$mm->_get_parse_parameters})) {
        $options{$option} = \($parameters->{$parameter_name});
    }
    GetOptions(%options) ||
        MonkeyMan::Exception->throw("Can't get command-line options");

    # Adding methods
    my $meta = $self->meta;
    foreach my $parameter_name (keys(%{$parameters})) {
        my $reader    =  "get_$parameter_name";
        my $writer    = "_set_$parameter_name";
        $meta->add_attribute(
            Class::MOP::Attribute->new(
                $parameter_name => (
                    reader  => $reader,
                    writer  => $writer,
                    is      => 'ro'
                )
            )
        );
        $meta->add_method(
            $parameter_name => sub { shift->$reader(@_); }
        );
        $self->$writer($parameters->{$parameter_name});
    }

}



#__PACKAGE__->meta->make_immutable;

1;
