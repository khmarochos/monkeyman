package MonkeyMan;

=head1 NAME

MonkeyMan - Apache CloudStack Management Framework

=head1 DESCRIPTION

This is a framework that makes possible to manage the
L<Apache CloudStack|http://cloudstack.apache.org/> based cloud infrastructure
with high-level Perl5-applications.

=begin markdown

![The mascot has been originaly created by D.Kolesnichenko for Tucha.UA](http://tucha.ua/wp-content/uploads/2013/08/monk.png)

=end markdown

=head1 SYNOPSIS

    MonkeyMan->new(
        app_code            => \&MyCoolApplication,
        app_name            => 'apps/cool/mine.pl',
        app_description     => "Discovers objects' relations",
        app_version         => '6.6.6',
        parameters_to_get   => {
            'd|domain_id=s'     => 'domain_id'
        }
    );

    sub MyCoolApplication {

        $mm  = shift;
        $log = $mm->get_logger;

        # The CloudStack API is amazingly easy to use, refer to the
        # MonkeyMan::CloudStack::API documentation
        $api = $mm->get_cloudstack->get_api;

        # Let's find the domain by its ID
        foreach my $d ($api->get_elements(
            type        => 'Domain',
            criterions  => {
                id  => $mm->get_parameters->get_domain_id
            }
        )) {

            # Okay, now let's find all the virtual machines
            # related to the domain we found
            foreach $vm ($d->get_related(type => 'VirtualMachine')) {
                $log->infof("The %s's ID is %s - got as %s\n",
                    $vm->get_type(noun => 1),
                    $vm->get_id,
                    $vm,
                );
            }

        }

    }

    # > apps/cool/mine.pl -d 01234567-89ab-cdef-fedc-ba9876543210
    # 2040/04/20 04:20:00 [I] [main] The virtual machine's ID is 01234567-dead-beef-cafe-899123456789 - got as [MonkeyMan::CloudStack::API::Element::VirtualMachine@0xdeadbee/badcaffefeeddeafbeefbabedeadface]
    # 
    # Hope you'll enjoy it :)
    #

=head1 MODULES' HIERARCHY

...

=cut

use 5.20.1;
use strict;
use warnings;

our $VERSION='v2.1.0-dev_melnik13_v3';

# Use Moose and be happy :)
use Moose 2.1604;
use namespace::autoclean;

# Add some roles
with 'MonkeyMan::Roles::WithTimer';
# This is a role to implement the timer attributes for the MonkeyMan class
# (the time_started attribute and some methods to work with it)

use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Exception qw(CanNotLoadPackage);
use MonkeyMan::Parameters;
use MonkeyMan::CloudStack;
use MonkeyMan::Logger;
use MonkeyMan::PasswordGenerator;

# Use 3rd-party libraries
use MooseX::Handies;
use MooseX::Singleton;
use Method::Signatures;
use TryCatch;
use Getopt::Long qw(:config no_ignore_case);
use Config::General;



=head1 METHODS

=head2 C<new()>

    MonkeyMan->new(%parameters => %Hash)

This method initializes the framework and runs the application.

=cut

method BUILD(...) {

    END {
        my $mm = MonkeyMan->instance;
        if(ref($mm) eq 'MonkeyMan') {
            $mm->get_logger->debugf("<%s> Goodbye world!", $mm->get_time_passed_formatted)
                if($mm->can('get_logger'));
            $mm->_mm_shutdown
                if($mm->can('_mm_shutdown'));
        }
    }

    $self->_mm_init;
    $self->get_logger->debugf("<%s> Hello world!", $self->get_time_passed_formatted);
    if(defined($self->get_app_code)) {
        $self->_app_start;
        $self->_app_run;
        $self->_app_finish;
    }


}



=pod

There are a few parameters that can (and need to) be defined:

=head3 Application-Related Parameters

=cut

has 'mm_version' => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_mm_version',
    builder     => '_build_mm_version',
    init_arg    => undef
);

method _build_mm_version {

    MM_VERSION;

}

=head4 C<app_code>

MANDATORY. Contains a C<CodeRef> pointing to the code of the application that
needs to be run. The reader's name is C<get_app_code>.

