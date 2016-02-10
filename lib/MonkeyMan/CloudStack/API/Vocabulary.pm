package MonkeyMan::CloudStack::API::Vocabulary;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Essentials';

use MonkeyMan::Exception qw(
    VocabularyIsMissing
    VocabularyIsIncomplete
    WordIsMissing
    MacrosIsUndefined
    RequiredParameterIsUnset
    UnknownResultRequested
    ReturnAsDisallowed
);

use Method::Signatures;



has 'type' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Types::ElementType',
    reader      =>  'get_type',
    writer      => '_set_type',
    required    => 1
);



has 'global_macros' => (
    isa         => 'HashRef',
    is          => 'ro',
    reader      =>    'get_global_macros',
    writer      =>   '_set_global_macros',
    builder     => '_build_global_macros',
    lazy        => 1
);

method _build_global_macros {
    return({
        OUR_NAME        => $self->vocabulary_lookup(
            words   => [ 'name' ],
            fatal   => 1,
            resolve => 0
        ),
        OUR_ENTITY_NODE => $self->vocabulary_lookup(
            words   => [ 'entity_node' ],
            fatal   => 1,
            resolve => 0
        )
    });
}



method resolve_macros(
    Str             :$source!,
    Maybe[HashRef]  :$macros,
    Bool            :$fatal = 1
) {

    my @result;

    my %macros_all = %{ $self->get_global_macros };
    if(defined($macros)) {
        while(my($macros_name, $macros_value) = each(%{ $macros })) {
            $macros_all{$macros_name} = $macros_value;
        }
    }

    while ($source =~ /^(.*)<%(.+)%>(.*)$/) {

        my($left, $middle, $right) = ($1, $2, $3);

        if(defined($right)) {
            unshift(@result, $right);
        }

        if(defined(my $new_value = $macros_all{$middle})) {
            unshift(@result, $new_value);
        } elsif($fatal) {
            (__PACKAGE__ . '::Exception::MacrosIsUndefined')->throwf(
                "Can't resolve the %s macros", $middle
            )
        }

        $source = $left;

    }

    unshift(@result, $source);

    return(join('', @result));

}



has 'vocabulary_data' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_vocabulary_data',
    writer      =>   '_set_vocabulary_data',
    predicate   =>   '_has_vocabulary_data',
    builder     => '_build_vocabulary_data',
    lazy        => 1
);

method _build_vocabulary_data {

    my $type        = $self->get_type;
    my $class_name  = $self->get_api->load_element_package($type);

    no strict 'refs';
    my $vocabulary_data = \%{ '::' . $class_name . '::vocabulary_data' };

    unless(defined($vocabulary_data)) {
        (__PACKAGE__ . '::Exception::VocabularyIsMissing')->throwf(
            "The %s class' vocabulary data is missing. " .
            "Sorry, but I can not use this class.",
            $class_name
        );
    }

    $self->check_vocabulary(vocabulary_data => $vocabulary_data, fatal => 1);

    return($vocabulary_data);

}



method check_vocabulary(
    HashRef :$vocabulary_data?   = $self->get_vocabulary_data,
    Bool    :$fatal              = 1
) {

    foreach my $words (
        [ qw(type) ],
        [ qw(name) ],
        [ qw(entity_node) ],
        [ qw(actions list request) ],
        [ qw(actions list response) ]
    ) {
        unless(defined($self->vocabulary_lookup(
            words       => $words,
            ref         => $vocabulary_data,
            fatal       => 0,
            resolve     => 0
        ))) {
            if($fatal) {
                (__PACKAGE__ . '::Exception::VocabularyIsIncomplete')->throwf(
                    "The %s class' vocabulary data is missing the %s word." ,
                    $self->get_api->translate_type(type => $self->get_type),
                    join(':', @{ $words })
                );
            } else {
                return(0)
            }
        }
    }

    return(1);

}



