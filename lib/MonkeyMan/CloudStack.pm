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

method find_all_objects (
    MonkeyMan::Logger           :$logger?           = $self->_get_logger,
    MonkeyMan::CloudStack::API  :$api?              = $self->get_api,
    MonkeyMan::Parameters       :$parameters!,
    HashRef                     :$what_is_what!,
    HashRef                     :$who_is_who!
) {

    foreach my $huerga_name (
        sort(
            {
                # We need to have it sorted, because certain parameters need some
                # other parameters to have been proceeded beforehand. For example,
                # the "account" parametr that is depentant on the "domain" one.
                $what_is_what->{$a}->{'number'} <=> $what_is_what->{$b}->{'number'}
            }
            keys(%{ $what_is_what })
        )
    ) {

        # We've got the key, now let's get the value...
        my $huerga_configuration = $what_is_what->{$huerga_name};

        $logger->tracef(
            "Selecting the %s desired (as defined in %s)",
            $huerga_name,
            $huerga_configuration
        );

        # Later we'll need to know what exactly search criterions had been really set
        my %huerga_desired;

        # Now let's define the hash that will be passed to the perform_action() method,
        # it shall contain all the search criterions for the huerga we proceed.
        my %action_parameters = ref($huerga_configuration->{'parameters_fixed'}) eq 'HASH' ?
            (%{ $huerga_configuration->{'parameters_fixed'} }) :
            ();

        # Is this huerga choosen by the operator?
        my $huerga_choosen = 0;
        # What variable parameters do we have for this huerga?
        foreach my $action_parameter_name (keys(%{ $huerga_configuration->{'parameters_variable'} })) {

            # The value will be needed later
            my $action_parameter_configuration = $huerga_configuration->{'parameters_variable'}->{$action_parameter_name};

            my $source;
            my $value;
            if(($source = $action_parameter_configuration->{'from_results'}) && defined($source)) {
                # The parameter's value needs to be fetched from the results that have been already got
                $value = $who_is_who->{ $source };
            } elsif(($source = $action_parameter_configuration->{'from_parameters'}) && defined($source)) {
                # The parameter's value needs to be fetched from the command-line paramters
                my $predicate = 'has_' . $source;
                my $reader    = 'get_' . $source;
                if($parameters->$predicate) {
                    $value = $parameters->$reader;
                    $huerga_choosen++; # This huerga has been choosen by the operator!
                }
            }
            if(defined($value)) {
                if(ref($value) eq 'ARRAY') {
                    $huerga_desired{$action_parameter_name} = $value;
                } else {
                    $huerga_desired{$action_parameter_name} = [ $value ];
                }
            }
        }

        $logger->tracef(
            "We're ready to perform list-getting actions to find the following element(s): %s",
            \%huerga_desired
        );

        if(
            # So, have we got any command-line parameters about this huerga?
            ($huerga_choosen) ||
            # Or shall it be proceeded even without the command-line parameters given?
            ($huerga_configuration->{'forced'})
        ) {

            my @action_parameters_sets = ();

            # It's a recursive subroutine that is generating all possible combinations of the parameters.
            _generate_parameters(
                parameters_input    => \%huerga_desired,
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
                my @huerga_found = $api->perform_action(
                    type        => $huerga_configuration->{'type'},
                    action      => 'list',
                    parameters  => { %action_parameters, %{ $action_parameters_set } },
                    requested   => { element => 'element' }
                );

                # How much huerga have we found?
                if(@huerga_found < 1) {
                    # Too little (less than 1 element)
                    (__PACKAGE__ . '::Exception::ParameterIsNotFound')->throwf(
                        "The %s desired (%s) has not been found",
                        $huerga_name, join(', ', map({ sprintf("%s: %s", $_, join('/', @{ $huerga_desired{$_} }))} keys(%huerga_desired)))
                    );
                } elsif(@huerga_found > 1) {
                    # Too much (more than 1 element)
                    (__PACKAGE__ . '::Exception::ParameterIsNotFound')->throwf(
                        "Too many %s have been found, their IDs are: %s",
                        PL($huerga_name), join(', ', map({ $_->get_id } @huerga_found))
                    );
                } else {
                    # Perfect! :)
                    my $huerga_selected = $huerga_found[0];
                    $logger->debugf(
                        "The %s %s has been found, its ID is: %s",
                        $huerga_selected,
                        $huerga_name,
                        $huerga_selected->get_id
                    );
                    foreach my $who_is_who_parameter (keys(%{ $huerga_configuration->{'results'} })) {
                        if(defined(my $query = $huerga_configuration->{'results'}->{$who_is_who_parameter}->{'query'})) {
                            my @results = $huerga_selected->qxp(
                                query       => $query,
                                return_as   => 'value'
                            );
                            if(@results < 1) {
                                (__PACKAGE__ . '::Exception::ParameterIsNotFound')->throwf("Expected a result, have got none");
                            } elsif(@results > 1) {
                                (__PACKAGE__ . '::Exception::ParameterIsNotFound')->throwf("Expected a result, have got too many");
                            } else {
                                if(defined($huerga_configuration->{'ref'}) && $huerga_configuration->{'ref'} eq 'ARRAY') {
                                    # If we need to get multiple elements, we'll put it
                                    # to an array referenced from the $who_is_who hash
                                    unless(defined($who_is_who->{$who_is_who_parameter})) {
                                        # If it hasn't been initialized yet
                                        $who_is_who->{$who_is_who_parameter} = [ $results[0] ];
                                    } else {
                                        # Otherwise, we'll push the new element
                                        push(@{ $who_is_who->{$who_is_who_parameter} }, $results[0]);
                                    }
                                } else {
                                    # If we need to get only one element, we'll simply put it
                                    # to the $who_is_who hash as a scalar value
                                    $who_is_who->{$who_is_who_parameter} = $results[0];
                                }
                            }
                        }
                    }
                }

            }

        } elsif($huerga_configuration->{'mandatory'}) {
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
