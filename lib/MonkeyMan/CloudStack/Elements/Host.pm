package MonkeyMan::CloudStack::Elements::Host;

use strict;
use warnings;
use feature "switch";

use MonkeyMan::Constants;

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

    return($self->error("Required parameters haven't been defined"))
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

    return($self->error("The required parameter hasn't been defined"))
        unless(defined($parameter));

    return("/host/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    return($self->error("The key element hasn't been defined"))
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

