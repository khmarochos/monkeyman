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
        ", it shall match following conditions: " . Dumper(%conditions)
    );

    my $dom = $api->run_command(parameters => $self->_load_full_list_command);
    return($self->error($api->error_message)) unless(defined($dom));

    $dom = eval { $dom->documentElement };
    return($self->error("Can't XML::LibXML::Node::child_nodes(): $@")) if($@);

    foreach my $condition (keys(%conditions)) {

        my $xpath_query = $self->_generate_xpath_query($condition, $conditions{$condition});
        return($self->error($self->error_message))
            unless(defined($xpath_query));

        my @results = $api->query_xpath($dom, $xpath_query);
        if(scalar(@results) < 1) {
            $log->warn(
                "Anything has matched the condition: " .
                "$condition eq $conditions{$condition}"
            );
            return(XML::LibXML::Document->new);
        } elsif(scalar(@results) > 1) {
            $log->warn(
                "Too many elements matches the condition: " .
                "$condition eq $conditions{$condition}"
            );
            return(XML::LibXML::Document->new);
        }

        $dom = $results[0];

    }

    $log->debug("$self element has been loaded from $dom");

    $log->trace(
        "Now we've got the following info about $self: " .
        $dom->toString(1)
    );

    return($dom);
}



1;

