package MonkeyMan::GotOptions;

=head1 NAME

MonkeyMan::GotOptions - options passed to a MonkeyMan-driven application

=cut

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

# Use 3rd-party libraries
use TryCatch;
use Getopt::Long;



has 'got_options' => (
    is          => 'ro',
    isa         => 'HashRef',
    init_arg    => undef,
    builder     => '_build_got_options',
    reader      => '_get_got_options',
    lazy        => 1
);



sub _build_got_options {

    return({});

}



sub BUILD {

    my $self    = shift;
    my $mm      = $self->mm;

    my %options;

    # Parsing options
    while(my($option_parameters, $option_name) = each(%{$mm->_get_get_options})) {
        $options{$option_parameters} = \($self->_get_got_options->{$option_name});
    }
    GetOptions(%options);

    # Adding methods
    my $meta = $self->meta;
    foreach my $option_name (keys(%{$self->_get_got_options})) {
        my $reader    =      "$option_name";
        my $writer    = "_set_$option_name";
        $meta->add_attribute(
            Class::MOP::Attribute->new(
                $option_name => (
                    reader      => $reader,
                    writer      => $writer,
                    is          => 'ro'
                )
            )
        );
        $self->$writer($self->_get_got_options->{$option_name});
    }

}



#__PACKAGE__->meta->make_immutable;

1;
