package MonkeyMan::CloudStack::Elements::Volume;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



sub element_type {
    return('volume');
}



sub _load_full_list_command {
    return({
        command => 'listVolumes',
        listall => 'true'
    });
}



sub _load_dom_xpath_query {

    my($self, %parameters) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%parameters);

    if($parameters{'attribute'} eq 'FINAL') {
        return("/listvolumesresponse/volume");
    } else {
        return("/listvolumesresponse/volume[" .
            $parameters{'attribute'} . "='" .
            $parameters{'value'} . "']"
        );
    }

}



sub _get_parameter_xpath_query {

    my($self, $parameter) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(defined($parameter));

    return("/volume/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    return($self->error("The key element hasn't been defined"))
        unless(defined($key_element));

    return(
        $key_element->element_type . "id" => $key_element->get_parameter('id')
    );

}



sub create_snapshot {

    my($self, %input) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%input);
    return($self->error("MonkeyMan hasn't been initialized"))
        unless($self->has_mm);
    my $mm  = $self->mm;
    return($self->error("CloudStack's API connector hasn't been initialized"))
        unless($mm->has_cloudstack_api);
    my $api     = $mm->cloudstack_api;
    my $cache   = $mm->cloudstack_cache
        if($mm->has_cloudstack_cache);
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };

    my $cmd_result = $api->run_command(
        parameters  => {
            command     => 'createSnapshot',
            volumeid    => $self->get_parameter('id')
        },
        wait    => $input{'wait'}
    );
    unless(defined($cmd_result)) {
        return($self->error($api->error_message));
    }

    if($input{'wait'}) {

        # ...

    } else {

        my $job_id_list = $api->query_xpath($cmd_result, '/createsnapshotresponse/jobid');
        return($self->error($api->error_message))
            unless(defined($job_id_list));

        my $job_id = eval { ${$job_id_list}[0]->textContent };
        return($self->error(mm_sprintify("Can't XML::LibXML::Element->textContent(): %s", $@)))
            if($@);

        return($job_id);

    }

}



__PACKAGE__->meta->make_immutable;

1;

