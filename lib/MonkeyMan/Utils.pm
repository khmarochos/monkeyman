package MonkeyMan::Utils;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);

# Use 3rd party libraries
use TryCatch;
use autodie;
use experimental qw(switch);
use Scalar::Util qw(blessed refaddr);
use Data::Dumper;
use Data::Dump::XML;
use File::Path;
use POSIX qw(strftime);
use POSIX::strptime;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);



my @MM_utils_all = qw(
    mm_sprintf
    mm_dump_object
    mm_check_method_invocation
    mm_string_to_time
);

@ISA                = qw(Exporter);
@EXPORT             = @MM_utils_all;
@EXPORT_OK          = @MM_utils_all;



sub mm_sprintf {

    my($message, @values) = @_;

    for(my $i = 0; $i < @_; $i++) {
        given($values[$i]) {
            when(undef)                     { $values[$i] = "[UNDEF]"; }
            when(blessed($_))               { $values[$i] = sprintf("[%s\@0x%x]", blessed($_), refaddr($_)); }
            when(ref($_) eq 'HASH') { eval  { $values[$i] = Data::Dumper->new([$_])->Indent(0)->Terse(1)->Dump; } }
        }
    }

    return(sprintf($message, @values));

}



sub mm_dump_object {

=pod

    use MonkeyMan::Utils;

    mm_dump_object(
        data        => $stash,  # (suggested)   some big and complicated data structure
        object_type => $type,   # (optional)    object's type (for categorizing)
        object_name => $name,   # (optional)    object's name (for the same)
        max_depth   => $depth   # (optional)    max depth for Data::Dumper (-1 is unlimited)
    );

=cut

    my %parameters = @_;
    my($data, $object_type, $object_name, $max_depth, $make_xml);

    try {
        mm_check_method_invocation(
            'object'    => bless({}),
            'checks'    => {
                '$data'         => { variable => \$data,        value => $parameters{'data'} },
                '$object_type'  => { variable => \$object_type, value => $parameters{'object_type'},    careless => 1 },
                '$object_name'  => { variable => \$object_name, value => $parameters{'object_name'},    careless => 1 },
                '$max_depth'    => { variable => \$max_depth,   value => $parameters{'max_depth'},      careless => 1 },
                '$make_xml'     => { variable => \$make_xml,    value => $parameters{'make_xml'},       careless => 1 },
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw($e)
    }

    $object_type = "other"
        unless(defined($object_type));
    $object_name = "noname"
        unless(defined($object_name));
    $max_depth = -1
        unless(defined($max_depth));

    # Make a dump
    
    my $output;
    if($make_xml) {
        try {
            $output = Data::Dump::XML->new()->dump_xml($data);
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't Data::Dump::XML->new()->dump_xml(): %s", $e);
        }
    } else {
        try {
            Data::Dumper->new([$data], [[$object_name]])->Indent(2)->Maxdepth(($max_depth >= 0) ? $max_depth : undef)->Dump;
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't Data::Dumper->new()->Indent()->Maxdepth()->Dump(): %s", $e);
        }
    }

    # Create necessary diretories

    my $dirname     = MM_DIRECTORY_DUMP . mm_sprintf(
        "/%s/%s-%d",
            $object_type,
            strftime("%Y%m%d%H%M%S", localtime),
            $$
    );
    try {
        mkpath($dirname);
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mkpath() %s: %s", $dirname, $e);
    }

    # Open a file and just dump all the fookin shit down there

    my $filename = mm_sprintf("%s/%s.%s", $dirname, $object_name, ($make_xml ? "xml" : "dump"));
    try {
        open(OUT, ">$filename");
        print(OUT $output);
        close(OUT);
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't dump to the %s file: %s", $filename, $e);
    }

    try {
       my $log = Log::Log4perl::get_logger(__PACKAGE__);
       $log->trace(mm_sprintf("Something has been dumped to %s", $filename))
           if(defined($log));
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't send a message to the logger: %s", $e);
    }

    return($filename);

}



sub mm_check_method_invocation {

=pod

    package MonkeyMan::SomeClass;
    use MonkeyMan::Utils;

    some_method {
        my($self, %parameters) = (shift, @_);
        my($mm, $log, $cloudstack_api, $cloudstack_cache, $something);

        eval { mm_check_method_invocation(
            'object' => $self,
            'checks' => {
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
                }, # ^^^ Checks the parameter and makes $something equal to its' value
                '$something'    => {
                    value           =>  $parameters{'something'},
                    variable        => \$something,
                    careless        => 1
                }  # ^^^ Makes $something equal to the value, but doesn't care about its' definition
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

    while(my($check_key, $check_value) = each(%{ $checks })) {

        # If the value is given, just assign it

        my $value = $check_value->{'value'};

        # Or, if we don't have the value...
        
        unless(defined($value)) {

            my $try_global_method_checks = 1;

            if(
                $check_key !~ /^\$/ && blessed($object) && $object->can('own_method_checks')
            ) {
                try {
                    $value = $object->own_method_checks($check_key);
                    $try_global_method_checks = 0;
                } catch(MonkeyMan::Exception::MethodInvocationCheck::CheckNotImplemented $e) {
                    # That's okay!
                } catch(MonkeyMan::Exception $e) {
                    $e->throw;
                } catch($e) {
                    MonkeyMan::Exception::MethodInvocationCheck->throw_f("Can't %s->own_method_checks(): %s", $object, $e);
                }
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
                            if(blessed($object->cs) && $object->cs->isa('MonkeyMan::CloudStack'));
                    } when('cs_cache') {
                        $value = $object->cs->cache
                            if(blessed($object->cs) && $object->cs->isa('MonkeyMan::CloudStack'));
                    } when(/^\$/) {
                        # Oh, it's okay
                    } default {
                        MonkeyMan::Exception::MethodInvocationCheck::CheckNotImplemented->throw_f("The %s check isn't implemented", $check_key);
                    }
                }
            }

        }

        # So, have we got anything after all these checks and assignments?

        if(
            !defined($value) &&
            !$check_value->{'careless'}
        ) {
            MonkeyMan::Exception::MethodInvocationCheck::ParameterUndefined->throw_f(
                defined($check_value->{'error'}) ?
                    ($check_value->{'error'}) :
                    ("The %s parameter has been neither defined nor initialized", $check_key)
            );
        }

        # Shall the value be a reference?

        if(
            defined($check_value->{'isaref'}) &&
           (ref($check_value->{'value'}) ne $check_value->{'isaref'})
        ) {
            MonkeyMan::Exception::MethodInvocationCheck::ParameterInvalid->throw_f(
                defined($check_value->{'error'}) ?
                    ($check_value->{'error'}) :
                    ("The %s parameter (%s) isn't a reference to %s",
                        $check_key,
                        ref($check_value->{'value'}) ?
                            mm_sprintf("is a reference to %s", ref($check_value->{'value'})) :
                            mm_sprintf("is not a reference at all, equal to %s", $check_value->{'value'}),
                        $check_value->{'isaref'}
                    )
            );
        }

        # If the target variable is given, it's supposed to be a reference, isn't it?

        if(
            defined($check_value->{'variable'}) &&
               !ref($check_value->{'variable'})
        ) {
            MonkeyMan::Exception::MethodInvocationCheck::TargetInvalid->throw_f("The target variable for the %s parameter isn't a reference", $check_key);
        }

        # If the value and the variable are given, assign the value to the variable

        ${$check_value->{'variable'}} = $value;

    }

}



sub mm_string_to_time {

    my $string = shift;

    return(undef)
        unless(defined($string));

    return(POSIX::strftime("%s", POSIX::strptime($string, "%Y-%m-%dT%H:%M:%S")));

}



1;