method vocabulary_lookup(
    ArrayRef[Str]       :$words!,
    HashRef             :$ref           = $self->get_vocabulary_data,
    Maybe[Bool]         :$fatal         = 1,
    Maybe[HashRef]      :$macros,
    Bool                :$resolve       = 1
) {

    my $result;
    
    # I hope, we'll never need it again!
    # $self->get_api->get_cloudstack->get_monkeyman->get_logger->tracef(
    #     "Looking for the %s word in the %s vocabulary",
    #     join(':', @{ $words }), $ref
    # );

    my @wordz = (@{ $words });
    my $word0 = shift(@wordz);
    if(scalar(@wordz) > 0) {
        if(defined($ref->{ $word0 })) {
            $result = $self->vocabulary_lookup(
                words       => \@wordz,
                ref         => $ref->{ $word0 },
                fatal       => 0
            );
        }
    } else {
        $result = $ref->{ $word0 };
    }

    if($fatal && !defined($result)) {
        (__PACKAGE__ . '::Exception::WordIsMissing')->throwf(
            "The %s vocabulary is missing the %s word." ,
            $ref, join(':', @{ $words })
        )
    }

    if($resolve && defined($result) && !ref($result)) {
        $result = $self->resolve_macros(
            source  => $result,
            macros  => $macros,
            fatal   => 1
        );
    }

    return($result);

}



method compose_command(
    Str             :$action!,
    HashRef         :$parameters
) {

    my $action_data = $self->vocabulary_lookup(
        words   => [ 'actions', $action ],
        fatal   => 1
    );

    my %command_parameters = (
        command => $self->vocabulary_lookup(
            words   => [ qw(request command) ],
            fatal   => 1,
            ref     => $action_data
        )
    );

    # Let's translate the method's parameters to the command's parameters

    foreach my $parameter (keys(%{ $parameters })) {

        my $parameter_data = $self->vocabulary_lookup(
            words   => [ 'request', 'parameters', $parameter ],
            fatal   => 1,
            ref     => $action_data
        );
        
        my $command_parameter_name = $self->vocabulary_lookup(
            words   => [ 'parameter_name' ],
            fatal   => 0,
            ref     => $parameter_data
        );
        $command_parameter_name = $parameter
            unless(defined($command_parameter_name));

        my $command_parameter_value = $self->vocabulary_lookup(
            words   => [ 'parameter_value' ],
            fatal   => 0,
            ref     => $parameter_data,
            macros  => { VALUE => $parameters->{$parameter} }
        );
        $command_parameter_value = $parameters->{$parameter}
            unless(defined($command_parameter_value));

        my $command_parameter_isa = $self->vocabulary_lookup(
            words   => [ 'isa' ],
            fatal   => 0,
            ref     => $parameter_data,
        );

        $command_parameters{$command_parameter_name} = $command_parameter_value;

    }

    # Now let's check if all required command parameters have been defined

    foreach my $parameter (keys(%{
        $self->vocabulary_lookup(
            words   => [ 'request', 'parameters' ],
            fatal   => 1,
            ref     => $action_data
        )
    })) {

        my $parameter_data = $self->vocabulary_lookup(
            words   => [ 'request', 'parameters', $parameter ],
            fatal   => 1,
            ref     => $action_data
        );
        
        my $command_parameter_required = $self->vocabulary_lookup(
            words   => [ 'required' ],
            fatal   => 0,
            ref     => $parameter_data,
        );
        next
            unless(
                defined($command_parameter_required) &&
                        $command_parameter_required
            );

        my $command_parameter_name = $self->vocabulary_lookup(
            words   => [ 'parameter_name' ],
            fatal   => 0,
            ref     => $parameter_data
        );
        $command_parameter_name = $parameter
            unless(defined($command_parameter_name));

        (__PACKAGE__ . '::Exception::RequiredParameterIsUnset')->throwf(
            "The %s parameter is required by the %s command, " .
            "but the corresponding parameter it isn't set for the %s action",
            $command_parameter_name,
            $command_parameters{'command'},
            $action
            
        )
            unless(defined($command_parameters{$command_parameter_name}));

    }

    return(MonkeyMan::CloudStack::API::Command->new(
        api         => $self->get_api,
        parameters  => \%command_parameters
    ));

}



