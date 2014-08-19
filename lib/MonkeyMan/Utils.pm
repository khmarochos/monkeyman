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
use POSIX::strptime;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

my @MM_utils_all = qw(
    mm_sprintify
    mm_dump_object
    mm_method_checks
    mm_string_to_time
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
                'mm'            => { variable   => \$mm },
                'log'           => { variable   => \$log },
                'cs'            => { variable => \$cloudstack },
                'cs_api'        => { variable   => \$cloudstack_api },
                'cs_cache'      => { variable   => \$cloudstack_cache },
                '$something'    => {
                    value           =>  $parameters{'something'}
                }, # ^^^ Just checks if the parameter has been defined
                '$something'    => {
                    value           =>  $parameters{'something'},
                    isaref          => 'MonkeyMan::_templates::SomeClass'
                }, # ^^^ Checks if the parameter is defined and it's a reference to something
                '$something'    => {
                    value           =>  $parameters{'something'},
                    error           => "Something hasn't been defined"
                }, # ^^^ What error message should be generated if the check fails instead of default
                '$something'    => {
                    value           =>  $parameters{'something'},
                    variable        => \$something
                }, # ^^^ Checks the parameter and makes $something equal to the value
                '$something'    => {
                    value           =>  $parameters{'something'},
                    variable        => \$something,
                    careless        => 1
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

        # If the value is given, just assign it

        my $value = $check_value->{'value'};

        # Or, if we don't have the value...
        
        unless(defined($value)) {
            my $try_global_method_checks = 0;
            if($object->can('own_method_checks') && $check_key !~ /^\$/) {
                $value = eval { $object->own_method_checks($check_key) };
                $try_global_method_checks = 1
                    if($@ =~ /^\[CAN'T CHECK\]/)
            } else {
                $try_global_method_checks = 1;
            }

            if($try_global_method_checks) {
                given($check_key) {
                    when('log') {
                        $value = Log::Log4perl::get_logger(ref($object))
                    } when('mm') {
                        $value = $object->mm
                    } when('configuration') {
                        $value = $object->configuration
                    } when('cs') {
                        $value = $object->cs
                    } when('cs_api') {
                        $value = $object->cs->api
                            if(ref($object->cs) eq 'MonkeyMan::CloudStack');
                    } when('cs_cache') {
                        $value = $object->cs->cache
                            if(ref($object->cs) eq 'MonkeyMan::CloudStack');
                    } when(/^\$/) {
                        # Oh, it's okay
                    } default {
                        die(mm_sprintify("[CAN'T CHECK] - the parameter %s is unknown", $check_key));
                    }
                }
            }

        }

        # So, have we got anything after all these checks and assignments?

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



sub mm_string_to_time {

    my $string = shift;

    return(undef)
        unless(defined($string));

    return(POSIX::strftime("%s", POSIX::strptime($string, "%Y-%m-%dT%H:%M:%S")));

}



1;
