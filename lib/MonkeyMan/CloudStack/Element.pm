package MonkeyMan::CloudStack::Element;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;
use MonkeyMan::Utils;

# Use 3rd-party libraries
use experimental qw(switch);

# Use Moose :)
use Moose::Role;
use namespace::autoclean;



has 'cs' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack',
    predicate   => 'has_cs',
    writer      => '_set_cs',
    required    => 'yes'
);
has 'init_load_dom' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => 'has_init_load_dom',
    init_arg    => 'load_dom',
    writer      => '_set_init_load_dom' # needed by preBUILDers
);
has 'dom' => (
    is          => 'ro',
    isa         => 'Object',
    predicate   => 'has_dom',
    reader      => 'dom',
    writer      => '_set_dom'
);



sub BUILD {

    my $self = shift;

    # Load information if it's neccessary
 
    if($self->has_init_load_dom) {
        my $result = $self->load_dom(%{$self->init_load_dom});
        given($result) {
            when(scalar(@{ $result }) < 1) { MonkeyMan::Exception->throw("The element hasn't been found") }
            when(scalar(@{ $result }) > 1) { MonkeyMan::Exception->throw("Too many elements have been found") }
        }
    }
    
}



sub own_method_checks {

    my($self, $check_key) = @_;

    given($check_key) {
        when('dom') { return($self->dom); }
        when('id')  { return($self->get_parameter('id')); }
        default {
            MonkeyMan::Exception::MethodInvocationCheck::CheckNotImplemented->
                throw_f("The %s parameter isn't implemeted to be checked", $check_key);
        }
    }

}



sub load_dom {
    
    my($self, %input) = @_;
    my($log, $api, $cache);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'       => { variable   => \$log },
                'cs_api'    => { variable   => \$api },
                'cs_cache'  => { variable   => \$cache, careless => 1 },
                '$input'    => { value      => \%input, error => "Required parameters haven't been defined" },
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    my $nodes = [];             # resulting nodes are to be stored here
    my $dom_unfiltered;         # the source DOM
    my $dom_filtered;           # the resulting DOM

    # Load the predetermined DOM (if given) or the full list of elements

    if(blessed($input{'dom'}) && $input{'dom'}->isa('XML::LibXML::Document')) {

        $log->debug(mm_sprintf("Loading %s with the predetermined DOM: %s", $self, $input{'dom'}));

        try {
            push(@{ $nodes }, eval { $input{'dom'}->documentElement });
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't %s->documentElement(): %s", $input{'dom'}, $e);
        }
    
    } else {

        my $cached = $cache->get_full_list($self->element_type);

        if(defined($cached)) {

            $dom_unfiltered = $cached->{'dom'};
            $log->trace(mm_sprintf(
                "The list of %ss has been loaded from the cache as %s",
                    $self->element_type,
                    $cached->{'dom'}
            ));

        } else {

            $dom_unfiltered = $api->run_command(
                # FIXME: it's quite dangerous to pass all parameters without any
                # security checks, so I should consider adding a couple of restrictions here...
                parameters => $self->_load_full_list_command
            );

            $cache->store_full_list($self->element_type, $dom_unfiltered, time);

            $log->trace(mm_sprintf(
                "The list of %ss has been stored in the cache as %s",
                    $self->element_type,
                    $cached->{'dom'}
            ));

        }

    }
    
    if(keys(%{ $input{'conditions'} })) {

        # If someone passed the empty string instead of a hash, it means they can't
        # calculate these conditions, so we shall point to an empty list

        if(defined($input{'conditions'}->{""})) {
            $log->debug("There are no defined conditions to find that object at the moment");
            return([]);
        }

        $log->debug(mm_sprintf(
            "Have got a request for a %s, it shall match following conditions: %s",
                $self->element_type,
                $input{'conditions'}
        ));


    }

    # Apply filters, checking for matching conditions

    foreach my $condition (keys(%{ $input{'conditions'} }), 'FINAL') {

        # Don't do anything if we already have some predetermined DOM

        last unless(keys(%{ $input{'conditions'} }));

        # Create a new DOM for storing resulting nodes

        try {
            $dom_filtered = XML::LibXML::Document->createDocument("1.0", "UTF-8");
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't XML::LibXML::Document->createDocument(): %s", $e);
        }

        # Do we have the XPath-query for that condition?

        my $xpath_query = $self->_load_dom_xpath_query(
            attribute   => $condition,
            value       => $input{'conditions'}->{$condition}
        );

        # Okay, let's apply the filter

        $nodes = $api->query_xpath($dom_unfiltered, $xpath_query);

        # So, how many nodes have we got? If there are no nodes, let's stop
        # working and return nothing.

        if(scalar(@{ $nodes }) < 1) {
            $log->trace(mm_sprintf(
                "Nothing matches the condition: %s == %s",
                    $condition,
                    $input{'conditions'}->{$condition}
            ));
            last;
        }

        # If it's not the last pass, prepare the new "unfiltered" DOM filled
        # with resulting nodes of this pass

        if($condition ne 'FINAL') {

            # Building all required parents' nodes
        
            my @node_names;
            try {
                @node_names = (split('/', ${ $nodes }[0]->parentNode->nodePath));
            } catch($e) {
                MonkeyMan::Exception->throw_f("Can't %s->parentNode()->nodePath(): %s", ${ $nodes }[0], $e);
            }

            my $node_to_add_children = $dom_filtered;

            foreach my $node_name (@node_names) {

                next unless ($node_name);

                my $node;

                try {
                    $node = $dom_filtered->createElement($node_name);
                } catch($e) {
                    MonkeyMan::Exception->throw_f("Can't %s->createElement(): %s", $dom_filtered, $e);
                }

                try {
                    $node_to_add_children->addChild($node);
                } catch($e) {
                    MonkeyMan::Exception->throw_f("Can't %s->addChild(): %s", $node_to_add_children, $e);
                }

                $node_to_add_children = $node;

            }

            # Okay, now let's attach resulting nodes to the main node

            foreach my $node (@{ $nodes }) {

                my $node_clone;
                
                try {
                    $node->cloneNode(1);
                } catch($e) {
                    MonkeyMan::Exception->throw_f("Can't %s->cloneNode(): %s", $node, $e);
                }

                try {
                    $node_to_add_children->addChild($node_clone);
                } catch($e) {
                    MonkeyMan::Exception->throw_f("Can't %s->addChild(): %s", $node_to_add_children, $e);
                }

            }

            try {
                $node_to_add_children->setAttribute("count", scalar(@{ $nodes }));
            } catch($e) {
                MonkeyMan::Exception->("Can't %s->setAttribute(): %s", $node_to_add_children, $e);
            }

            $dom_unfiltered = $dom_filtered;

        }

    }

    # Okay, what have we got?

    my @results;
    my $results_got = 0;

    foreach my $node (@{ $nodes }) {

        my $dom;
        
        try {
            $dom = XML::LibXML::Document->createDocument("1.0", "UTF-8");
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't XML::LibXML::Document->createDocument(): %s", $e);
        }

        my $node_clone;
        
        try {
            $node_clone = $node->cloneNode(1);
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't %s->cloneNode(): %s", $node, $e);
        }

        try {
            $dom->addChild($node_clone);
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't %s->addChild(): %s", $dom, $e);
        }

        push(@results, $dom);

        $results_got++;

    }

    $log->debug(mm_sprintf("%d got result(s) has/have been got", $results_got));

    if($results_got == 1) { $self->_set_dom($results[0]); }

    return(\@results);

}



