package MonkeyMan::CloudStack::Elements::Snapshot;

use strict;
use warnings;
use feature "switch";

use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::Elements::AsyncJob;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('snapshot');
}



sub _load_full_list_command {
    return({
        command => 'listSnapshots',
        listall => 'true'
    });
}



sub _load_dom_xpath_query {

    my($self, %parameters) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%parameters);

    if($parameters{'attribute'} eq 'FINAL') {
        return("/listsnapshotsresponse/snapshot");
    } else {
        return("/listsnapshotsresponse/snapshot[" .
            $parameters{'attribute'} . "='" .
            $parameters{'value'} . "']"
        );
    }

}



sub _get_parameter_xpath_query {

    my($self, $parameter) = @_;

    return($self->error("The required parameter hasn't been defined"))
        unless(defined($parameter));

    return("/snapshot/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    return($self->error("The key element hasn't been defined"))
        unless(defined($key_element));

    given($key_element->element_type) {
        default {
            return(
                $key_element->element_type . "id" => $key_element->get_parameter('id')
            );
        }
    }

}



sub delete {

    my $self = shift;
    my($cs, $log);

    eval { mm_method_checks(
        'object' => $self,
        'checks' => {
            'cs'    => { variable => \$cs },
            'log'   => { variable => \$log }
        }
    ); };
    return($self->error($@))
        if($@);

    my $job = eval {
        MonkeyMan::CloudStack::Elements::AsyncJob->new(
            cs  => $cs,
            run => {
                parameters  => {
                    command     => 'deleteSnapshot',
                    id          => $self->get_parameter('id')
                }
            }
        );
    };
    return($self->error(mm_sprintify("Can't MonkeyMan::CloudStack::Elements::AsyncJob->new(): %s", $@)))
        if($@);

    return($job);

}



__PACKAGE__->meta->make_immutable;

1;

