package MonkeyMan::Parameters;

=head1 NAME

MonkeyMan::Parameters - options passed to a MonkeyMan-driven application

=cut

use strict;
use warnings;

use MonkeyMan::Exception qw(
    ParameterKeyReserved
    ParameterNameReserved
    MultipleParameterNames
    NoParameterNames
    InvalidValidationRule
    ParameterValidationFailed
);

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Use 3rd-party libraries
use Method::Signatures;
use TryCatch;
use Getopt::Long;
use YAML::XS;



has 'parameters_reserved' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   =>   '_has_parameters_reserved',
    reader      =>   '_get_parameters_reserved',
    builder     => '_build_parameters_reserved',
    lazy        => 1
);

method _build_parameters_reserved {
    return({});
}

has 'parameters_to_get' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => '_has_parameters_to_get',
    reader      => '_get_parameters_to_get'
);

has 'parameters_to_get_validated' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   => '_has_parameters_to_get_validated',
    reader      => '_get_parameters_to_get_validated'
);

has '_parameters' => (
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

    $self->parse_everything(strict => 0);

}

method parse_everything(Bool :$strict? = 0) {

    my $parameters_got = $self->_get_parameters;

    # Getting lists of parameters' keys and attribute names defined by the
    # parameters_to_get attribute of MonkeyMan
    my @parameter_keys_defined;
    my @parameter_names_defined;
    if($self->_has_parameters_to_get) {
        while(
            my(
                $parameter_keys,
                $parameter_name
            ) = each(%{ $self->_get_parameters_to_get })
        ) {
            push(@parameter_keys_defined, ($parameter_keys =~ /(?:\|?([a-zA-Z\-]+)(?:=.+)?)/g));
            push(@parameter_names_defined, $parameter_name);
        }
    }

    # Parsing some YAML here, filling the HASH referenced by parameters_to_get,
    # overriding everything without any warnings as it's documented.
    my $parameters_to_get_validated;
    if($self->_has_parameters_to_get_validated) {
        $parameters_to_get_validated = Load($self->_get_parameters_to_get_validated);
        while(
            my(
                $parameter_keys,
                $parameter_name_hashref
            ) = each(%{ $parameters_to_get_validated })
        ) {
            my @parameter_names = (ref($parameter_name_hashref) eq 'HASH') ?
                (keys(%{ $parameter_name_hashref })) :
                ($parameter_name_hashref);
            if(@parameter_names > 1) {
                (__PACKAGE__ . '::Exception::MultipleParameterNames')->throwf(
                    "The %s command-line parameter key has multiple attribute names",
                    $parameter_keys
                );
            } elsif(@parameter_names < 1) {
                (__PACKAGE__ . '::Exception::NoParameterNames')->throwf(
                    "The %s command-line parameter key has no attribute names",
                    $parameter_keys
                );
            }
            my $parameter_name = shift(@parameter_names);
            push(@parameter_keys_defined, ($parameter_keys =~ /(?:\|?([a-zA-Z\-]+)(?:=.+)?)/g));
            push(@parameter_names_defined, $parameter_name);
            #warn("$parameter_keys, $parameter_name");
            $self->_get_parameters_to_get->{ $parameter_keys } = $parameter_name;
        }
    }

    $self->check_reserved(
        parameter_keys_defined  => \@parameter_keys_defined,
        parameter_names_defined => \@parameter_names_defined
    );

    # Parsing parameters
    my $yammer;
    my %parameters;
    while(
        my(
            $parameter_keys,
            $parameter_name
        ) = each(%{$self->_get_parameters_to_get})
    ) {
        $parameters{$parameter_keys} = \($parameters_got->{$parameter_name});
    }
    try {
        local $SIG{__WARN__} = sub { $yammer = shift; };
        GetOptions(%parameters);
    } catch($e) {
        $yammer = $e;
    }
    MonkeyMan::Exception->throwf("Can't get command-line parameters: %s", $yammer)
        if($yammer);

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
                    is          => 'ro',
                    lazy        => 0
                )
            )
        );

        $self->$writer($parameters_got->{$parameter_name})
            if(defined($parameters_got->{$parameter_name}));
    }

    # Validating all the parameters
    if(
        (!defined($parameters_got->{'mm_show_help'}))    &&
        (!defined($parameters_got->{'mm_show_version'})) &&
        ( defined($parameters_to_get_validated))
    ) {
        while(
            my(
                $parameter_keys,
                $parameter_name_hashref
            ) = each(%{ $parameters_to_get_validated })
        ) {
            next unless(ref($parameter_name_hashref) eq 'HASH');
            # We won't check how many parameter names there are, as we've done it previously
            my $parameter_name = (keys(%{ $parameter_name_hashref }))[0];
            my $validation_rules = $parameter_name_hashref->{ $parameter_name };
            foreach my $validation_rule (sort(keys(%{ $validation_rules }))) {
                my $validation_conditions_ref = $validation_rules->{ $validation_rule };
                try { 
                    $self->_validate_parameters(
                        parameters_got              => $parameters_got,
                        parameter_name              => $parameter_name,
                        validation_rule             => $validation_rule,
                        validation_conditions_ref   => $validation_conditions_ref
                    );
                } catch($e) {
                    (__PACKAGE__ . '::Exception::ParameterValidationFailed')->throwf(
                        'The %s command-line parameter validation failed: %s',
                        $parameter_name, $e
                    );
                }
            }
        }
    }

}



