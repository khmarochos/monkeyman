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
    SplitBrain
);
use MonkeyMan::CloudStack::API::Request;
use MonkeyMan::Utils qw(mm_sprintf);

use Method::Signatures;
use Lingua::EN::Inflect qw(A);



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

#    $self->get_api->get_cloudstack->get_monkeyman->get_logger->debugf(
#        "!!! %s !!!", join('', @result)
#    #);

    return(join('', @result));

}



has 'vocabulary_tree' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_vocabulary_tree',
    writer      =>   '_set_vocabulary_tree',
    predicate   =>   '_has_vocabulary_tree',
    builder     => '_build_vocabulary_tree',
    lazy        => 1
);

method _build_vocabulary_tree {

    my $type        = $self->get_type;
    my $class_name  = $self->get_api->load_element_package($type);

    no strict 'refs';
    my $vocabulary_tree = \%{ '::' . $class_name . '::vocabulary_tree' };

    unless(defined($vocabulary_tree)) {
        (__PACKAGE__ . '::Exception::VocabularyIsMissing')->throwf(
            "The %s class' vocabulary tree is missing. " .
            "Sorry, but I can not use this class.",
            $class_name
        );
    }

    $self->check_vocabulary(vocabulary_tree => $vocabulary_tree, fatal => 1);

    return($vocabulary_tree);

}



method check_vocabulary(
    HashRef :$vocabulary_tree    = $self->get_vocabulary_tree,
    Bool    :$fatal              = 1
) {

    foreach my $words (
        [ qw(type) ],
        [ qw(name) ],
        [ qw(entity_node) ],
        [ qw(actions list request) ],
        [ qw(actions list response) ]
    ) {
        $self->get_api->get_cloudstack->get_monkeyman->get_logger->tracef(
            "Making sure if there is the %s word in the %s vocabulary tree",
            join(':', @{ $words }), $vocabulary_tree
        );
        unless(defined($self->vocabulary_lookup(
            words       => $words,
            tree        => $vocabulary_tree,
            fatal       => 0,
            resolve     => 0
        ))) {
            if($fatal) {
                (__PACKAGE__ . '::Exception::VocabularyIsIncomplete')->throwf(
                    "The %s vocabulary tree is missing the %s word." ,
                    $vocabulary_tree, join(':', @{ $words })
                );
            } else {
                return(0);
            }
        }
    }

    return(1);

}



