package MonkeyMan::CloudStack::Elements::Snapshot;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::Elements::AsyncJob;

# Use 3rd-party libraries
use experimental qw(switch);

# Use Moose :)
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

    MonkeyMan::Exception->throw("Required parameters haven't been defined")
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

    MonkeyMan::Exception->throw("The required parameter hasn't been defined")
        unless(defined($parameter));

    return("/snapshot/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    MonkeyMan::Exception->throw("The key element hasn't been defined")
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

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'cs'    => { variable => \$cs },
                'log'   => { variable => \$log }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    my $job;

    try {
        $job = MonkeyMan::CloudStack::Elements::AsyncJob->new(
            cs  => $cs,
            run => {
                parameters  => {
                    command     => 'deleteSnapshot',
                    id          => $self->get_parameter('id')
                }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't MonkeyMan::CloudStack::Elements::AsyncJob->new(): %s", $e)
    }

    return($job);

}



__PACKAGE__->meta->make_immutable;

1;