sub get_parameter {

    my($self, $parameter) = @_;
    my($log, $api, $dom);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                'dom'           => { variable   => \$dom, careless => 1 },
                'cs_api'        => { variable   => \$api },
                '$parameter'    => { value      =>  $parameter }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    $log->trace(mm_sprintf("Looking up for the %s parameter of %s", $parameter, $self));

    my $xpath_query = $self->_get_parameter_xpath_query($parameter);

    my $results = $api->query_xpath($dom, $xpath_query);

    my $results_got = scalar(@{ $results });

    given($results_got) {
        when($_ < 1) { $log->trace("The requested parameter haven't been got") }
        when($_ > 1) { $log->warn(mm_sprintf("%d results have been got, but the caller is expecting for only one", $results_got)) }
    }

    my $result;

    try {
        $result = $results_got ? ${ $results }[0]->textContent : undef;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't %s->textContent(): %s", ${ $results }[0], $e);
    }

    return($result);

}



sub find_related_to_me {

    my($self, $what_to_find, $return_elements) = @_;
    my($log, $cs);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                'cs'            => { variable   => \$cs },
                '$what_to_find' => { value      =>  $what_to_find }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    $log->trace(mm_sprintf("Going to look for %ss related to %s", $what_to_find, $self));

    my $module_name = ${&MMElementsModule}{$what_to_find};
    MonkeyMan::Exception->throw_f("I'm not able to look for related %ss yet", $what_to_find)
        unless(defined($module_name));

    my $quasi_object;

    try {
        require "MonkeyMan/CloudStack/Elements/$module_name.pm";
        $quasi_object = "MonkeyMan::CloudStack::Elements::$module_name"->new(cs => $cs);
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't MonkeyMan::CloudStack::Elements::%s->new(): %s", $module_name, $e)
    }

    my $objects = $quasi_object->find_related_to_given($self);

    # Wrapping each element in an object of its type, if they're asking 'bout that

    if($return_elements) {
        for(my $i = 0; $i < @{ $objects }; $i++) {
            try {
                ${ $objects }[$i] = "MonkeyMan::CloudStack::Elements::$module_name"->new(
                    cs  => $cs,
                    dom => ${ $objects }[$i]
                );
            } catch($e) {
                MonkeyMan::Exception->throw_f("Can't MonkeyMan::CloudStack::Elements::%s->new(): %s", $module_name, $e);
            }
        }
    }

    return($objects);

}



sub find_related_to_given {

    my($self, $key_element) = @_;
    my($log, $dom);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                '$key_element'  => { value      =>  $key_element }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    try {
        mm_check_method_invocation(
            'object' => $key_element,
            'checks' => {
                'dom'           => { },
                'id'            => { }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    $log->trace(mm_sprintf("Looking for %ss related to %s", $self->element_type, $key_element));

    my $objects = $self->load_dom(
        conditions => { $self->_find_related_to_given_conditions($key_element) }
    );

    return($objects);

}



1;

