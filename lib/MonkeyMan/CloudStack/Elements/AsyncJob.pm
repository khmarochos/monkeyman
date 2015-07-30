package MonkeyMan::CloudStack::Elements::AsyncJob;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants;
use MonkeyMan::Utils;

# Use Moose :)
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

        try {
            mm_check_method_invocation(
                'object'    => $self,
                'checks'    => {
                    'log'       => { variable   => \$log },
                    'cs_api'    => { variable   => \$api }
                }
            );
        } catch(MonkeyMan::Exception $e) {
            $e->throw;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
        } 

        my $result = $api->run_command(%{ $self->init_run });

        my $jobids = $api->query_xpath($result, "/*/jobid");

        my $jobid;
        
        try {
            $jobid = ${$jobids}[0]->textContent;
        } catch($e) {
            MonkeyMan::Exception->throw("Can't XML::LibXML::Element->textContent(): %s", $e);
        }

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

    MonkeyMan::Exception->throw("Required parameters haven't been defined")
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

    MonkeyMan::Exception->throw("The required parameter hasn't been defined"))
        unless(defined($parameter));

    return("/asyncjobs/$parameter");

}



sub _find_related_to_given_conditions {

    my($self, $key_element) = @_;

    MonkeyMan::Exception->throw("The key element hasn't been defined")
        unless(defined($key_element));

    return(
        $key_element->element_type . "id" => $key_element->get_parameter('id')
    );

}



sub result {

    my $self = shift;
    my($log, $api, $jobid);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'       => { variable   => \$log },
                'cs_api'    => { variable   => \$api },
                '$jobid'    => {
                                variable   => \$jobid,
                                value      => shift,
                                careless   => 1
                }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    $jobid = $self->get_parameter('jobid')
        unless(defined($jobid));
    MonkeyMan::Exception->throw("The element's ID isn't defined")
        unless(defined($jobid));

    my $result_of_run = $api->run_command(
        parameters  => {
            command     => 'queryAsyncJobResult',
            jobid       => $jobid
        }
    );

    my $result_to_return = {};

    $self->result_parse($result_of_run, $result_to_return);

    return($result_to_return);

}



sub result_parse {

    my $self = shift;
    my($log, $api, $dom, $results_to);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                'cs_api'        => { variable   => \$api },
                '$dom'          => {
                                    variable   => \$dom,
                                    value      => shift,
                },
                '$results_to'   => {
                                    variable   => \$results_to,
                                    value      => shift,
                }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    my $elements = $api->query_xpath($dom, "/queryasyncjobresultresponse/*");

    my $elements_found = 0;

    foreach my $element (@{ $elements }) {

        my $element_value;
        my $element_name;
        my $more_children;

        try {
            $element_name = $element->nodeName;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't XML::LibXML::Element->nodeName(): %s", $e);
        }

        try {
            $element = $element->firstChild;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't XML::LibXML::Element->firstChild(): %s", $e);
        }

        try {
            $more_children = $element->hasChildNodes;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't XML::LibXML::Element->hasChildNodes(): %s", $e);
        }

        if($more_children) {
            $element_value = $element;
        } else {
            try {
                $element_value = $element->textContent;
            } catch($e) {
                MonkeyMan::Exception->throw_f("Can't XML::LibXML::Element->textContent(): %s", $e);
            }
        }

        $results_to->{$element_name} = $element_value;
    }

    return($elements_found);

}



__PACKAGE__->meta->make_immutable;



1;

