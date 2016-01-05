package MonkeyMan;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
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

# Use 3rd-party libraries
use MooseX::Handies;
use MooseX::Singleton;
use Method::Signatures;
use TryCatch;
use Getopt::Long qw(:config no_ignore_case);
use Config::General;



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

has 'app_code' => (
    is          => 'ro',
    isa         => 'CodeRef',
    reader      => 'get_app_code',
    predicate   => 'has_app_code'
);

has 'app_name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_name',
    writer      => '_set_app_name'
);

has 'app_description' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_description',
    writer      => '_set_app_description'
);

has 'app_version' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_version',
    writer      => '_set_app_version'
);

has 'app_usage_help' => (
    is          => 'ro',
    isa         => 'CodeRef',
    required    => 0,
    reader      =>  'get_app_usage_help',
    predicate   =>  'has_app_usage_help',
    writer      => '_set_app_usage_help'
);

has 'parameters_to_get' => (
    is          => 'ro',
    isa         => 'HashRef[Str]',
    predicate   => '_has_parameters_to_get',
    reader      => '_get_parameters_to_get',
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



has 'loggers' => (
    is          => 'ro',
    isa         => 'HashRef[MonkeyMan::Logger]',
    reader      =>   '_get_loggers',
    writer      =>   '_set_loggers',
    builder     => '_build_loggers',
    lazy        => 1,
    handies     => [{
        name        => 'get_logger',
        default     => &MM_PRIMARY_LOGGER,
        strict      => 1
    }]
);

method _build_loggers {

    return({ 
        &MM_PRIMARY_LOGGER => MonkeyMan::Logger->new(
            monkeyman => $self
        )
    });

}




has 'cloudstacks' => (
    is          => 'ro',
    isa         => 'HashRef[MonkeyMan::CloudStack]',
    reader      =>   '_get_cloudstacks',
    writer      =>   '_set_cloudstacks',
    builder     => '_build_cloudstacks',
    lazy        => 1,
    handies     => [{
        name        => 'get_cloudstack',
        default     => &MM_PRIMARY_CLOUDSTACK,
        strict      => 1
    }]
);

method _build_cloudstacks {

    return({
        &MM_PRIMARY_CLOUDSTACK => MonkeyMan::CloudStack->new(
            monkeyman       => $self,
            configuration   => $self
                                ->get_configuration
                                    ->{'cloudstack'}
                                        ->{&MM_PRIMARY_CLOUDSTACK}
        )
    });

}



method _mm_init {

    my $parameters  = $self->get_parameters;
    my $logger      = $self->get_logger;

    if($parameters->get_mm_show_help) {
        $self->print_full_version_info;
        $self->print_full_usage_help;
        exit;
    } elsif($parameters->get_mm_show_version) {
        $self->print_full_version_info;
        exit;
    }

    $logger->tracef("We've got the set of command-line parameters: %s",
        $parameters
    );

    $logger->tracef("We've got the configuration: %s",
        $self->get_configuration
    );

    $logger->tracef("We've got the primary logger instance: %s",
        $self->_get_loggers->{&MM_PRIMARY_LOGGER}
    );

    $logger->tracef("We've got the primapy CloudStack instance: %s",
        $self->_get_cloudstacks->{&MM_PRIMARY_CLOUDSTACK}
    );

    $logger->tracef("We've got the framework %s initialized by PID %d at %s",
        $self,
        $$,
        $self->get_time_started_formatted
    );

    $logger->debugf("%s The framework has been initialized",
        $self->get_time_passed_formatted,
        $self
    );

}



method _app_start {

    $self->get_logger->debugf("%s The application has been started",
        $self->get_time_passed_formatted
    );

}



method _app_run {

    &{ $self->{app_code}; }($self);

    $self->get_logger->debugf("%s The application has run",
        $self->get_time_passed_formatted
    );

}



method _app_finish {

    $self->get_logger->debugf("%s The application has finished",
        $self->get_time_passed_formatted
    );

}



method _mm_shutdown {

    $self->get_logger->debugf("%s The framework is shutting itself down",
        $self->get_time_passed_formatted,
        $self
    );

}



method print_full_version_info {

    printf(<<__END_OF_VERSION_INFO__
%s (v%s) driven by MonkeyMan (v%s):

    %s

__END_OF_VERSION_INFO__
        ,   $self->get_app_name,
            $self->get_app_version,
            $self->get_mm_version,
            $self->get_app_description,
    );

}



method print_full_usage_help {

    my $app_usage_help = (
            $self->has_app_usage_help &&
        ref($self->get_app_usage_help) eq 'CODE'
    ) ?
        &{ $self->get_app_usage_help } :
        '';

    printf(<<__END_OF_USAGE_HELP__
%sIt%shandles the following set of MonkeyMan-wide parameteters:

    -h, --help
        [opt]       Print usage help text and do nothing
    -V, --version
        [opt]       Print version number and do nothing
    -c <filename>, --configuration <filename>
        [opt]       The main configuration file
    -v, --verbose
        [opt] [mul] Increases verbosity
    -q, --quiet
        [opt] [mul] Decreases verbosity

__END_OF_USAGE_HELP__
        , $app_usage_help ? ($app_usage_help . "\n") : ''
        , $app_usage_help ? ' also ' : ' '
    );

}



method BUILD(...) {

    $self->get_logger->debugf("%s Hello, world!", $self->get_time_passed_formatted);

    $self->_mm_init;
    $self->_app_start;
    $self->_app_run;
    $self->_app_finish;
    $self->_mm_shutdown;

}



method BUILDARGS(...) {

    my %args = @_;

    $args{'parameters_to_get'}->{'h|help'}              = 'mm_show_help';
    $args{'parameters_to_get'}->{'V|version'}           = 'mm_show_version';
    $args{'parameters_to_get'}->{'c|configuration=s'}   = 'mm_configuration';
    $args{'parameters_to_get'}->{'v|verbose+'}          = 'mm_be_verbose';
    $args{'parameters_to_get'}->{'q|quiet+'}            = 'mm_be_quiet';

    return(\%args);

}



#__PACKAGE__->meta->make_immutable;

1;



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
        parse_parameters    => {
            'd|domain_id=s' => 'domain_id'
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
    # 2040/04/20 04:20:00 [I] [main] The  virtual machine's ID is 01234567-dead-beef-cafe-899123456789 - got as [MonkeyMan::CloudStack::API::Element::VirtualMachine@0xdeadbee/badcaffedeadfacefeeddeafbeefbabe]
    # 
    # Hope you'll enjoy it :)
    #

=head1 MODULE HIERARCHY

...

=head1 METHODS

=head2 C<new()>

    MonkeyMan->new(%parameters => %Hash)

This method initializes the framework and runs the application.

There are a few parameters that can (and need to) be defined:

=head3 MonkeyMan Application-Related Parameters

=head4 C<app_code>

MANDATORY. Contains a C<CodeRef> pointing to the code of the application that
needs to be run. The reader's name is C<get_app_code>.

=head4 C<app_name>

MANDATORY. Contains a C<Str> of the application's full name. The reader's name
is C<get_app_name>.

=head4 C<app_description>

MANDATORY. Contains a C<Str> of the application's description. The reader's name
is C<get_app_description>.

=head4 C<app_version>

MANDATORY. Contains a C<Str> of the application's version number. The reader's
name is C<get_app_version>.

=head4 C<app_usage_help>

Optional. Contains a C<Str> to be displayed when the user asks for help. The
reader's name is C<get_app_usage_help>.

=head3 MonkeyMan Configuration-Related Parameters

=head4 C<parameters_to_get>

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

=head4 C<configuration>

Optional. Contains a reference to the hash containing the framework's
configuration tree. If it's not defined (in most cases), the framework will try
to parse the configuration file. The name of the file can be passed with the
C<-c|--configuration> startup parameter.

    # MM_DIRECTORY_ROOT/etc/monkeyman.conf contains:
    #          <log>
    #  .           <PRIMARY>
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

=head3 MonkeyMan Helpers-Related Parameters

=head4 C<loggers>

Optional. Contains a C<HashRef> with links to L<MonkeyMan::Logger>
modules, so you can use multiple interfaces to multiple cloudstack with the
C<get_logger()> method described below.

=head4 C<cloudstacks>

Optional. Contains a C<HashRef> with links to L<MonkeyMan::CloudStack> modules.
The C<get_cloudstack()> method helps to get the CloudStack instance by its
handle is described below.

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
requested. If the ID hasn't been specified, it returns the instance identified
as C<PRIMARY>.

    ok($mm->get_logger() == $mm->get_logger(&MM_PRIMARY_LOGGER));
    ok($mm->get_logger() == $mm->get_logger('PRIMARY');

The C<PRIMARY> logger is being initialized proactively by the framework, but
it's also possible to initialize it by oneself in the case will you need it.

    %my_loggers = (&MM_PRIMARY_LOGGER => MonkeyMan::Logger->new(...));
    $mm = MonkeyMan->new(loggers => \%my_loggers, ...);

Please, keep in mind that C<PRIMARY> is the default logger's handle, it's
defined by the C<MM_PRIMARY_LOGGER> constant.

The C<get_loggers> returns the reference to the hash containing the loggers'
index, which means the following:

    ok($mm->get_logger('Log-13') == $mm->get_loggers->{'Log-13'});

=head2 get_cloudstack()

=head2 get_cloudstacks()

These accessors behaves very similar to C<get_logger()> and C<get_loggers()>,
but the index contains references to L<MonkeyMan::CloudStack> objects
initialized. The default CloudStack instance's name is C<PRIMARY>, it's defined
as the C<MM_PRIMARY_CLOUDSTACK> constant.

=head2 get_mm_version()

The name of the method is pretty self-descriptive: the accessor returns the
framework's version ID.

=head1 HOW IT WORKS

...

=cut
