package MonkeyMan::CloudStack::Elements::Volume;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::Elements::AsyncJob;

# Use Moose :)
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

    MonkeyMan::Exception->throw("Required parameters haven't been defined")
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

    MonkeyMan::Exception->throw("The required parameter hasn't been defined")
        unless(defined($parameter));

    return("/volume/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    MonkeyMan::Exception->throw("The key element hasn't been defined")
        unless(defined($key_element));

    return(
        $key_element->element_type . "id" => $key_element->get_parameter('id')
    );

}



sub create_snapshot {

    my($self, %input) = @_;
    my($log, $cs);

    MonkeyMan::Exception->throw("Required parameters haven't been defined")
        unless(%input);

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
                    command     => 'createSnapshot',
                    volumeid    => $self->get_parameter('id')
                },
                wait    => $input{'wait'}
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't MonkeyMan::CloudStack::Elements::AsyncJob->new(): %s", $e)
    }

    return($job);

}



sub cleanup_snapshots {

    my $self = shift;
    my($keep, $mm, $api, $log);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'       => { variable   => \$log },
                'cs_api'    => { variable   => \$api },
                '$keep'     => {
                                 variable   => \$keep,
                                 value      => shift
                }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    $log->trace(mm_sprintf(
        "Going to cleanup old snapshots for the %s volume (%d snapshot(s) will be kept)",
            $self->get_parameter('id'),
            $keep
    ));

    my $snapshots = $self->find_related_to_me('snapshot', 1);

    my $snapshots_deleted = 0;
    my $snapshots_found = 0;

    foreach my $snapshot (sort { $b->get_parameter('created') cmp $a->get_parameter('created') } (@{ $snapshots })) {
        $log->trace(mm_sprintf(
            "Found the %s snapshot created on %s related to the %s volume",
                $snapshot->get_parameter('id'),
                $snapshot->get_parameter('created'),
                $self->get_parameter('id')
        ));
        if($snapshot->get_parameter('state') eq 'BackedUp') {

            if(++$snapshots_found > $keep) {
                my $job = $snapshot->delete;
                return($self->error($snapshot->error_message))
                    unless(defined($job));
                $log->info(mm_sprintf(
                    "The %s snapshot has been requested for deletion, the %s job has been started",
                        $snapshot->get_parameter('id'),
                             $job->get_parameter('jobid')
                ));
            }

        }
    }

    return($snapshots_deleted);

}



__PACKAGE__->meta->make_immutable;

1;
