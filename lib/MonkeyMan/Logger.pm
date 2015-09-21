package MonkeyMan::Logger;

=head1 NAME

MonkeyMan::Logger - MonkeyMan's chronicler :)

=cut

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

use MonkeyMan::Constants qw(:filenames :logging);
use MonkeyMan::Utils;
use MonkeyMan::Exception;

# Use 3rd-party libraries
use TryCatch;
use Text::Template;
use Log::Log4perl qw(:no_extra_logdie_message);



has 'configuration' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => '_get_configuration',
    writer      => '_set_configuration',
    predicate   => '_has_configuration'
);

has 'configuration_file' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => '_get_configuration_file',
    writer      => '_set_configuration_file',
    predicate   => '_has_configuration_file'
);

has 'console_verbosity' => (
    is          => 'ro',
    isa         => 'Int',
    reader      => '_get_console_verbosity',
    writer      => '_set_console_verbosity',
    predicate   => '_has_console_verbosity'
);

has 'log4perl' => (
    is          => 'ro',
    isa         => 'Log::Log4perl::Logger',
    reader      => 'get_log4perl',
    writer      => '_set_log4perl',
);



sub BUILD {

    my $self = shift;

    unless(Log::Log4perl->initialized) {

        # If the console log-level haven't been defined with the corresponding
        # parrameter, we'll need to calculate it leaning on -q and -v parameters

        my $log_console_level = $self->_has_console_verbosity ?
            $self->_get_console_verbosity : (
                MM_VERBOSITY_LEVEL_BASE + (
                    defined($self->mm->got_options->be_verbose) ?
                            $self->mm->got_options->be_verbose :
                            0
                ) - (
                    defined($self->mm->got_options->be_quiet) ?
                            $self->mm->got_options->be_quiet :
                            0
                )
            );

        # We should be more informative on higher levels

        my $log_console_pattern = ($log_console_level > 4) ?
            '%d %m%n' :
            '%d [%p{2}] %m%n';

        # Okay, shall we use some certain configuration or we should get it from
        # some configuration file?

        my $log_configuration_file = $self->_has_configuration_file ?
            $self->_get_configuration_file :
            MM_CONFIG_LOGGER;

        my $log_configuration_template = $self->_has_configuration ?
            Text::Template->new(
                TYPE        => 'STRING',
                SOURCE      => $self->_get_configuration,
                DELIMITERS  => ['<%', '%>']
            ) :
            Text::Template->new(
                TYPE        => 'FILE',
                SOURCE      => $log_configuration_file,
                DELIMITERS  => ['<%', '%>']
            ) ||
                MonkeyMan::Exception->throwf(
                    "Can't load logger's configuration from %s: %s",
                        $self->_has_configuration ?
                            'from the string' :
                            "from the $log_configuration_file file",
                        $!
                );
        my $log_configuration = $log_configuration_template->fill_in(
            HASH => {
                log_console_loglevel => (&MM_VERBOSITY_LEVELS)[$log_console_level],
                log_console_pattern  => $log_console_pattern
            }
        );

        Log::Log4perl::init_once(\$log_configuration);

    }

    $self->_set_log4perl(Log::Log4perl::get_logger(__PACKAGE__));

    foreach my $method_name (qw(error warn info debug trace)) {
        $self->_create_wrapper($method_name);
    }

}


sub _create_wrapper {

    my $self        = shift;
    my $method_name = shift;

    die("Haven't got a valid wrapper's name")
        unless($method_name =~ /^[\w\d_]+$/);

    my $log_straight    = sub {
        shift->get_log4perl->$method_name(@_);
    };
    my $log_formatted   = sub {
        shift->get_log4perl->$method_name(mm_sprintf(@_));
    };

    $self->meta->add_method(
        $method_name => Class::MOP::Method->wrap(
            $log_straight, (
                name            => $method_name,
                package_name    => __PACKAGE__
            )
        )
    );
    $self->meta->add_method(
        $method_name . 'f' => Class::MOP::Method->wrap(
            $log_formatted, (
                name            => $method_name . 'f',
                package_name    => __PACKAGE__
            )
        )
    );

}



1;