=cut

has 'app_code' => (
    is          => 'ro',
    isa         => 'Maybe[CodeRef]',
    reader      => 'get_app_code',
    predicate   => 'has_app_code'
);

=head4 C<app_name>

MANDATORY. Contains a C<Str> of the application's full name. The reader's name
is C<get_app_name>.

=cut

has 'app_name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_name',
    writer      => '_set_app_name'
);

=head4 C<app_description>

MANDATORY. Contains a C<Str> of the application's description. The reader's name
is C<get_app_description>.

=cut

has 'app_description' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_description',
    writer      => '_set_app_description'
);

=head4 C<app_version>

MANDATORY. Contains a C<Str> of the application's version number. The reader's
name is C<get_app_version>.

=cut

has 'app_version' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_version',
    writer      => '_set_app_version'
);

=head4 C<app_usage_help>

Optional. Contains a C<Str> to be displayed when the user asks for help. The
reader's name is C<get_app_usage_help>.

=cut

has 'app_usage_help' => (
    is          => 'ro',
    isa         => 'CodeRef|Str',
    required    => 0,
    reader      =>  'get_app_usage_help',
    predicate   =>  'has_app_usage_help',
    writer      => '_set_app_usage_help'
);



=head3 Configuration-Related Parameters

=head4 C<parameters_to_get>

THIS PARAMETER MAY BE DEPRECATED, ONE SHOULD USE C<parameters_to_get_and_check>

Optional. Contains a C<HashRef>. This parameter shall be a reference to a hash
containing parameters to be passed to the L<Getopt::Long>::GetOptions()
function.  It sets the the C<parameters> attribute with the C<get_parameters()>
accessor which returns a reference to the L<MonkeyMan::Parameters> object
containing the information about startup parameters. Thus,

    parameters_to_get => {
        'i|input=s'     => 'file_in',
        'o|output=s'    => 'file_out'
    }

will create L<MonkeyMan::Parameters> object with C<get_file_in> and
C<get_file_out> read-only accessors, so you could address them as

    $monkeyman->get_parameters->get_file_in,
    $monkeyman->get_parameters->get_file_out

You can define various startup parameters, but there are some special
ones that shouldn't be redefined:

=over

=item C<-h>, C<--help>

The show-help-and-terminate mode. Sets the C<mm_show_help> attribute, the
accessor is C<get_mm_show_help()>.

=item C<-V>, C<--version>

The show-version-and-terminate mode. Sets the C<mm_show_version> attribute, the
accessor is C<get_mm_show_version()>.

=item C<<-c <filename> >>, C<< --configuration=<filename> >>

The name of the main configuration file. Sets the C<mm_configuration>
attribute. The accessor is C<get_mm_configuration()>.

=item C<-v>, C<--verbose>

Increases the debug level, the more times you add it, the higher level is. The
default level is INFO, for more information about logging see
L<MonkeyMan::Logger> documentation. Sets the C<mm_be_verbose> attribute, the
accessor is C<get_mm_be_verbose()>.

=item C<-q>, C<--quiet>

Does the opposite of what the previous one does - it decreases the debug level.
Sets the C<mm_be_quiet> attribute, the accessor is is C<get_mm_be_quiet()>.

=back

=cut

has 'parameters_to_get' => (
    is          => 'ro',
    isa         => 'HashRef[Str]',
    predicate   => '_has_parameters_to_get',
    reader      => '_get_parameters_to_get',
    builder     => '_build_parameters_to_get',
    lazy        => 0,
);

method _build_parameters_to_get(...) {
    return({});
}

=head4 C<parameters_to_get_validated>

Optional. Contains a YAML-based configuration of the command-line parameters
need to be parsed and validated.

Overrides values of C<parameters_to_get>. Basically fucks C<parameters_to_get>
off to tell you the truth.

=cut

has 'parameters_to_get_validated' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   => '_has_parameters_to_get_validated',
    reader      => '_get_parameters_to_get_validated',
    lazy        => 0
);

has 'parameters' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Parameters',
    reader      =>    'get_parameters',
    writer      =>   '_set_parameters',
    predicate   =>   '_has_parameters',
    builder     => '_build_parameters',
    lazy        => 1
);

