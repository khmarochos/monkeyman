package MonkeyMan::Parameters;

=head1 NAME

MonkeyMan::Parameters - options passed to a MonkeyMan-driven application

=cut

use strict;
use warnings;

use MonkeyMan::Exception qw(SuperflousParametersGiven);

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

# Use 3rd-party libraries
use Method::Signatures;
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



method _build_parameters {

    return({});

}



method BUILD(...) {

    my $monkeyman       = $self->get_monkeyman;
    my $parameters_got  = $self->_get_parameters;

    # Parsing parameters
    my %parameters;
    while(
        my(
            $parameter_definition,
            $parameter_name
        ) = each(%{$monkeyman->_get_parameters_to_get})
    ) {
        $parameters{$parameter_definition} = \($parameters_got->{$parameter_name});
    }
    GetOptions(%parameters) ||
        MonkeyMan::Exception->throw("Can't get command-line parameters");

    # Adding methods
    my $meta = $self->meta;
    foreach my $parameter_name (keys(%{$parameters_got})) {

        my $predicate =  "has_$parameter_name";
        my $reader    =  "get_$parameter_name";
        my $writer    = "_set_$parameter_name";

        $meta->add_attribute(
            Class::MOP::Attribute->new(
                $parameter_name => (
                    predicate   => $predicate,
                    reader      => $reader,
                    writer      => $writer,
                    is          => 'ro'
                )
            )
        );

        $self->$writer($parameters_got->{$parameter_name});

        # Actually we don't need it:
        #
        # $meta->add_method(
        #     $parameter_name => sub { shift->$reader(@_); }
        # );
    }

}



method only_one(Bool :$fatal, ArrayRef[Str] :$lone_attributes) {

    my $monkeyman                   = $self->get_monkeyman;
    my $logger                      = $monkeyman->get_logger;
    my %parameters_by_definitions   = %{ $self->get_monkeyman->_get_parameters_to_get };
    my %parameters_by_attributes    = reverse(%parameters_by_definitions);
    my @result;

    foreach my $lone_attribute (@{ $lone_attributes }) {
        my $reader  = 'get_' . $lone_attribute;
        my $value   = $self->$reader;
        if(defined($value)) {
            push(@result, {
                attribute   => $lone_attribute,
                definition  => $parameters_by_attributes{$lone_attribute},
                value       => $value
            });
        }
    }

    if(@result > 1) {
        my @superflous_parameters;
        for my $i (2..@result) {
            push(@superflous_parameters, $result[$i-1]->{'attribute'});
            $logger->warnf(
                "The %s parameter (%s) is already given, " .
                "the %s parameter (%s) is superflous",
                $result[0]   ->{'attribute'}, $result[0]   ->{'definition'},
                $result[$i-1]->{'attribute'}, $result[$i-1]->{'definition'}
            );
        }
        if($fatal) {
            (__PACKAGE__ . '::Exception::SuperflousParametersGiven')->throwf(
                "Superflous parameter(s) found (%s), " .
                "which is considered as fatal for this application",
                join(', ', @superflous_parameters)
            );
        }
    }

}



#__PACKAGE__->meta->make_immutable;

1;
