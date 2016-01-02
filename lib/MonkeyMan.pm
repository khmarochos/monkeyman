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
use MonkeyMan::Exception;
use MonkeyMan::Parameters;
use MonkeyMan::Configuration;
use MonkeyMan::CloudStack;
use MonkeyMan::Logger;

# Use 3rd-party libraries
use MooseX::Handies;
use MooseX::Singleton;
use Method::Signatures;
use TryCatch;
use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper; # Only for debugging



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
    isa         => 'MonkeyMan::Configuration',
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

    my %configuration = $config->getall;

    MonkeyMan::Configuration->new(
        monkeyman   => $self,
        tree        => \%configuration
    );

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

    my %loggers = (
        &MM_PRIMARY_LOGGER => MonkeyMan::Logger->new(
            monkeyman => $self
        )
    );

    \%loggers;

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

    my %cloudstacks = (
        &MM_PRIMARY_CLOUDSTACK => MonkeyMan::CloudStack->new(
            monkeyman           => $self,
            configuration_tree  => $self->get_configuration->get_tree->{'cloudstack'}
        )
    );

    \%cloudstacks;

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
    -c <file>, --configuration <file>
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
L<Apache CloudStack|http://cloudstack.apache.org/>-based cloud infrastructure
with high-level Perl5-applications.

=begin markdown

![The mascot has been originaly created by D.Kolesnichenko for Tucha.UA](http://tucha.ua/wp-content/uploads/2013/08/monk.png)

=end markdown

=head1 SYNOPSIS

    MonkeyMan->new(
        app_code            => \&MyCoolApplication,
        parse_parameters    => {
            'd|domain_id=s' => 'domain_id'
        }
    );

    sub MyCoolApplication {

        my $mm  = shift;
        my $log = $mm->get_logger;

        $log->debugf("We were asked to find the '%s' domain",
            $mm->get_parameters->domain_id
        );

        my $api = $mm->get_cloudstack->get_api;

        # Find the domain by its ID
        foreach my $d ($api->get_elements(
            type        => 'Domain',
            criterions  => { id  => '01234567-89ab-cdef-0123-456789abcdef' }
        )) {

            # Find the virtual machines related to the domain
            foreach my $vm ($d->get_related(type => 'VirtualMachine')) {
                $log->infof("The %s %s's ID is %s\n",
                    $vm,
                    $vm->get_type(noun => 1),
                    $vm->get_id
                );
            }

        }

    }

=head1 METHODS

=head2 C<new>

    MonkeyMan->new(%parameters => %Hash)

This method initializes the framework and runs the application.

There are a few parameters that can (and need to) be defined:

=over

=item C<app_code> (CodeRef)

MANDATORY.  The reference to the subroutine that will do all the job.

=item C<app_name> (Str)

MANDATORY. The application's full name.

=item C<app_description> (Str)

MANDATORY. The application's description.

=item C<app_version> (Str)

MANDATORY. The application's version number.

=item C<app_usage_help> (Str)

Optional. The text to be displayed when the user asks for help.

=item C<parameters_to_get> (HashRef)

Optional. This parameter shall be a reference to a hash containing parameters
to be passed to the L<Getopt::Long-E<gt>GetOptions()> method (on the left
corresponding names of accessors to values of startup parameters. It sets the
the C<parameters> attribute which returns a reference to the
L<MonkeyMan::Parameters> object containing the information about startup
parameters. Thus,

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

The print-help-and-exit mode. Sets the C<mm_show_help> attribute, the accessor
is C<get_mm_show_help>.

=item C<-V>, C<--version>

The print-version-and-exit mode. Sets the C<mm_show_version> attribute, the
accessor is C<get_mm_show_version>.

=item C<-c [filename]>, C<--configuration=[filename]>

The name of the main configuration file. Sets the C<mm_configuration>
attribute. The accessor is C<get_mm_configuration>.

=item C<-v>, C<--verbose>

Increases the debug level. Sets the C<mm_be_verbose> attribute, the accessor is
C<get_mm_be_verbose>.

=item C<-q>, C<--quiet>

Decreases the debug level. Sets the C<mm_be_quiet> attribute, the accessor is
is C<get_mm_be_quiet>.

=back

=item C<configuration> (L<MonkeyMan::Configuration>)

Optional. You can create a configuration object and pass its reference to
the framework. If it's not defined, the framework will try to fetch the
configuration from the file. The name of the configuration file can be passed
with the C<-c|--configuration> startup parameter.

=back

=head2

=cut