method _build_parameters {

    return(MonkeyMan::Parameters->new(monkeyman => $self));

}



=head4 C<configuration>

Optional. Contains a reference to the hash containing the framework's
configuration tree. If it's not defined (in most cases), the framework will try
to parse the configuration file. The name of the file can be passed with the
C<-c|--configuration> startup parameter.

    # MM_DIRECTORY_ROOT/etc/monkeyman.conf contains:
    #          <log>
    #              <PRIMARY>
    #                  <dump>
    #                      enabled = 1
    $log->debugf("The dumper is %s,
        $mm->get_configuration
            ->{'log'}
                ->{'PRIMARY'}
                    ->{'dump'}
                        ->{'enabled'} ? 'enabled' : 'disabled'
    );

If the configuration is neither defined as the constructor parameter nor
defined by the startup parameter, the framework attempts to find the
configuration file at the location defined as the C<MM_CONFIG_MAIN> constant.

=cut

has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   =>    'has_configuration',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {

    my $config = Config::General->new(
        -ConfigFile         => (
            defined($self->get_parameters->get_mm_configuration) ?
                    $self->get_parameters->get_mm_configuration :
                    MM_CONFIG_MAIN
        ),
        -UseApacheInclude   => 1,
        -ExtendedAccess     => 1
    );
    return({ $config->getall });

}



=head3 Helpers-Related Parameters

=head4 C<loggers>

Optional. Contains a C<HashRef> with links to L<MonkeyMan::Logger>
modules, so you can use multiple interfaces to multiple cloudstack with the
C<get_logger()> method described below.

=cut

has 'default_logger_id' => (
    is          => 'ro',
    isa         => 'Str',
    lazy        => 1,
    reader      => 'get_default_logger_id',
    writer      => '_set_default_logger_id',
    predicate   => '_has_default_logger_id',
    builder     => '_build_default_logger_id'
);

method _build_default_logger_id {
    if(defined(my $default_logger_id =
        $self->get_parameters->get_mm_default_logger)) {
        return($default_logger_id);
    } else {
        return(&MM_DEFAULT_LOGGER_ID);
    }
}

=head4 C<cloudstacks>

Optional. Contains a C<HashRef> with links to L<MonkeyMan::CloudStack> modules.
The C<get_cloudstack()> method helps to get the CloudStack instance by its
handle is described below.

=cut

has 'default_cloudstack_id' => (
    is          => 'ro',
    isa         => 'Str',
    lazy        => 1,
    reader      => 'get_default_cloudstack_id',
    writer      => '_set_default_cloudstack_id',
    predicate   => '_has_default_cloudstack_id',
    builder     => '_build_default_cloudstack_id'
);

method _build_default_cloudstack_id {
    if(defined(my $default_cloudstack_id =
        $self->get_parameters->get_mm_default_cloudstack)) {
        return($default_cloudstack_id);
    } else {
        return(&MM_DEFAULT_CLOUDSTACK_ID);
    }
}

=head4 C<password_generators>

=cut

has 'default_password_generator_id' => (
    is          => 'ro',
    isa         => 'Str',
    lazy        => 1,
    reader      =>    'get_default_password_generator_id',
    writer      =>   '_set_default_password_generator_id',
    predicate   =>   '_has_default_password_generator_id',
    builder     => '_build_default_password_generator_id'
);

method _build_default_password_generator_id {
    return(&MM_DEFAULT_PASSWORD_GENERATOR_ID);
}

=head2 get_app_code()

=head2 get_app_name()

=head2 get_app_description()

=head2 get_app_usage_help()

=head2 get_app_version()

Readers for corresponding modules attributes. These attributes are being set
when initializing the framework, so see L</MonkeyMan Application-Related
Parameters> for details.

=head2 get_parameters()

=head2 get_parameters_to_get()

The first accessor returns the reference to the L<MonkeyMan::Parameters> object
containing B<results> of parsing command-line parameters according to the rules
defined by the C<parameters_to_get> initialization parameter.

