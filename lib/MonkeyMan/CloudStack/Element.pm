package MonkeyMan::CloudStack::Element;

use strict;
use warnings;
use feature "switch";

use MonkeyMan::Constants;
use MonkeyMan::Utils;

use Moose::Role;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
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
            when(undef)                     { die($self->error_message) }
            when(scalar(@{ $result }) < 1)  { die("The element hasn't been found") }
            when(scalar(@{ $result }) > 1)  { die("Too many elements have been found") }
        }
    }
    
}



sub load_dom {
    
    my($self, %input) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%input);
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    my $mm  = $self->mm;
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($mm->has_cloudstack_api);
    my $api     = $mm->cloudstack_api;
    my $cache   = $mm->cloudstack_cache
        if($mm->has_cloudstack_cache);
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error(mm_sprintify("The logger hasn't been initialized: %s", $@)))
        if($@);


    my $nodes = [];             # resulting nodes are to be stored here
    my $dom_unfiltered;         # the source DOM
    my $dom_filtered;           # the resulting DOM

    # Load the predetermined DOM (if given) or the full list of elements

    if(ref($input{'dom'}) eq 'XML::LibXML::Document') {

        $log->debug(mm_sprintify("Loading %s with the predetermined DOM: %s", $self, $input{'dom'}));

        push(@{ $nodes }, eval { $input{'dom'}->documentElement });
        return($self->error(mm_sprintify("Can't %s->documentElement(): %s", $input{'dom'}, $@)))
            if($@);
    
    } else {

        my $cached = $cache->get_full_list($self->element_type);
        return($self->error($cache->error_message))
            if($cache->has_error);

        if(defined($cached)) {

            $dom_unfiltered = $cached->{'dom'};
            $log->trace(mm_sprintify(
                "The list of %ss has been loaded from the cache as %s",
                    $self->element_type,
                    $cached->{'dom'}
            ));

        } else {

            $dom_unfiltered = $api->run_command(
                # FIXME: it's quite dangerous to pass all parameters without any
                # security checks, so I should consider adding a couple of them here...
                parameters => $self->_load_full_list_command
            );
            return($self->error($api->error_message)) unless(defined($dom_unfiltered));

            my $cached = $cache->store_full_list($self->element_type, $dom_unfiltered, time);
            return($self->error($cache->error_message)) unless(defined($cached));

            $log->trace(mm_sprintify(
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

        $log->debug(mm_sprintify(
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

        $dom_filtered = eval { XML::LibXML::Document->createDocument("1.0", "UTF-8"); };
        return($self->error(mm_sprintify("Can't XML::LibXML::Document->createDocument(): %s" ,$@)))
            if($@);

        # Do we have the XPath-query for that condition?

        my $xpath_query = $self->_load_dom_xpath_query(
            attribute   => $condition,
            value       => $input{'conditions'}->{$condition}
        );
        return($self->error($self->error_message))
            unless(defined($xpath_query));

        # Okay, let's apply the filter

        $nodes = $api->query_xpath($dom_unfiltered, $xpath_query);
        return($self->error($api->error_message))
            unless(defined($nodes));

        # So, how many nodes have we got? If there are no nodes, let's stop
        # working and return nothing.

        if(scalar(@{ $nodes }) < 1) {
            $log->trace(mm_sprintify(
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
        
            my @node_names = (split('/', eval { ${ $nodes }[0]->parentNode->nodePath; }));
            return($self->error(mm_sprintify("Can't %s->parentNode()->nodePath(): %s", ${ $nodes }[0], $@)))
                if($@);

            my $node_to_add_children = $dom_filtered;

            foreach my $node_name (@node_names) {

                next unless ($node_name);

                my $node = eval { $dom_filtered->createElement($node_name); };
                return($self->error(mm_sprintify("Can't %s->createElement(): %s", $dom_filtered, $@)))
                    if($@);

                eval { $node_to_add_children->addChild($node); };
                return($self->error(mm_sprintify("Can't %s->addChild(): %s", $node_to_add_children, $@)))
                    if($@);

                $node_to_add_children = $node;

            }

            # Okay, now let's attach resulting nodes to the main node

            foreach my $node (@{ $nodes }) {

                my $node_clone = eval { $node->cloneNode(1); };
                return($self->error(mm_sprintify("Can't %s->cloneNode(): %s", $node, $@)))
                    if($@);

                eval { $node_to_add_children->addChild($node_clone); };
                return($self->error(mm_sprintify("Can't %s->addChild(): %s", $node_to_add_children, $@)))
                    if ($@);

            }

            eval { $node_to_add_children->setAttribute("count", scalar(@{ $nodes })); };
            return(self->error(mm_sprintify("Can't %s->setAttribute(): %s", $node_to_add_children, $@)))
                if($@);

            $dom_unfiltered = $dom_filtered;

        }

    }

    # Okay, what have we got?

    my @results;
    my $results_got = 0;

    foreach my $node (@{ $nodes }) {

        my $dom = eval { XML::LibXML::Document->createDocument("1.0", "UTF-8"); };
        return($self->error(mm_sprintify("Can't XML::LibXML::Document->createDocument(): %s", $@)))
            if($@);

        my $node_clone = eval { $node->cloneNode(1); };
        return($self->error(mm_sprintify("Can't %s->cloneNode(): %s", $node, $@)))
            if($@);

        eval { $dom->addChild($node_clone); };
        return($self->error(mm_sprintify("Can't %s->addChild(): %s", $dom, $@)))
            if($@);

        push(@results, $dom);

        $results_got++;

    }

    $log->debug(mm_sprintify("%d got result(s) has/have been got", $results_got));

    if($results_got == 1) { $self->_set_dom($results[0]); }

    return(\@results);

}



sub get_parameter {

    my($self, $parameter) = @_;

    return($self->error("The soaked parameter hasn't been defined"))
        unless(defined($parameter));
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    my $mm  = $self->mm;
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($self->mm->has_cloudstack_api);
    my $api = $mm->cloudstack_api;
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error(mm_sprintify("The logger hasn't been initialized: %s", $@)))
        if($@);

    $log->trace(mm_sprintify("Looking up for the %s parameter of %s", $parameter, $self));

    my $xpath_query = $self->_get_parameter_xpath_query($parameter);
    return($self->error($self->error_message))
        unless(defined($xpath_query));

    my $results = $api->query_xpath($self->dom, $xpath_query);
    return($self->error($api->error_message))
        unless(defined($results));

    my $results_got = scalar(@{ $results });

    given($results_got) {
        when($_ < 1) { $log->trace("The requested parameter haven't been got") }
        when($_ > 1) { $log->warn(mm_sprintify("%d results have been got, but the caller is expecting only 1, returning the first one", $results_got)) }
    }

    my $result = eval { $results_got ? ${ $results }[0]->textContent : undef; };
    return($self->error(mm_sprintify("Can't %s->textContent(): %s", ${ $results }[0], $@)))
        if($@);

    return($result);

}



sub find_related_to_me {

    my($self, $what_to_find, $return_elements) = @_;

    return($self->error("The type of soaked elements hasn't been defined"))
        unless(defined($what_to_find));
    return($self->error("The element's information haven't been loaded"))
        unless($self->has_dom);
    return($self->error($self->has_error) ? $self->error_message : "The ID of the element is unknown")
        unless($self->get_parameter('id'));
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    my $mm  = $self->mm;
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($self->mm->has_cloudstack_api);
    my $api = $mm->cloudstack_api;
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error(mm_sprintify("The logger hasn't been initialized: %s", $@)))
        if($@);

    $log->trace(mm_sprintify("Going to look for %ss related to %s", $what_to_find, $self));

    my $module_name = ${&MMElementsModule}{$what_to_find};
    return($self->error(mm_sprintify("I'm not able to look for related %ss yet", $what_to_find)))
        unless(defined($module_name));

    my $quasi_object = eval {
        require "MonkeyMan/CloudStack/Elements/$module_name.pm";
         return("MonkeyMan::CloudStack::Elements::$module_name"->new(mm => $mm));
    };
    return($self->error(mm_sprintify("Can't MonkeyMan::CloudStack::Elements::%s->new(): %s", $module_name, $@)))
        if($@);

    my $objects = $quasi_object->find_related_to_given($self);
    return($self->error($quasi_object->error_message)) unless(defined($objects));

    if($return_elements) {
        for(my $i = 0; $i < @{ $objects }; $i++) {
            ${ $objects }[$i] = eval {
                return("MonkeyMan::CloudStack::Elements::$module_name"->new(
                    mm  => $mm,
                    dom => ${ $objects }[$i]
                ));
            };
            return($self->error(mm_sprintify("Can't MonkeyMan::CloudStack::Elements::%s->new(): %s", $module_name, $@)))
                if($@);
        }
    }

    return($objects);

}



sub find_related_to_given {

    my($self, $key_element) = @_;

    return($self->error("The key element hasn't been defined"))
        unless(defined($key_element));
    return($self->error("The key element's information haven't been loaded"))
        unless($key_element->has_dom);
    return($self->error($self->has_error) ? $self->error_message : "The ID of the element is unknown")
        unless($key_element->get_parameter('id'));
    my $mm  = $self->mm;
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($self->mm->has_cloudstack_api);
    my $api = $mm->cloudstack_api;
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error(mm_sprintify("The logger hasn't been initialized: %s", $@)))
        if($@);

    $log->trace(mm_sprintify("Looking for %ss related to %s", $self->element_type, $key_element));

    my $objects = $self->load_dom(
        conditions => { $self->_find_related_to_given_conditions($key_element) }
    );
    return($self->error($self->error_message)) unless(defined($objects));
    return($objects);

}



1;

