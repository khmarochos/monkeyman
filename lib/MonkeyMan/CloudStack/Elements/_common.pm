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

    my $dom = $api->run_command(parameters => $self->_load_full_list_command);
    return($self->error($api->error_message)) unless(defined($dom));

    # Apply filters, checking for matching conditions

    my $results_got;
    my $resulting_dom;
    my $resulting_node;

    foreach my $condition (keys(%conditions), 'RESULT') {

        $results_got = 0;

        # Do we have an XPath-query for that condition?

        my $xpath_query = $self->_generate_xpath_query(
            find    => {
                attribute   => $condition,
                value       => $conditions{$condition}
            }
        );
        return($self->error($self->error_message))
            unless(defined($xpath_query));

        # Okay, let's apply the filter

        my $results = $api->query_xpath(defined($resulting_dom) ? $resulting_dom : $dom, $xpath_query);
        return($self->error($api->error_message))
            unless(defined($results));

        # Do we have a place to store results?

        unless(defined($resulting_dom)) {
            $resulting_dom = eval { XML::LibXML::Document->createDocument("1.0", "UTF-8"); };
            return($self->error("Can't XML::LibXML::Document::createDocument(): $@")) if($@);
            $resulting_node = $resulting_dom;
        }

        # How many results have we got?

        if(scalar(@{ $results }) < 1) {
            $log->trace(
                "Nothing matches the condition: " .
                "$condition eq $conditions{$condition}"
            );
            last;
        }

        # Here you are...

        if($condition ne 'RESULT') {

            my @node_names = split('/', eval { ${$results}[0]->parentNode->nodePath; });
            return($self->error("Can't XML::LibXML::Element::parentNode() or XML::LibXML::Element::nodePath(): $@")) if($@);

            foreach my $node_name (@node_names) {

                next unless ($node_name);

                my $node = eval { $resulting_dom->createElement($node_name); };
                return($self->error("Can't XML::LibXML::Document::createElement(): $@")) if($@);

                eval { $resulting_node->addChild($node); };
                return($self->error("Can't XML::LibXML::Document::addChild(): $@")) if($@);

                $resulting_node = $node;

            }

        }

        foreach my $result (@{ $results }) {

            my $child = eval { $resulting_node->addChild($result); };
            return($self->error("Can't XML::LibXML::Node::addChild() $@")) if ($@);

            $results_got++;

            if($condition eq 'RESULT') {
               $resulting_dom->setDocumentElement($child);
            }

        }

    }

    $self->logwarn("$results_got results have been returned, but I expected only one!")
        if($results_got > 1);

    $self->_set_dom($resulting_dom);

    if($results_got) {
        $log->debug("$self element has been loaded, it's " . $self->dom);
        $log->trace(
            "Now we've got the following info about $self: " .
            $self->dom->toString(1)
        );
    }

    return($resulting_dom);

}



1;

