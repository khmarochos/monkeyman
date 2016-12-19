package MonkeyMan::CloudStack;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

use MonkeyMan::Exception qw(ParameterIsNotSet ParameterIsNotFound);
use MonkeyMan::CloudStack::API;
use MonkeyMan::Logger;

use Method::Signatures;

our $VERSION = $MonkeyMan::VERSION;




has 'configuration' => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>   '_has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {
    return({});
}

has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      =>   '_get_logger',
    writer      =>   '_set_logger',
    predicate   =>   '_has_logger',
    builder     => '_build_logger',
    lazy        => 1
);

method _build_logger {
    return(MonkeyMan::Logger->instance);
}

has 'api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      =>    'get_api',
    writer      =>   '_set_api',
    predicate   =>   '_has_api',
    builder     => '_build_api',
    lazy        => 1
);

method _build_api {
    return(
        MonkeyMan::CloudStack::API->new(
            cloudstack      => $self,
            configuration   => $self->get_configuration->{'api'}
        )
    );
}



# This is a recursively-called function needed to generate all the possible
# combinations of parameters for each huerga. It's needed if the operator 
# selects multiple networks by their names or IDs, so we'll need to find them.

func _generate_parameters (
    HashRef     :$parameters_input!,    # Will get the parameters from there
    ArrayRef    :$parameters_output!,   # Will put the results here
    HashRef     :$state = {},           # A temporary storage
    Int         :$depth = 0             # A temporary depthometer
) {
    my @parameters_names = sort(keys(%{ $parameters_input }));
    my $current_parameter_name = $parameters_names[$depth];
    foreach my $current_parameter_value (@{ $parameters_input->{$current_parameter_name} }) {
        $state->{$current_parameter_name} = $current_parameter_value;
        if($depth < @parameters_names - 1) {
            _generate_parameters(
                parameters_input    => $parameters_input,
                parameters_output   => $parameters_output,
                state               => $state,
                depth               => $depth + 1
            );
        } else {
            push(@{ $parameters_output }, { %{ $state } });
        }
    }
}

