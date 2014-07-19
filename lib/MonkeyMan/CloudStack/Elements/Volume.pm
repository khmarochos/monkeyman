package MonkeyMan::CloudStack::Elements::Volume;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::Elements::AsyncJob;

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
    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__); };

    my $job = eval {
        MonkeyMan::CloudStack::Elements::AsyncJob->new(
            mm  => $mm,
            run => {
                parameters  => {
                    command     => 'createSnapshot',
                    volumeid    => $self->get_parameter('id')
                },
                wait    => $input{'wait'}
            }
        );
    };
    return($self->error(mm_sprintify("Can't MonkeyMan::CloudStack::Elements::AsyncJob->new(): %s", $@)))
        if($@);

    return($job);

}



__PACKAGE__->meta->make_immutable;

1;