method _validate_parameters(
    HashRef     :$parameters_got!,
    Str         :$parameter_name!,
    Str         :$validation_rule!,
    Maybe[Ref]  :$validation_conditions_ref!
) {

    my @failure;
    my @validation_conditions = @{ $validation_conditions_ref };

    if(defined($parameters_got->{ $parameter_name })) {
        if($validation_rule =~ /^requires_each(\..+)?$/i) {
            @failure = qw();
            foreach my $validation_condition (@validation_conditions) {
                if(! defined($parameters_got->{ $validation_condition })) {
                    @failure = (
                        "The %s command-line parameter is required",
                        $validation_condition
                    );
                    last;
                }
            }
        } elsif($validation_rule =~ /^requires_any(\..+)?$/i) {
            @failure = (
                "One of the command-line parameters is required: %s" ,
                join(', ', @validation_conditions)
            );
            foreach my $validation_condition (@validation_conditions) {
                if(defined($parameters_got->{ $validation_condition })) {
                    @failure = qw();
                    last;
                }
            }
        } elsif($validation_rule =~ /^conflicts_each(\..+)?$/i) {
            @failure = (
                "The following command-line parameters set is conflicting: %s",
                join(', ', @validation_conditions)
            );
            foreach my $validation_condition (@validation_conditions) {
                if(! defined($parameters_got->{ $validation_condition })) {
                    @failure = qw();
                    last;
                }
            }
        } elsif($validation_rule =~ /^conflicts_any(\..+)?$/i) {
            @failure = qw();
            foreach my $validation_condition (@validation_conditions) {
                if(defined($parameters_got->{ $validation_condition })) {
                    @failure = (
                        "The %s command-line parameter is conflicting",
                        $validation_condition,
                    );
                    last;
                }
            }
       } elsif($validation_rule =~ /^matches_each$/i) {
            @failure = qw();
            foreach my $validation_condition (@validation_conditions) {
                if($parameters_got->{ $parameter_name } !~ m/$validation_condition/) {
                    @failure = (
                        "'%s' doesn't match qr/%s/",
                        $parameters_got->{ $parameter_name },
                        $validation_condition
                    );
                    last;
                }
            }
       } elsif($validation_rule =~ /^matches_any$/i) {
            @failure = (
                "'%s' didn't match any of the following regexp set: %s",
                $parameters_got->{ $parameter_name },
                join(', ', map {"qr/$_/"} @validation_conditions)
            );
            foreach my $validation_condition (@validation_conditions) {
                if($parameters_got->{ $parameter_name } =~ m/$validation_condition/) {
                    @failure = qw();
                    last;
                }
            }
    #   } elsif($validation_rule =~ /^mismatches_each$/i) { #TODO
    #   } elsif($validation_rule =~ /^mismatches_any$/i) {
        } else {
            @failure = (
                "The following validation rule is not recognized: %s",
                $validation_rule
            );
        }
    } elsif($validation_rule =~ /^requires_each(\..+)?$/i) {
        foreach my $validation_condition (@validation_conditions) {
            if(
                ($validation_condition eq $parameter_name) &&
                (! defined($parameters_got->{ $validation_condition }))
            ) {
                @failure = ('This command-line parameter is required');
                last;
            }
        }
    }

    if(@failure) {
        $failure[0] .= ' - the %s validation rule of the %s parameter failed';
        (__PACKAGE__ . '::Exception::ParameterValidationFailed')->throwf(
            @failure, $validation_rule, $parameter_name
        );
    }
    
}



method check_reserved(
    ArrayRef    :$parameter_keys_defined!,
    ArrayRef    :$parameter_names_defined!,
    Bool        :$fatal? = 1
) {
    # Adding common parameters handling instructions,
    # making sure they aren't overriding any settings discovered previously
    my %default_parameters = %{ $self->_get_parameters_reserved };
    foreach my $attribute ($self->meta->get_all_attributes) {
        $default_parameters{ $attribute->name =~ s/_/-/r } = $attribute->name;
    }
    my @forbidden_keys;
    my @forbidden_names;
    while(my($reserved_keys, $reserved_name) = each(%default_parameters)) {
        foreach my $reserved_key ($reserved_keys =~ /(?:\|?([a-zA-Z\-]+)(?:=.+)?)/g) {
            foreach my $forbidden_key (grep({ $reserved_key eq $_ } @{ $parameter_keys_defined })) {
                (__PACKAGE__ . '::Exception::ParameterKeyReserved')->throwf(
                    "The %s command-line parameter key is reserved, " .
                    "you shouldn't have tried to use it",
                    $forbidden_key
                ) if($fatal);
                push(@forbidden_keys, $forbidden_key);
            }
        }
        foreach my $forbidden_name (grep({ $reserved_name eq $_ } @{ $parameter_names_defined })) {
            (__PACKAGE__ . '::Exception::ParameterNameReserved')->throwf(
                "The %s command-line parameter attribute name is reserved, " .
                "you shouldn't have tried to use it",
                $forbidden_name
            ) if ($fatal);
            push(@forbidden_names, $forbidden_name);
        }
        $self->_get_parameters_to_get->{$reserved_keys} = $reserved_name;
    }
    return(\@forbidden_keys, \@forbidden_names);
}


#__PACKAGE__->meta->make_immutable;

1;
