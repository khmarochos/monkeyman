package MonkeyMan;

=head1 NAME

MonkeyMan - Apache CloudStack Management Framework

=head1 SYNOPSIS

    use MonkeyMan;

    my %opts;

    MonkeyMan->new(
        application => \&MyCoolApplication,
        get_options => {
            'l|line=s' => 'what_to_say'
        }
    );

    sub MyCoolApplication {

        my $mm = shift;

        $mm->log->info->f(
            "We were asked to say '%s'",
            $mm->got_options->{'what_to_say'}
        );

        MonkeyMan::Expection::Bored->throw(
            "I'm feeling bored, so I'm going to stop working"
        );

    }

=cut

use strict;
use warnings;

use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Exception;
use MonkeyMan::GotOptions;
use MonkeyMan::Logger;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
use MooseX::UndefTolerant;
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

=head2 C<get_options>

This attribute requires a reference to a hash containing parameters to be
passed to the C<Getopt::Long-E<gt>GetOptions()> method (on the left)
corresponding names of sub-methods to get values of startup parameters. It
creates the C<got_options> method which returns a reference to the
C<MonkeyMan::GotOptions> object containing the information of startup
parameters accessible via corresponding methods. So,

    'get_options'   => {
        'i|input=s'     => 'file_in',
        'o|output=s'    => 'file_out'
    }

would create C<MonkeyMan::GotOptions> object with C<get_file_in> and
C<get_file_out> methods, you could address them as

    $mm->got_options->file_in,
    $mm->got_options->file_out

=cut

has 'get_options' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   => '_has_get_options',
    reader      => '_get_get_options'
);

has 'got_options' => (
    is          => 'ro',
    isa         => 'MonkeyMan::GotOptions',
    reader      => '_get_got_options',
    alias       => 'got_options',
    builder     => '_build_got_options',
    lazy        => 1,
    init_arg    => undef
);

sub _build_got_options {

    my $self = shift;

    MonkeyMan::GotOptions->new(mm => $self)

}

has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      => '_get_logger',
    writer      => '_set_logger',
    alias       => 'logger',
    builder     => '_build_logger',
    lazy        => 1
);

sub _build_logger {

    my $self = shift;

    MonkeyMan::Logger->new(mm => $self);

}



sub _app_start {

    my $self = shift;

    # We shall initialize option's parser, as we'll need to know some
    # parameters shortly

    if($self->got_options->show_help) {
        $self->print_full_version_info;
        $self->print_full_usage_help;
        exit;
    } elsif($self->got_options->show_version) {
        $self->print_full_version_info;
        exit;
    }

    #FIXME: We should fetch it from the global configuration file

    my $log4perl_conf;

    $self->_set_logger(MonkeyMan::Logger->new(
        mm                  => $self,
        configuration_file  => $log4perl_conf
    ));

    $self->logger->tracef(
        "The logger has been initialized: %s",
        $self->logger
    );

}



sub _app_run {

    my $self = shift;

    &{ $self->{application}; }($self);

}



sub _app_finish {

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
    -c <file>, --config <file>
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

    try {
        $self->_app_start;
    } catch($e) {
        MonkeyMan::Exception->throwf("Can't initialize the application: %s", $e),
    }

    try {
        $self->_app_run;
    } catch($e) {
        die("An error occuried while running the application: $e");
    }

    try {
        $self->_app_finish;
    } catch($e) {
        die("An error occuried while finishing the application: $e");
    }

}



sub BUILDARGS {

    my $self = shift;
    my %args = @_;

    $args{'get_options'}->{'h|help'}        = 'show_help';
    $args{'get_options'}->{'V|version'}     = 'show_version';
    $args{'get_options'}->{'v|verbose+'}    = 'be_verbose';
    $args{'get_options'}->{'q|quiet+'}      = 'be_quiet';

    return(\%args);

}



__PACKAGE__->meta->make_immutable;

1;
