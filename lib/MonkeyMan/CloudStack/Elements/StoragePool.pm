package MonkeyMan::CloudStack::Elements::StoragePool;

use strict;
use warnings;
use feature "switch";

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('storagepool');
}



sub _load_full_list_command {
    return({
        command => 'listStoragePools',
        listall => 'true'
    });
}



sub _load_dom_xpath_query {

    my($self, %parameters) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%parameters);

    if($parameters{'attribute'} eq 'FINAL') {
        return("/liststoragepoolsresponse/storagepool");
    } else {
        return("/liststoragepoolsresponse/storagepool[" .
            $parameters{'attribute'} . "='" .
            $parameters{'value'} . "']"
        );
    }

}



sub _get_parameter_xpath_query {

    my($self, $parameter) = @_;

    return($self->error("The required parameter hasn't been defined"))
        unless(defined($parameter));

    return("/storagepool/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    return($self->error("The key element hasn't been defined"))
        unless(defined($key_element));

    given($key_element->element_type) {
        when('volume') {
            return(      "" => "")
                unless(defined($key_element->get_parameter('storage')));
            return(    name => $key_element->get_parameter('storage'));
        } default {
            return(
                $key_element->element_type . "id" => $key_element->get_parameter('id')
            );
        }
    }

}



__PACKAGE__->meta->make_immutable;

1;