method interpret_response(
    XML::LibXML::Document   :$dom!,
    Str                     :$action = ($self->recognize_response(dom => $dom))[1],
    ArrayRef[HashRef]       :$requested!
) {

    my $api     = $self->get_api;
    my $logger  = $api->get_cloudstack->get_monkeyman->get_logger;

    my @results;

    my $action_data = $self->vocabulary_lookup(
        words   => [ 'actions', $action ],
        fatal   => 1
    );

    foreach my $request (@{ $requested }) {

        my $result;
        my $return_as;
        while(each(%{ $request })) {
            if(defined($result)) {
                $logger->warnf(
                    "The %s (as %s) requisition is redundant, " .
                    "as %s (as %s) is already requested.",
                    $_[0], $_[1], $result, $return_as
                );
            } else {
                $result     = $_[0];
                $return_as  = $_[1];
            }
        }

        my $response_data = $self->vocabulary_lookup(
            words   => [ 'response' ],
            fatal   => 1,
            ref     => $action_data
        );
        my $responde_node_name = $self->vocabulary_lookup(
            words   => [ 'response_node' ],
            fatal   => 1,
            ref     => $response_data
        );

        while(my($result, $return_as) = each(%{ $request })) {
            my $results_data = $self->vocabulary_lookup(
                words   => [ 'results', $result ],
                fatal   => 1,
                ref     => $response_data
            );
            unless(grep { $_ eq $return_as } (@{ $self->vocabulary_lookup(
                words   => [ 'return_as' ],
                fatal   => 1,
                ref     => $results_data
            ) })) {
                (__PACKAGE__ . '::Exception::ReturnAsDisallowed')->throwf(
                    "Can't return %s as %s from the %s vocabulary",
                    $result, $return_as, $self
                );
            }
            foreach my $xpath (@{ $self->vocabulary_lookup(
                words   => [ 'xpaths' ],
                fatal   => 1,
                ref     => $results_data,
            ) }) {
                $xpath = $self->resolve_macros(
                    source  => $xpath,
                    macros  => { OUR_RESPONSE_NODE => $responde_node_name }
                );
                push(@results, $self->get_api->qxp(
                    dom         => $dom,
                    query       => $xpath,
                    return_as   => $return_as
                ));
            }
        }

#        (__PACKAGE__ . '::Exception::InvalidResultRequested')->throwf(
#            "The %s request is invalid, it doesn't contain "
#            "but the corresponding parameter it isn't set for the %s action",
#            unless(defined($result) && defined($return_as)) {
#        }
    }

    if(defined(wantarray) && ! wantarray) {
        if(@results > 1) {
            $logger->warnf(
                "The interpret_response() method is supposed to return " .
                "not a list, but a scalar value to the context it has been " .
                "called from, altough %d elements have been found (%s). " .
                "Returning the first one (%s) only.",
                scalar(@results), \@results, $results[0]
            );
        }
        return($results[0]);
    } else {
        return(@results);
    }

    return(@results);

}



method recognize_response (
    XML::LibXML::Document   :$dom!,
    Maybe[Bool]             :$fatal = 1
) {

    my @response_recognized = $self->get_api->recognize_response(
        dom         => $dom,
        vocabulary  => $self->get_type,
        fatal       => $fatal
    );

    if(scalar(@response_recognized)) {
        $self->get_api->get_cloudstack->get_monkeyman->get_logger->tracef(
            "The %s DOM has been recognized as the response to " .
            "the %s action of %s",
            $dom,
            $response_recognized[1],
            $self->get_api->translate_type(
                type    => $response_recognized[0],
                a       => 1
            )
        );
    }

    return(@response_recognized);

}

__PACKAGE__->meta->make_immutable;

1;
