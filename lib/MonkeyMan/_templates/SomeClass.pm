package MonkeyMan::_templates::SomeClass;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);



sub some_method {

    my $self = shift;
    my %parameters = @_;
    my($mm, $log, $cloudstack_api, $cloudstack_cache, $something);

    eval { mm_method_checks(
        'object' => $self,
        'checks' => {
            'mm'                => { variable   => \$mm },
            'log'               => { variable   => \$log },
            'cloudstack_api'    => { variable   => \$cloudstack_api },
            'cloudstack_cache'  => { variable   => \$cloudstack_cache },
            '$something' => {
                value       =>  $parameters{'something'}
            }, # ^^^ Just checks if the parameter has been defined
            '$something' => {
                value       =>  $parameters{'something'},
                isaref      => 'MonkeyMan::_templates::SomeClass'
            }, # ^^^ Checks if the parameter is defined and it's a reference to something
            '$something' => {
                value       =>  $parameters{'something'},
                error       => "Something hasn't been defined"
            }, # ^^^ What error message should be generated if the check fails instead of default
            '$something' => {
                value       =>  $parameters{'something'},
                variable    => \$something
            }, # ^^^ Checks the parameter and makes $something equal to the value
            '$something' => {
                value       =>  $parameters{'something'},
                variable    => \$something,
                careless    => 1
            }, # ^^^ Makes $something equal to the value, but doesn't care about the value itself
            '$something' => {
                value       =>  $parameters{'something'},
                isaref      => 'MonkeyMan::_templates::SomeClass'
            } 
               # You also can do all these tricks to element's attributes, such as $mm, $log, etc.
        }
    ); };
    return($self->error($@))
        if($@);

    $log->trace(mm_sprintify("I've got \"%s\" as \$something", $something));
    $log->trace(mm_sprintify("I've also got these parameters: %s", \%parameters));

    return(mm_sprintify("That %s is fine, thank you!", $something));

}



__PACKAGE__->meta->make_immutable;

1;
