package MonkeyMan::CloudStack::Elements::_common;

use strict;
use warnings;

use MonkeyMan::Constants;

use Data::Dumper;

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
has 'dom' => (
    is          => 'ro',
    isa         => 'Object',
    predicate   => 'has_dom',
    reader      => 'dom',
    writer      => '_set_dom'
);



sub load_dom {
    
    my($self, %conditions) = @_;

    return($self->error("Searching conditions haven't been defined"))
        unless(%conditions);
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    return($self->error("The logger hasn't been initialized"))
        unless($self->mm->has_logger);
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($self->mm->has_cloudstack_api);

    my $mm  = $self->mm;
    my $log = $mm->logger;
    my $api = $mm->cloudstack_api;

    $log->trace(
        "Have got a request for a " . ref($self) .
        ", it shall match following conditions: " . Dumper(\%conditions)
    );

    # Load the full list of elements

    my $dom_unfiltered = $api->run_command(
        # FIXME: it's quite dangerous to pass all parameters without any
        # security checks, so I should consider adding a couple of them here...
        parameters => $self->_load_full_list_command
    );
    return($self->error($api->error_message)) unless(defined($dom_unfiltered));

    # Apply filters, checking for matching conditions

    my $results_got;            # the counter of results
    my $dom_filtered;           # results are to be stored here

    # The last quasi-condition must be called "RESULT"!
    foreach my $condition (keys(%conditions), 'RESULT') {

        # Zeroize the counter of last pass' results

        $results_got = 0;

        # Create a new DOM for storing results

        $dom_filtered = eval { XML::LibXML::Document->createDocument("1.0", "UTF-8"); };
        return($self->error("Can't XML::LibXML::Document::createDocument(): $@")) if($@);

        # Do we have the XPath-query for that condition?

        my $xpath_query = $self->_generate_xpath_query(
            find    => {
                attribute   => $condition,
                value       => $conditions{$condition}
            }
        );
        return($self->error($self->error_message))
            unless(defined($xpath_query));

        # Okay, let's apply the filter

        my $results = $api->query_xpath($dom_unfiltered, $xpath_query);
        return($self->error($api->error_message))
            unless(defined($results));

        # So, how many results have we got? If there are no results, let's
        # return our empty DOM

        if(scalar(@{ $results }) < 1) {
            $log->trace(
                "Nothing matches the condition: " .
                "$condition eq $conditions{$condition}"
            );
            last;
        }

        # Building all required parents' nodes

        my @node_names = (split('/',
            ($condition ne 'RESULT') ?
                eval { ${$results}[0]->parentNode->nodePath; } :
                '/info'
        ));
        return($self->error("Can't XML::LibXML::Element::parentNode() or XML::LibXML::Element::nodePath(): $@")) if($@);

        my $node_to_add_children = $dom_filtered;

        foreach my $node_name (@node_names) {

            next unless ($node_name);

            my $node = eval { $dom_filtered->createElement($node_name); };
            return($self->error("Can't XML::LibXML::Document::createElement(): $@")) if($@);

            eval { $node_to_add_children->addChild($node); };
            return($self->error("Can't XML::LibXML::Document::addChild(): $@")) if($@);

            $node_to_add_children = $node;

        }

        # Okay, now let's attach nodes containing results to the main node

        my $child_last;

        foreach my $result (@{ $results }) {

            my $child_last = eval { $node_to_add_children->addChild($result); };
            return($self->error("Can't XML::LibXML::Node::addChild() $@")) if ($@);

            $results_got++;

        }

        $dom_unfiltered = $dom_filtered;

    }

    $self->logwarn("$results_got results have been returned, but I expected only one")
        if($results_got > 1);

    $self->_set_dom($dom_filtered);

    if($results_got) {
        $log->debug("$self element has been loaded, it's " . $self->dom);
        $log->trace(
            "Now we've got the following info about $self: " .
            $self->dom->toString(1)
        );
    } else {
        $log->debug("$self element hasn't been found");
    }

    return($results_got, $self->dom);

}



sub get_parameter {

    my($self, $parameter) = @_;

    return($self->error("Searching conditions haven't been defined"))
        unless(defined($parameter));
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    return($self->error("The logger hasn't been initialized"))
        unless($self->mm->has_logger);
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($self->mm->has_cloudstack_api);

    my $mm  = $self->mm;
    my $log = $mm->logger;
    my $api = $mm->cloudstack_api;

    $log->trace("Getting the parameter $parameter of $self");

    my $xpath_query = $self->_generate_xpath_query(
        get => $parameter
    );
    return($self->error($self->error_message))
        unless(defined($xpath_query));

    my $results = $api->query_xpath($self->dom, $xpath_query);
    return($self->error($api->error_message))
        unless(defined($results));

    my $results_got = scalar(@{ $results });

    $log->logwarn("$results results have been returned, but I expected only one")
        if($results_got > 1);
    $log->trace("The parameter haven't been got")
        if($results_got < 1);

    my $result = eval { $results_got ? ${ $results }[0]->textContent : undef; };
    return($self->error("Can't XML::LibXML::Element->textContent: $@")) if($@);

    return($results_got, $result);

}



1;

