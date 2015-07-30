package MonkeyMan::CloudStack::Elements::Host;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;

# Use 3rd-party libraries
use experimental qw(switch);

# Use Moose :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('host');
}



sub _load_full_list_command {
    return({
        command => 'listHosts',
        listall => 'true'
    });
}



sub _load_dom_xpath_query {

    my($self, %parameters) = @_;

    MonkeyMan::Exception->throw("Required parameters haven't been defined")
        unless(%parameters);

    if($parameters{'attribute'} eq 'FINAL') {
        return("/listhostsresponse/host");
    } else {
        return("/listhostsresponse/host[" .
            $parameters{'attribute'} . "='" .
            $parameters{'value'} . "']"
        );
    }

}



sub _get_parameter_xpath_query {

    my($self, $parameter) = @_;

    MonkeyMan::Exception->throw("The required parameter hasn't been defined")
        unless(defined($parameter));

    return("/host/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    MonkeyMan::Exception->throw("The key element hasn't been defined")
        unless(defined($key_element));

    given($key_element->element_type) {
        when('virtualmachine') {
            return(      "" => "")
                unless(defined($key_element->get_parameter('hostid')));
            return(      id => $key_element->get_parameter('hostid'));
        } default {
            return(
                $key_element->element_type . "id" => $key_element->get_parameter('id')
            );
        }
    }

}



__PACKAGE__->meta->make_immutable;

1;