method vocabulary_lookup(
    ArrayRef[Str]       :$words!,
    HashRef             :$tree?         = $self->get_vocabulary_tree,
    Maybe[Bool]         :$fatal         = 1,
    Maybe[HashRef]      :$macros,
    Bool                :$resolve       = 1
) {

    my $result;
    
    #my $logger = $self->get_api->get_cloudstack->get_monkeyman->get_logger;
    #$logger->tracef(
    #    "Looking for the %s word in the %s vocabulary tree",
    #    join(':', @{ $words }), $tree
    #);

    my @wordz = (@{ $words }); # Don't mess up with the original list!
    my $word0 = shift(@wordz);
    if(scalar(@wordz) > 0) {
        if(defined($tree->{ $word0 })) {
            $result = $self->vocabulary_lookup(
                words       => \@wordz,
                tree        => $tree->{ $word0 },
                fatal       => 0
            );
        }
    } else {
        $result = $tree->{ $word0 };
    }

    if($fatal && !defined($result)) {
        (__PACKAGE__ . '::Exception::WordIsMissing')->throwf(
            "The %s vocabulary is missing the %s word." ,
            $tree, join(':', @{ $words })
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



method compose_request(
    Str             :$action!,
    HashRef         :$parameters,
    Maybe[HashRef]  :$macros,
    Maybe[Bool]     :$return_as_hashref
) {

    my $r = {
        api         => $self->get_api,
        type        => $self->get_type,
        action      => $action,
        parameters  => $parameters,
        async       => undef,
        paged       => undef,
        filters     => [ ],
        macros      => $macros
    };

    my $macros_complete = { defined($macros) ? %{ $macros } : () };

    my $action_subtree = $self->vocabulary_lookup(
        words   => [ 'actions', $action ],
        fatal   => 1
    );
    my $request_subtree = $self->vocabulary_lookup(
        words   => [ 'request' ],
        fatal   => 1,
        tree    => $action_subtree
    );

    my $responde_node_name = $self->vocabulary_lookup(
        words   => [ qw(response response_node) ],
        fatal   => 1,
        tree    => $action_subtree
    );
    $macros_complete->{'OUR_RESPONSE_NODE'} = $responde_node_name;

    # Now let's make sure if all required action parameters have been defined
    while(my($parameter_name, $parameter_subtree) = each(%{
        $self->vocabulary_lookup(
            words   => [ qw(request parameters) ],
            fatal   => 1,
            tree    => $action_subtree
        )
    })) {
        if($self->vocabulary_lookup(
            words   => [ 'required' ],
            fatal   => 0,
            tree    => $parameter_subtree
        ) && !defined($parameters->{$parameter_name})) {
            (__PACKAGE__ . '::Exception::RequiredParameterIsUnset')->throwf(
                "The %s parameter is missing, it's required by the %s action",
                $parameter_name, $action
            )
        }
    }

    # Let's translate the method's parameters to the command's parameters
    my $command_parameters = { };

    foreach my $parameter (keys(%{ $parameters })) {

        $macros_complete->{'VALUE'} = $parameters->{$parameter};

        my $filters = $self->vocabulary_lookup(
            words   => [ 'request', 'parameters', $parameter, 'filters' ],
            fatal   => 0,
            tree    => $action_subtree
        );
        if(defined($filters) && ref($filters) eq 'ARRAY') {
            foreach my $filter (
                map { $self->resolve_macros(
                    source => $_,
                    macros => $macros_complete
                ) } (@{ $filters })
            ) {
                push(@{ $r->{'filters'} }, $filter);
            }
        }
        
        my $command_parameters_subtree = $self->vocabulary_lookup(
            words => [
                'request',  'parameters',
                $parameter, 'command_parameters'
            ],
            fatal   => 0,
            tree    => $action_subtree,
        );
        if(
            defined($command_parameters_subtree) &&
                ref($command_parameters_subtree) eq 'HASH'
        ) {
            while(
                my(
                    $command_parameter_name,
                    $command_parameter_value
                ) = map { $self->resolve_macros(
                    source => $_,
                    macros => $macros_complete
                ) } each(%{ $command_parameters_subtree })
            ) {
                $command_parameters->{$command_parameter_name} =
                $command_parameter_value;
            }
        }
    }

    $command_parameters->{'command'} = $self->vocabulary_lookup(
        words   => [ 'command' ],
        fatal   => 1,
        tree    => $request_subtree
    );

    $r->{'command'} = MonkeyMan::CloudStack::API::Command->new(
        api         => $self->get_api,
        parameters  => $command_parameters
    );

    $r->{'async'} = $self->vocabulary_lookup(
        words   => [ 'async' ],
        fatal   => 0,
        tree    => $request_subtree
    );
    $r->{'paged'} = $self->vocabulary_lookup(
        words   => [ 'paged' ],
        fatal   => 0,
        tree     => $request_subtree
    );

    $self->get_api->get_cloudstack->get_monkeyman->get_logger->tracef(
        "Composed the %s set of parameters", $r
    );

    return((defined($return_as_hashref) && $return_as_hashref) ?
        $r : MonkeyMan::CloudStack::API::Request->new($r)
    );

}



method apply_filters(
    XML::LibXML::Document                       :$dom!,
    Maybe[Str]                                  :$action,
    Maybe[HashRef]                              :$parameters,
    Maybe[ArrayRef[Str]]                        :$filters,
    Maybe[MonkeyMan::CloudStack::API::Request]  :$request,
    Maybe[HashRef]                              :$macros
) {

    my $logger = $self->get_api->get_cloudstack->get_monkeyman->get_logger;

    if(defined($request)) {

        $logger->warnf(
            "The %s request is given, though the %s action is given too",
            $request, $action
        ) if(defined($action));
        $action = $request->get_action;

        $logger->warnf(
            "The %s request is given, though the %s filters set is given too",
            $request, $action
        ) if(defined($filters));
        $filters = $request->get_filters;

    } elsif(defined($action) && defined($parameters)) {

        $logger->warnf(
            "The %s action is given, though the %s fitlers set is given too",
            $request, $action
        ) if(defined($filters));

        my $request = $self->compose_request(
            action              => $action,
            parameters          => $parameters,
            macros              => $macros,
            return_as_hashref   => 1
        );

        @{ $filters } = @{ $request->{'filters'} };

    }

    my $nodes_cloned = { };
    my $new_dom = $dom;
    foreach my $filter (@{ $filters }) {
        $logger->tracef("Applying the %s filter to the %s DOM", $filter, $new_dom);
        foreach my $node ($dom->findnodes($filter)) {
            $new_dom = $self->_import_node($nodes_cloned, $node, 1)->ownerDocument;
        }
    }
    return($new_dom);

}

method _import_node(
    HashRef           $nodes_cloned!,
    XML::LibXML::Node $node!,
    Bool              $last
) {

    #$self->get_api->get_cloudstack->get_monkeyman->get_logger->debugf(
    #    "Called to add the %s node, " .
    #    "the %s map contains the following elements: %s",
    #    $node, $nodes_cloned, join(', ',
    #        map { mm_sprintf("%s => %s", $_, $nodes_cloned->{$_}) }
    #            keys(%{ $nodes_cloned })
    #    )
    #);

    my $node_new;
    if(defined(my $parent_node = $node->parentNode)) {
        my $parent_node_key = $parent_node->unique_key;
        if(defined($nodes_cloned->{$parent_node_key})) {
            unless($nodes_cloned->{$parent_node_key}->isSameNode($parent_node)) {
                (__PACKAGE__ . '::Exception::SplitBrain')->throwf(
                    "The %s node and the %s one aren't the same " .
                    "as they're supposed to be",
                        $nodes_cloned->{$parent_node_key},
                                        $parent_node
                );
            }
            # If we already have the parent node cloned and mapped
            $node_new = $nodes_cloned->{$parent_node_key};
        } else {
            # If we don't have the parent node cloned and mapped yet
            $node_new = $self->_import_node($nodes_cloned, $parent_node, 0);
        }
        $node_new = $node_new->addChild($node->cloneNode($last ? 1 : 0));
    } else {
        # If the node has no parents at all
        $node_new = $node->cloneNode($last ? 1 : 0);
    }
    $nodes_cloned->{$node->unique_key} = $node_new;

    return($node_new);

}



method interpret_response(
    XML::LibXML::Document       :$dom!,
    Maybe[Str]                  :$action,
    Maybe[HashRef]              :$macros,
    HashRef|ArrayRef[HashRef]   :$requested!
) {

    my $api     = $self->get_api;
    my $logger  = $api->get_cloudstack->get_monkeyman->get_logger;

    my @results;

    $action = ($self->recognize_response(dom => $dom))[1]
        unless(defined($action));

    $requested = [ $requested ]
        unless(ref($requested) eq 'ARRAY');

    my $action_subtree = $self->vocabulary_lookup(
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

        my $response_subtree = $self->vocabulary_lookup(
            words   => [ 'response' ],
            fatal   => 1,
            tree    => $action_subtree
        );
        my $responde_node_name = $self->vocabulary_lookup(
            words   => [ 'response_node' ],
            fatal   => 1,
            tree    => $response_subtree
        );

        my $macros_complete = { defined($macros) ? %{ $macros } : () };
        $macros_complete->{'OUR_RESPONSE_NODE'} = $responde_node_name;

        while(my($result, $return_as) = each(%{ $request })) {
            my $results_subtree = $self->vocabulary_lookup(
                words   => [ 'results', $result ],
                fatal   => 1,
                tree    => $response_subtree
            );
            unless(grep { $_ eq $return_as } (@{ $self->vocabulary_lookup(
                words   => [ 'return_as' ],
                fatal   => 1,
                tree    => $results_subtree
            ) })) {
                (__PACKAGE__ . '::Exception::ReturnAsDisallowed')->throwf(
                    "Can't return the %s result as %s from the %s vocabulary",
                    $result, A($return_as), $self
                );
            }
            foreach my $xpath (@{ $self->vocabulary_lookup(
                words   => [ 'queries' ],
                fatal   => 1,
                tree    => $results_subtree,
            ) }) {
                $xpath = $self->resolve_macros(
                    source  => $xpath,
                    macros  => $macros_complete
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
