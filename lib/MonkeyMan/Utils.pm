package MonkeyMan::Utils;

use strict;
use warnings;

use feature qw(switch);

use MonkeyMan::Constants;

use Exporter;

use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
use Data::Dump::XML;
use File::Path;
use POSIX qw(strftime);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

my @MM_utils_all = qw(
    mm_sprintify
    mm_dump_object
    mm_method_checks
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_utils_all;
@EXPORT_OK          = @MM_utils_all;

sub mm_sprintify {

    $Data::Dumper::Indent   = 0;
    $Data::Dumper::Terse    = 1;

    my($message, @values) = @_;

    return($message) unless(@values);

    for(my $i = 0; $i < @_; $i++) {
        given($values[$i]) {
            when(undef)             { $values[$i] = "[UNDEF]"; }
            when(ref($_) eq 'HASH') { $values[$i] = Dumper($_); }
            when(blessed($_))       { $values[$i] = sprintf("[%s\@0x%x]", blessed($_), refaddr($_)); }
        }
    }

    return(sprintf($message, @values));

}



sub mm_dump_object {

    my $data        = shift;
    my $object_type = shift;
    my $object_name = shift;
    my $depth       = shift;
    my $xml         = shift;

    die("The data reference isn't defined")
        unless(defined($data));
    $object_type = "other"
        unless(defined($object_type));
    $object_name = "nonane"
        unless(defined($object_name));
    $depth = -1
        unless(defined($depth));

    # Make a dump
    
    my $output;
    if($xml) {
        my $dumper = eval { Data::Dump::XML->new(); };
        die(mm_sprintify("Can't Data::Dump::XML->new(): %s", $@))
            if($@);
        $output = $dumper->dump_xml($data);
    } else {
        my $dumper = eval { Data::Dumper->new([$data], [[$object_name]]); };
        die(mm_sprintify("Can't Data::Dumper->new(): %s", $@))
            if($@);
        $dumper->Indent(2);
        $dumper->Maxdepth($depth) if($depth < 0);
        $output = $dumper->Dump;
    }

    # Create necessary diretories

    my $dirname     = MMDumpObjectsTo . mm_sprintify(
        "/%s/%s-%d",
            $object_type,
            strftime("%Y%m%d%H%M%S", localtime),
            $$
    );
    eval { mkpath($dirname); };
    die(mm_sprintify("Can't mkpath(): %s", $@))
        if($@);

    # Open a file and just dump all the fookin shit down there

    my $filename    = mm_sprintify("%s/%s.%s", $dirname, $object_name, ($xml ? "xml" : "dump"));
    eval { open(OUT, ">$filename"); };
    die(mm_sprintify("Can't open: %s", $@))
        if($@);
    print(OUT $output);
    close(OUT);

    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    $log->trace(mm_sprintify("Something has been dumped to %s", $filename))
        if(defined($log));

    return($filename);

}



sub mm_method_checks {

=pod

    package MonkeyMan::SomeClass;
    use MonkeyMan::Utils;

    some_method {
        my($self, %parameters) = (shift, @_);
        my($mm, $log, $cloudstack_api, $cloudstack_cache, $something);

        eval { mm_method_checks(
            'object' => $self,
            'checks' => {
                'mm'                => { variable   => \$mm },
                'log'               => { variable   => \$log },
                'element_dom'       => { variable   => \$element_dom },
                'element_id'        => { variable   => \$element_id },
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
                }  # ^^^ Makes $something equal to the value, but doesn't care about the value itself
                   # Of course, you can do all these tricks to any element's attribute, such as mm, log, etc.
            },
        ); };
        return($self->error($@))
            if($@);
    }

    Performes essential sanity checks for the method being called.

=cut

    my(%parameters) = @_;
    
    my $checks = $parameters{'checks'};
    my $object = $parameters{'object'};
    die("The object hasn't been defined")
        unless(defined($object));

    while(my($check_key, $check_value) = each(%{ $checks })) {

        my $value = $check_value->{'value'};

        # Assigning parameters...
 
        given($check_key) {
            when('mm') {
                $value = $object->mm
                    if(!defined($value) && $object->has_mm);
            } when('log') {
                $value = eval { Log::Log4perl::get_logger(ref($object)) }
                    if(!defined($value));
            } when('element_dom') {
                $value = $object->dom
                    if(!defined($value) && $object->has_dom);
            } when('element_id') {
                $value = $object->get_parameter('id')
                      if(defined($object->get_parameter('id') && $object->get_parameter('id') =~ /./)); #
            } when('cloudstack_api') {
                $value = $object->mm->cloudstack_api
                    if(!defined($value) && $object->has_mm && $object->mm->has_cloudstack_api);
            } when('cloudstack_cache') {
                $value = $object->mm->cloudstack_cache
                    if(!defined($value) && $object->has_mm && $object->mm->has_cloudstack_cache);
            } when(/^\$/) {
                # It's okay :)
            } default {
                die(mm_sprintify("Don't know how to check the %s parameter", $_));
            }
        }

        # Have we got anything?

        if(
            !defined($value) &&
            !$check_value->{'careless'}
        ) {
            die(
                defined($check_value->{'error'}) ?
                    $check_value->{'error'} :
                    mm_sprintify("The %s parameter has been neither defined nor initialized", $check_key)
            );
        }

        # Shall the value be a reference?

        if(
            defined($check_value->{'isaref'}) &&
           (ref($check_value->{'value'}) ne $check_value->{'isaref'})
        ) {
            die(
                defined($check_value->{'error'}) ?
                    $check_value->{'error'} :
                    mm_sprintify("The %s parameter (%s) isn't a reference to %s",
                        $check_key,
                        ref($check_value->{'value'}) ?
                            mm_sprintify("is a reference to %s", ref($check_value->{'value'})) :
                            mm_sprintify("is not a reference, equal to %s", $check_value->{'value'}),
                        $check_value->{'isaref'}
                    )
            );
        }

        # If the target variable is given, it's supposed to be a reference, isn't it?

        if(
            defined($check_value->{'variable'}) &&
               !ref($check_value->{'variable'})
        ) {
            die(mm_sprintify("The variable for the %s parameter isn't a reference", $check_key));
        }

        # If the value and the variable are given, assign the value to the variable

        if(
                ref($check_value->{'variable'}) eq 'SCALAR'
        ) {
                  ${$check_value->{'variable'}} = $value;
                    next;
        }

    }

}



1;