The second one returns the reference to the hash containing the B<ruleset> of
parsing the command-line parameters that have been defined by the
<parameters_to_get> initialization parameter, but with addition of some default
rules (such as C<'h|help'>, C<'V|version'> and so on) added by the framework on
its own.

See L</MonkeyMan Configuration-Related Parameters> section of the L</new()>
method's documentation for more information.

=head2 get_configuration()

This accessor returns the reference to the hash containing the framework's
configuration tree.

=head2 get_logger()

=head2 get_loggers()

The C<get_logger()> accessor returns the reference to L<MonkeyMan::Logger>
requested. If the ID hasn't been specified, it returns the default instance.

You should keep in mind that the default instance can be reassigned by
the C<--default-logger> framework-wide command-line parameter. By
default, the default logger's ID is C<PRIMARY>, as it's defined by the
C<MM_DEFAULT_LOGGER_ID> constant.

    $default_logger_given   = $mm->get_parameters->default_logger;
    $default_logger_used    = $mm->_get_default_logger;

    if(defined($default_logger_given) {
        ok($default_logger_used eq $default_logger_given);
        ok($mm->get_logger == $mm->get_logger($default_logger_used));
    } else {
        ok($default_logger_used eq &MM_DEFAULT_LOGGER_ID);
        ok($mm->get_logger == $mm->get_logger(&MM_DEFAULT_LOGGER_ID));
    }

The default logger is being initialized proactively by the framework, but
it's also possible to initialize it by oneself in the case one needs it.

    $my_loggers = {
        zaloopa => MonkeyMan::Logger->new(...),
        ebuchka => MonkeyMan::Logger->new(...),
        pizdets => MonkeyMan::Logger->new(...)
    };
    $mm = MonkeyMan->new(
        loggers             => $my_loggers,
        default_logger_id   => 'zaloopa'
    );

The C<get_loggers> returns the reference to the hash containing the loggers'
index, which leads to the following:

    ok($mm->get_logger('zaloopa') == $mm->get_loggers->{'zaloopa'});

=head2 get_cloudstack()

=head2 get_cloudstacks()

These accessors behave very similar to C<get_logger()> and C<get_loggers()>,
but the index contains references to L<MonkeyMan::CloudStack> objects
initialized.

The default CloudStack instance's ID can be set by the
C<--default-cloudstack> parameter, by default it's C<PRIMARY>, as it's
defined as the C<MM_DEFAULT_CLOUDSTACK_ID> constant.

=cut

=head2 get_password_generator()

=head2 get_password_generators()

=cut

=head2 get_mm_version()

The name of the method is pretty self-descriptive: the accessor returns the
framework's version ID.

=cut



method _mm_init {

    my $meta = $self->meta;
    my $parameters = $self->get_parameters;

    my $default_logger_id = $self->get_default_logger_id;
    $meta->add_method(
        _build_loggers => method {
            return( { 
                $default_logger_id => MonkeyMan::Logger->new(
                    monkeyman => $self
                )
            } );
        }
    );
    $self->meta->add_attribute(
        'loggers' => (
            is          => 'ro',
            isa         => 'HashRef[MonkeyMan::Logger]',
            reader      =>   '_get_loggers',
            writer      =>   '_set_loggers',
            builder     => '_build_loggers',
            lazy        => 1,
            handies     => [{
                name        => 'get_logger',
                default     => $default_logger_id,
                strict      => 1
            }]
        )
    );

    my $default_cloudstack_id = $self->get_default_cloudstack_id;
    $meta->add_method(
        _build_cloudstacks => method {
            return( {
                $default_cloudstack_id => MonkeyMan::CloudStack->new(
                    monkeyman       => $self,
                    configuration   => $self
                                        ->get_configuration
                                            ->{'cloudstack'}
                                                ->{$default_cloudstack_id}
                )
            } );
        }
    );
    $self->meta->add_attribute(
        'cloudstacks' => (
            is          => 'ro',
            isa         => 'HashRef[MonkeyMan::CloudStack]',
            reader      =>   '_get_cloudstacks',
            writer      =>   '_set_cloudstacks',
            builder     => '_build_cloudstacks',
            lazy        => 1,
            handies     => [{
                name        => 'get_cloudstack',
                default     => $default_cloudstack_id,
                strict      => 1
            }]
        )
    );

    my $default_password_generator_id = $self->get_default_password_generator_id;
    $meta->add_method(
        _build_password_generators => method {
            return( {
                $default_password_generator_id => MonkeyMan::PasswordGenerator->new(
                    monkeyman       => $self,
                    configuration   => $self
                                        ->get_configuration
                                            ->{'password_generator'}
                                                ->{$default_password_generator_id}
                )
            } );
        }
    );
    $self->meta->add_attribute(
        'password_generators' => (
            is          => 'ro',
            isa         => 'HashRef[MonkeyMan::PasswordGenerator]',
            reader      =>   '_get_password_generators',
            writer      =>   '_set_password_generators',
            builder     => '_build_password_generators',
            lazy        => 1,
            handies     => [{
                name        => 'get_password_generator',
                default     => $default_password_generator_id,
                strict      => 1
            }]
        )
    );

    my $logger = $self->get_logger;
    $logger->tracef("We've got the set of command-line parameters: %s",
        $self->get_parameters
    );
    $logger->tracef("We've got the configuration: %s",
        $self->get_configuration
    );
    $logger->tracef("We've got the primary (%s) logger instance: %s",
        $default_logger_id,
        $self->get_logger
    );
    $logger->tracef("We've got the primary (%s) CloudStack instance: %s",
        $default_cloudstack_id,
        $self->get_cloudstack
    );
    $logger->tracef("We've got the primary (%s) password generator instance: %s",
        $default_password_generator_id,
        $self->get_password_generator
    );

    $logger->tracef("We've got the framework %s initialized by PID %d at %s",
        $self,
        $$,
        $self->get_time_started_formatted
    );
    $logger->debugf("<%s> The framework has been initialized",
        $self->get_time_passed_formatted,
        $self
    );

    if($parameters->get_mm_show_help) {
        $self->print_full_version_info;
        $self->print_full_usage_help;
        exit;
    } elsif($parameters->get_mm_show_version) {
        $self->print_full_version_info;
        exit;
    }

}



method _app_start {

    $self->get_logger->debugf("<%s> The application has been started",
        $self->get_time_passed_formatted
    );

}



method _app_run {

    &{ $self->{app_code}; }($self);

    $self->get_logger->debugf("<%s> The application has been executed",
        $self->get_time_passed_formatted
    );

}



method _app_finish {

    $self->get_logger->debugf("<%s> The application has been finished",
        $self->get_time_passed_formatted
    );

}



method _mm_shutdown {

    $self->get_logger->debugf("<%s> The framework is shutting itself down",
        $self->get_time_passed_formatted,
        $self
    )
        if($self->can('get_logger'));

}



method print_full_version_info {

    printf(<<__END_OF_VERSION_INFO__
%s (%s) driven by MonkeyMan (%s):

    %s

__END_OF_VERSION_INFO__
        ,   $self->get_app_name,
            $self->get_app_version,
            $self->get_mm_version,
            $self->get_app_description,
    );

}



method print_full_usage_help {

    my $app_usage_help = ref($self->get_app_usage_help) eq 'CODE' ?
        &{ $self->get_app_usage_help } :
           $self->get_app_usage_help;

    printf(<<__END_OF_USAGE_HELP__
%sIt%shandles the following set of MonkeyMan-wide parameteters:

    -h, --help
        [opt]       Print usage help text and do nothing
    -V, --version
        [opt]       Print version number and do nothing
    -c <filename>, --configuration <filename>
        [opt]       The main configuration file
    --default-cloudstack <ID>
        [opt]       The default Apache CloudStack connector
    --default-logger <ID>
        [opt]       The default Logger
    -v, --verbose
        [opt] [mul] Increases verbosity
    -q, --quiet
        [opt] [mul] Decreases verbosity

__END_OF_USAGE_HELP__
        , $app_usage_help ? ($app_usage_help . "\n") : ''
        , $app_usage_help ? ' also ' : ' '
    );

}



#__PACKAGE__->meta->make_immutable;

1;



=head1 HOW IT WORKS

...

=cut
