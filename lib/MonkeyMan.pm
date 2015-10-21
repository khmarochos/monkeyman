package MonkeyMan;

=head1 NAME

MonkeyMan - Apache CloudStack Management Framework

=head1 SYNOPSIS

    use MonkeyMan;

    my %opts;

    MonkeyMan->new(
        application         => \&MyCoolApplication,
        parse_parameters    => {
            'l|line=s' => 'what_to_say'
        }
    );

    sub MyCoolApplication {

        my $mm = shift;

        $mm->log->info->f(
            "We were asked to say '%s'",
            $mm->parameters->{'what_to_say'}
        );

        MonkeyMan::Expection::Bored->throw(
            "I'm feeling too bored, so I'm going to stop working"
        );

    }

=cut

use strict;
use warnings;

use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Exception;
use MonkeyMan::Parameters;
use MonkeyMan::Configuration;
use MonkeyMan::CloudStack;
use MonkeyMan::Logger;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
use namespace::autoclean;

# Use 3rd-party libraries
use TryCatch;
use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper; # Only for debugging



has 'mm_version' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => 'get_mm_version',
    builder     => '_build_mm_version',
    init_arg    => undef
);

sub _build_mm_version {

    MM_VERSION;

}

=head1 PARAMETERS

=head2 C<application>

A reference to the subroutine that will do all the job.

=cut

has 'application' => (
    is      => 'ro',
    isa     => 'CodeRef'
);

has 'app_name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 'yes',
    reader      =>  'get_app_name',
    writer      => '_set_app_name'
);

has 'app_description' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 'yes',
    reader      =>  'get_app_description',
    writer      => '_set_app_description'
);

has 'app_version' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 'yes',
    reader      =>  'get_app_version',
    writer      => '_set_app_version'
);

has 'app_usage_help' => (
    is          => 'ro',
    isa         => 'CodeRef',
    required    => 'yes',
    reader      =>  'get_app_usage_help',
    writer      => '_set_app_usage_help'
);

=head2 C<parse_parameters>, C<parameters>

This attribute requires a reference to a hash containing parameters to be
passed to the C<Getopt::Long-E<gt>GetOptions()> method (on the left)
corresponding names of sub-methods to get values of startup parameters. It
creates the C<parameters> method which returns a reference to the
C<MonkeyMan::Parameters> object containing the information of startup
parameters accessible via corresponding methods. Thus,

    'parse_parameters'      => {
        'i|input=s'     => 'file_in',
        'o|output=s'    => 'file_out'
    }

will create C<MonkeyMan::Parameters> object with C<file_in> and C<file_out>
methods, so you could address them as

    $mm->parameters->file_in,
    $mm->parameters->file_out

=cut

has 'parse_parameters' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => '_has_parse_parameters',
    reader      => '_get_parse_parameters',
    lazy        => 0
);

has 'parameters' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Parameters',
    reader      => '_get_parameters',
    writer      => '_set_parameters',
    builder     => '_build_parameters',
    alias       => 'parameters',
    lazy        => 1
);

sub _build_parameters {

    my $self = shift;

    MonkeyMan::Parameters->new(mm => $self)

}

has 'configuration' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Configuration',
    reader      => 'has_configuration',
    reader      => 'get_configuration',
    writer      => '_set_configuration',
    builder     => '_build_configuration',
    alias       => 'configuration',
    lazy        => 1
);

sub _build_configuration {

    my $self = shift;

    my $config = Config::General->new(
        -ConfigFile         => (
            defined($self->parameters->mm_configuration) ?
                    $self->parameters->mm_configuration :
                    MM_CONFIG_MAIN
        ),
        -UseApacheInclude   => 1,
        -ExtendedAccess     => 1
    );

    my %configuration = $config->getall;

    MonkeyMan::Configuration->new(
        mm      => $self,
        tree    => \%configuration
    );

}

has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      => '_get_logger',
    writer      => '_set_logger',
    builder     => '_build_logger',
    alias       => 'logger',
    lazy        => 1
);

sub _build_logger {

    my $self = shift;

    MonkeyMan::Logger->new(mm => $self);

}

has 'cloudstacks' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => 'get_cloudstacks',
    writer      => '_set_cloudstacks',
    builder     => '_build_cloudstacks',
    alias       => 'cloudstacks',
    lazy        => 1
);

sub _build_cloudstacks {

    my $self = shift;

    my %cloudstacks = (
        &MM_CLOUDSTACK_PRIMARY => MonkeyMan::CloudStack->new(
            monkeyman           => $self,
            configuration_tree  => $self->configuration->tree->{'cloudstack'}
        )
    );

    my $meta = $self->meta;
    $meta->add_method(
        cloudstack  => sub { shift->cloudstacks->{&MM_CLOUDSTACK_PRIMARY}; }
    );

    return(\%cloudstacks);

}



sub _mm_init {

    my $self = shift;

    if($self->parameters->mm_show_help) {
        $self->print_full_version_info;
        $self->print_full_usage_help;
        exit;
    } elsif($self->parameters->mm_show_version) {
        $self->print_full_version_info;
        exit;
    }

    $self->logger->tracef("We've got the set of command-line parameters: %s",
        $self->parameters
    );

    $self->logger->tracef("We've got the configuration: %s",
        $self->configuration
    );

    $self->logger->tracef("We've got the logger: %s",
        $self->logger
    );

    $self->logger->tracef("We've got the primapy CloudStack instance: %s",
        $self->get_cloudstacks->{&MM_CLOUDSTACK_PRIMARY}
    );

    $self->logger->debugf("The framework has been initialized: %s", $self);

}



sub _app_start {

    my $self = shift;

    $self->logger->debug("The application has been started");

}



sub _app_run {

    my $self = shift;

    &{ $self->{application}; }($self);

}



sub _app_finish {

    my $self = shift;

    $self->logger->debug("The application has been finished");

}



sub _mm_shutdown {

    my $self = shift;

    $self->logger->debugf("The %s framework is shutting itself down", $self);
}



sub print_full_version_info {

    my $self = shift;

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



sub print_full_usage_help {

    my $self = shift;

    my $app_usage_help =
        (ref($self->get_app_usage_help)) ?
            &{ $self->get_app_usage_help } : '';

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



sub BUILD {

    my $self = shift;

    $self->_mm_init;
    $self->_app_start;
    $self->_app_run;
    $self->_app_finish;
    $self->_mm_shutdown;

}



sub BUILDARGS {

    my $self = shift;
    my %args = @_;

    $args{'parse_parameters'}->{'h|help'}           = 'mm_show_help';
    $args{'parse_parameters'}->{'V|version'}        = 'mm_show_version';
    $args{'parse_parameters'}->{'c|configuration'}  = 'mm_configuration';
    $args{'parse_parameters'}->{'v|verbose+'}       = 'mm_be_verbose';
    $args{'parse_parameters'}->{'q|quiet+'}         = 'mm_be_quiet';

    return(\%args);

}



#__PACKAGE__->meta->make_immutable;

1;
