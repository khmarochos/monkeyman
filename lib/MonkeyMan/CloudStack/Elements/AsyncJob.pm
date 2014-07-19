package MonkeyMan::CloudStack::Elements::AsyncJob;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::Element';



has 'init_run' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => 'has_init_run',
    init_arg    => 'run'
);



before BUILD => sub {

    my $self = shift;

    # Run the command if it's necessary
 
    if($self->has_init_run) {

        my($api, $log);

        eval { mm_method_checks(
            'object'    => $self,
            'checks'    => {
                'cloudstack_api'    => { variable   => \$api },
                'log'               => { variable   => \$log }
            }
        ); };
        die($@)
            if($@);

        $log->trace("Going to run an API command");

        my $result = $api->run_command(%{ $self->init_run });
        die($api->error_message)
            unless(defined($result));

        my $jobids = $api->query_xpath($result, "/*/jobid");
        die($api->error_message)
            unless(defined($jobids));

        my $jobid = eval { ${$jobids}[0]->textContent; };
        die(mm_sprintify("Can't XML::LibXML::Element->textContent(): %s", $@))
            if($@);

        $self->_set_init_load_dom({ conditions => { jobid => $jobid} }); # the object will be created after

    }
};



sub element_type {
    return('asyncjob');
}



sub _load_full_list_command {
    return({
        command => 'listAsyncJobs',
        listall => 'true'
    });
}



sub _load_dom_xpath_query {

    my($self, %parameters) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(%parameters);

    if($parameters{'attribute'} eq 'FINAL') {
        return("/listasyncjobsresponse/asyncjobs");
    } else {
        return("/listasyncjobsresponse/asyncjobs[" .
            $parameters{'attribute'} . "='" .
            $parameters{'value'} . "']"
        );
    }

}



sub _get_parameter_xpath_query {

    my($self, $parameter) = @_;

    return($self->error("Required parameters haven't been defined"))
        unless(defined($parameter));

    return("/asyncjobs/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    return($self->error("The key element hasn't been defined"))
        unless(defined($key_element));

    return(
        $key_element->element_type . "id" => $key_element->get_parameter('id')
    );

}



sub result {

    my $self = shift;
    my($jobid, $mm, $api, $log);

    eval { mm_method_checks(
        'object' => $self,
        'checks' => {
            '$jobid'            => {
                                     variable   => \$jobid,
                                     value      => shift,
                                     careless   => 1
            },
            'mm'                => { variable   => \$mm },
            'cloudstack_api'    => { variable   => \$api },
            'log'               => { variable   => \$log }
        }
    ); };
    return($self->error($@))
        if($@);

    $jobid = $self->get_parameter('jobid')
        unless(defined($jobid));
    return($self->error("The element's ID isn't defined"))
        unless(defined($jobid));

    my $result_of_run = $api->run_command(
        parameters  => {
            command     => 'queryAsyncJobResult',
            jobid       => $jobid
        }
    );

    my $result_to_return = {};
    my $result = $self->result_parse($result_of_run, $result_to_return);
    return($self->error($self->error_message))
        unless(defined($result));

    return($result_to_return);

}



sub result_parse {

    my $self = shift;
    my($dom, $results_to, $mm, $api, $log);

    eval { mm_method_checks(
        'object' => $self,
        'checks' => {
            '$dom'              => {
                                     variable   => \$dom,
                                     value      => shift,
            },
            '$results_to'       => {
                                     variable   => \$results_to,
                                     value      => shift,
            },
            'mm'                => { variable   => \$mm },
            'cloudstack_api'    => { variable   => \$api },
            'log'               => { variable   => \$log }
        }
    ); };
    return($self->error($@))
        if($@);

    my $elements = $api->query_xpath($dom, "/queryasyncjobresultresponse/*");
    return($self->error($api->error_message))
        unless(defined($elements));

    my $elements_found = 0;

    foreach my $element (@{ $elements }) {

        my $element_name = eval { $element->nodeName };
        return($self->error(mm_sprintify("Can't XML::LibXML::Element->nodeName(): %s", $@)))
            if($@);

        my $element_value;
        if(ref($element) eq 'XML::LibXML::Element') {
            $element_value = eval { $element->textContent };
            return($self->error(mm_sprintify("Can't XML::LibXML::Element->textContent(): %s", $@)))
               if($@);
        } else {
            $element_value = $element;
        }

        $results_to->{$element_name} = $element_value;
    }

    return($elements_found);

}



__PACKAGE__->meta->make_immutable;



1;