method find_all_elements (
    MonkeyMan::Logger           :$logger?           = $self->_get_logger,
    MonkeyMan::CloudStack::API  :$api?              = $self->get_api,
    MonkeyMan::Parameters       :$parameters!,
    HashRef                     :$elements_catalog!,
    HashRef                     :$elements_recognized!
) {

    foreach my $element_name (
        sort(
            {
                # We need to have it sorted, because certain parameters need some
                # other parameters to have been proceeded beforehand. For example,
                # the "account" parametr that is depentant on the "domain" one.
                $elements_catalog->{$a}->{'number'} <=> $elements_catalog->{$b}->{'number'}
            }
            keys(%{ $elements_catalog })
        )
    ) {

        # We've got the key, now let's get the value...
        my $element_configuration = $elements_catalog->{$element_name};

        $logger->tracef(
            "Selecting the %s desired (as defined in %s)",
            $element_name,
            $element_configuration
        );

        # Later we'll need to know what exactly search criterions had been really set
        my %element_desired;

        # Now let's define the hash that will be passed to the perform_action() method,
        # it shall contain all the search criterions for the element we proceed.
        my %action_parameters = ref($element_configuration->{'parameters_fixed'}) eq 'HASH' ?
            (%{ $element_configuration->{'parameters_fixed'} }) :
            ();

        # Is this element choosen by the operator?
        my $element_choosen = 0;
        # What variable parameters do we have for this element?
        foreach my $action_parameter_name (keys(%{ $element_configuration->{'parameters_variable'} })) {

            # The value will be needed later
            my $action_parameter_configuration = $element_configuration->{'parameters_variable'}->{$action_parameter_name};

            my $source;
            my $value;
            if(($source = $action_parameter_configuration->{'from_results'}) && defined($source)) {
                # The parameter's value needs to be fetched from the results that have been already got
                $value = $elements_recognized->{ $source };
            } elsif(($source = $action_parameter_configuration->{'from_parameters'}) && defined($source)) {
                # The parameter's value needs to be fetched from the command-line paramters
                my $predicate = 'has_' . $source;
                my $reader    = 'get_' . $source;
                if($parameters->$predicate) {
                    $value = $parameters->$reader;
                    $element_choosen++; # This element has been choosen by the operator!
                }
            }
            if(defined($value)) {
                if(ref($value) eq 'ARRAY') {
                    $element_desired{$action_parameter_name} = $value;
                } else {
                    $element_desired{$action_parameter_name} = [ $value ];
                }
            }
        }

        $logger->tracef(
            "We're ready to perform the list-getting actions to find the following element(s): %s",
            \%element_desired
        );

        if(
            # So, have we got any command-line parameters about this element?
            ($element_choosen) ||
            # Or shall it be proceeded even without the command-line parameters given?
            ($element_configuration->{'forced'})
        ) {

            my @action_parameters_sets = ();

            # It's a recursive subroutine that is generating all possible combinations of the parameters.
            _generate_parameters(
                parameters_input    => \%element_desired,
                parameters_output   => \@action_parameters_sets
            );

            $logger->tracef(
                "The following list of parameters' sets are needed to be proceeded: %s",
                \@action_parameters_sets
            );

            # There can be multiple parameters sets (for example, in the case when the operator defined multiple networks),
            # so we're going to fetch them all
            foreach my $action_parameters_set (@action_parameters_sets) {

                # OK, let's perform the action
                my @elements_found = $api->perform_action(
                    type        => $element_configuration->{'type'},
                    action      => 'list',
                    parameters  => { %action_parameters, %{ $action_parameters_set } },
                    requested   => { element => 'element' }
                );

                # How much element have we found?
                if(@elements_found < 1) {
                    # Too little (less than 1 element)
                    (__PACKAGE__ . '::Exception::ElementIsNotFound')->throwf(
                        "The %s desired (%s) has not been found",
                        $element_name, join(', ', map({ sprintf("%s: %s", $_, join('/', @{ $element_desired{$_} }))} keys(%element_desired)))
                    );
                } elsif(@elements_found > 1) {
                    # Too much (more than 1 element)
                    (__PACKAGE__ . '::Exception::ElementIsNotFound')->throwf(
                        "Too many %s have been found, their IDs are: %s",
                        PL($element_name), join(', ', map({ $_->get_id } @elements_found))
                    );
                } else {
                    # Perfect! :)
                    my $element_selected    = $elements_found[0];
                    my $element_selected_id = $element_selected->get_id;
                    $logger->debugf(
                        "The %s %s has been found, its ID is: %s",
                        $element_selected,
                        $element_name,
                        $element_selected_id
                    );
                    foreach my $elements_recognized_parameter (keys(%{ $element_configuration->{'results'} })) {

                        my $what_we_got;

                        if(defined(my $query = $element_configuration->{'results'}->{$elements_recognized_parameter}->{'query'})) {
                            my @results = $element_selected->qxp(
                                query       => $query,
                                return_as   => 'value'
                            );
                            if(@results < 1) {
                                (__PACKAGE__ . '::Exception::ElementIsNotFound')->throwf("Expected a result, have got none");
                            } elsif(@results > 1) {
                                (__PACKAGE__ . '::Exception::ElementIsNotFound')->throwf("Expected a result, have got too many");
                            } else {
                                $what_we_got = $results[0];
                            }
                        } else {
                            $what_we_got = $element_selected_id;
                        }

                        if(defined($element_configuration->{'ref'}) && $element_configuration->{'ref'} eq 'ARRAY') {
                            # If we need to get multiple elements, we'll put it
                            # to an array referenced from the $elements_recognized hash
                            unless(defined($elements_recognized->{$elements_recognized_parameter})) {
                                # If it hasn't been initialized yet
                                $elements_recognized->{$elements_recognized_parameter} = [ $what_we_got ];
                            } else {
                                # Otherwise, we'll push the new element
                                push(@{ $elements_recognized->{$elements_recognized_parameter} }, $what_we_got);
                            }
                        } else {
                            # If we need to get only one element, we'll simply put it
                            # to the $elements_recognized hash as a scalar value
                            $elements_recognized->{$elements_recognized_parameter} = $what_we_got;
                        }

                    }
                }

            }

        } elsif($element_configuration->{'mandatory'}) {
            (__PACKAGE__ . '::Exception::ParameterIsNotSet')->throwf("The %s (a required parameter) hasn't been choosen");
        }

    }

}



#has 'cache' => (
#    is          => 'ro',
#    isa         => 'MonkeyMan::CloudStack::Cache',
#    reater      => '_get_cache',
#    writer      => '_set_cache',
#    predicate   => '_has_cache',
#    builder     => '_build_cache',
#    lazy        => 1
#);



__PACKAGE__->meta->make_immutable;

1;
