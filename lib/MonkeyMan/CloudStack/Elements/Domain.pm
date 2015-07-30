package MonkeyMan::CloudStack::Elements::Domain;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;

# Use Moose :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('domain');
}



sub _load_full_list_command {
    return({
        command => 'listDomains',
        listall => 'true'
    });
}



sub _load_dom_xpath_query {

    my($self, %parameters) = @_;

    MonkeyMan::Exception->throw("Required parameters haven't been defined")
        unless(%parameters);

    if($parameters{'attribute'} eq 'FINAL') {
        return("/listdomainsresponse/domain");
    } else {
        return("/listdomainsresponse/domain[" .
            $parameters{'attribute'} . "='" .
            $parameters{'value'} . "']"
        );
    }

}



sub _get_parameter_xpath_query {

    my($self, $parameter) = @_;

    MonkeyMan::Exception->throw("The required parameter hasn't been defined")
        unless(defined($parameter));

    return("/domain/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    MonkeyMan::Exception->throw("The key element hasn't been defined")
        unless(defined($key_element));

    return(
        $key_element->element_type . "id" => $key_element->get_parameter('id')
    );

}



__PACKAGE__->meta->make_immutable;

1;

