package MonkeyMan::CloudStack::Elements::Domain;

use strict;
use warnings;

use MonkeyMan::Constants;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Elements::_common';



sub _load_full_list_command {
    return({
        command => 'listDomains',
        listall => 'true'
    });
}

sub _generate_xpath_query {
    my($self, $cond_parameter, $cond_value) = @_;

    return($self->error("The condition haven't been defined"))
        unless(defined($cond_parameter) && defined($cond_value));

    return("/listdomainsresponse/domain[$cond_parameter='$cond_value']");

}


__PACKAGE__->meta->make_immutable;

1;

