package MonkeyMan::Parameters;

=head1 NAME

MonkeyMan::Parameters - options passed to a MonkeyMan-driven application

=cut

use strict;
use warnings;

use MonkeyMan::Exception qw(ParameterKeyReserved);

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

# Use 3rd-party libraries
use Method::Signatures;
use TryCatch;
use Getopt::Long;
use YAML::XS;



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

    # Getting lists of parameters' keys and attribute names defined by the
    # parameters_to_get
    my @parameter_keys_defined;
    my @parameter_names_defined;
    while(my($parameter_keys, $parameter_name) = each(%{ $monkeyman->_get_parameters_to_get })) {
        push(@parameter_keys_defined, ($parameter_keys =~ /(?:\|?([a-zA-Z]+)(?:=.+)?)/g));
        push(@parameter_names_defined, $parameter_name);
    }

    # Parsing some YAML here, filling the HASH referenced by parameters_to_get,
    # overriding everything without any warnings as it's documented.
    if($monkeyman->_has_parameters_to_get_validated) {
        my $parameters_to_get_validated = Load($monkeyman->_get_parameters_to_get_validated);
        while(my($parameter_keys, $parameter_name) = each(%{ $parameters_to_get_validated })) {
            push(@parameter_keys_defined, ($parameter_keys =~ /(?:\|?([a-zA-Z]+)(?:=.+)?)/g));
            push(@parameter_names_defined, $parameter_name);
            warn("$parameter_keys, $parameter_name, " . (keys(%{$parameter_name}))[0]);
            $monkeyman->_get_parameters_to_get->{ $parameter_keys } =
                (keys(%{$parameter_name}))[0];
        }
    }

    # Adding common parameters handling instructions,
    # making sure they aren't overriding any settings discovered previously
    my %default_parameters = (
        'h|help'                => 'mm_show_help',
        'V|version'             => 'mm_show_version',
        'c|configuration=s'     => 'mm_configuration',
        'default-cloudstack=s'  => 'mm_default_cloudstack',
        'default-logger=s'      => 'mm_default_logger',
        'v|verbose+'            => 'mm_be_verbose',
        'q|quiet+'              => 'mm_be_quiet'
    );
    while(my($reserved_parameters_group, $reserved_attribute) = each(%default_parameters)) {
        foreach my $forbidden_attribute (grep({ $reserved_attribute eq $_ } @parameter_names_defined)) {
            (__PACKAGE__ . '::Exception::ParameterKeyReserved')->throwf(
                "The %s command-line parameter attribute name is reserved, " .
                "you shouldn't have tried to use it",
                $forbidden_attribute
            );
        }
        foreach my $reserved_parameter ($reserved_parameters_group =~ /(?:\|?([a-zA-Z]+)(?:=.+)?)/g) {
            foreach my $forbidden_parameter (grep({ $reserved_parameter eq $_ } @parameter_keys_defined)) {
                (__PACKAGE__ . '::Exception::ParameterKeyReserved')->throwf(
                    "The %s command-line parameter key is reserved, " .
                    "you shouldn't have tried to use it",
                    $forbidden_parameter
                );
            }
        }
        $monkeyman->_get_parameters_to_get->{$reserved_parameters_group} = $reserved_attribute;
    }

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



#method check_loneliness(Bool :$fatal, ArrayRef[Str] :$attributes_alone) {
#
#    my $monkeyman                   = $self->get_monkeyman;
#    my $logger                      = $monkeyman->get_logger;
#    my %parameters_by_definitions   = %{ $self->get_monkeyman->_get_parameters_to_get };
#    my %parameters_by_attributes    = reverse(%parameters_by_definitions);
#    my @result;
#
#    # Firstly, let's see what parameters have been given
#
#    foreach my $leave_me_alone (@{ $attributes_alone }) {
#        my $reader  = 'get_' . $leave_me_alone;
#        my $value   = $self->$reader;
#        if(defined($value)) {
#            push(@result, {
#                attribute   => $leave_me_alone,
#                definition  => $parameters_by_attributes{$leave_me_alone},
#                value       => $value
#            });
#        }
#    }
#
#    # If there are more than one parameters, we should take some measures
#
#    if(@result > 1) {
#        my @superflous_parameters;
#        for my $i (2..@result) {
#            push(@superflous_parameters, $result[$i-1]->{'attribute'});
#            $logger->warnf(
#                "The %s parameter (defined as '%s') is already given, so " .
#                "the %s parameter (defined as '%s') is superflous",
#                $result[0]   ->{'attribute'}, $result[0]   ->{'definition'},
#                $result[$i-1]->{'attribute'}, $result[$i-1]->{'definition'}
#            );
#        }
#        if($fatal) {
#            (__PACKAGE__ . '::Exception::SuperflousParametersGiven')->throwf(
#                "Superflous parameter(s) found (%s), " .
#                "which is considered as fatal for this application",
#                join(', ', @superflous_parameters)
#            );
#        }
#    }
#
#}



#__PACKAGE__->meta->make_immutable;

1;
