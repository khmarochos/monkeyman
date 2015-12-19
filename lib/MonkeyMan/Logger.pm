package MonkeyMan::Logger;

=head1 NAME

MonkeyMan::Logger - MonkeyMan's chronicler :)

=cut

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

use MonkeyMan::Constants qw(:filenames :logging);
use MonkeyMan::Utils;
use MonkeyMan::Exception;

# Use 3rd-party libraries
use TryCatch;
use Log::Log4perl qw(:no_extra_logdie_message);



has 'configuration_string' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => '_get_configuration_string',
    writer      => '_set_configuration_string',
    predicate   => '_has_configuration_string'
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

has 'log4perl_loggers' => (
    is          => 'ro',
    isa         => 'HashRef',
    init_arg    => undef,
    reader      =>   '_get_log4perl_loggers',
    writer      =>   '_set_log4perl_loggers',
    predicate   =>   '_has_log4perl_loggers',
    builder     => '_build_log4perl_loggers',
    lazy        => 1
);

has 'dumped' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => 'get_dumped'
);

sub _build_log4perl_loggers {

    return({});

}



sub BUILD {

    my $self = shift;

    unless(Log::Log4perl->initialized) {

        # Okay, shall we any some certain configuration or we should get it
        # from some configuration file?

        my $log_configuration;
        if($self->_has_configuration_string) {
            $log_configuration = $self->_get_configuration_string;
        } else {
            my $log_configuration_file = $self->_has_configuration_file ?
                $self->_get_configuration_file :
                defined($self->get_monkeyman->get_configuration->get_tree->{'log'}->{'conf'}) ?
                        $self->get_monkeyman->get_configuration->get_tree->{'log'}->{'conf'} :
                        MM_CONFIG_LOGGER;
            open(
                my $log_configuration_filehandle, '<', $log_configuration_file
            ) ||
                MonkeyMan::Exception->throwf(
                    "Can't load logger's configuration from %s: %s",
                    $log_configuration_file,
                    $!
                );
            while(<$log_configuration_filehandle>) {
                $log_configuration .= $_;
            }
            close($log_configuration_filehandle);
        }

        Log::Log4perl->init_once(\$log_configuration);

        my $log_console_level = $self->_has_console_verbosity ?
            $self->_get_console_verbosity : (
                MM_VERBOSITY_LEVEL_BASE + (
                    defined($self->get_monkeyman->get_parameters->mm_be_verbose) ?
                            $self->get_monkeyman->get_parameters->mm_be_verbose :
                            0
                ) - (
                    defined($self->get_monkeyman->get_parameters->mm_be_quiet) ?
                            $self->get_monkeyman->get_parameters->mm_be_quiet :
                            0
                )
            );
        my $logger_console_appender = Log::Log4perl::Appender->new(
            'Log::Log4perl::Appender::Screen',
            name            => 'console',
            stderr          => 1,
        );
        my $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
            '%d [%p{1}] [%c] %m%n'
        );
        $logger_console_appender->layout($logger_console_layout);
        $logger_console_appender->threshold((&MM_VERBOSITY_LEVELS)[$log_console_level]);
        $self->find_log4perl_logger('')->add_appender($logger_console_appender);

    }

    # Initialize helpers

    foreach my $helper_name (qw(fatal error warn info debug trace)) {

        my $log_straight    = sub {
            shift->find_log4perl_logger((caller(0))[0])->$helper_name(
                "@_"
            );
        };
        my $log_formatted   = sub {
            shift->find_log4perl_logger((caller(0))[0])->$helper_name(
                mm_sprintf(@_)
            );
        };

        $self->meta->add_method(
            $helper_name => Class::MOP::Method->wrap(
                $log_straight, (
                    name            => $helper_name,
                    package_name    => __PACKAGE__
                )
            )
        );
        $self->meta->add_method(
            $helper_name . 'f' => Class::MOP::Method->wrap(
                $log_formatted, (
                    name            => $helper_name . 'f',
                    package_name    => __PACKAGE__
                )
            )
        );

    }

}



sub find_log4perl_logger {
    my $self    = shift;
    my $module  = shift;
    $self->_get_log4perl_loggers->{$module} ?
        $self->_get_log4perl_loggers->{$module} :
       ($self->_get_log4perl_loggers->{$module} = Log::Log4perl->get_logger($module));
}



1;
