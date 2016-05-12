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
use MonkeyMan::Utils qw(mm_sprintf);
use MonkeyMan::Exception;

# Consume some roles
with 'MonkeyMan::Roles::WithTimer';

# Use 3rd-party libraries
use Method::Signatures;
use TryCatch;
use File::Slurp;
use Log::Log4perl qw(:no_extra_logdie_message);



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>  'get_configuration',
    writer      => '_set_configuration',
    predicate   => '_has_configuration',
);

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

method _build_log4perl_loggers {

    return({});

}

#   has 'dumped' => (
#       is          => 'ro',
#       isa         => 'Str',
#       reader      => 'get_dumped'
#   );



method BUILD(...) {

    unless(Log::Log4perl->initialized) {

        # Okay, shall we any some certain configuration or we should get it
        # from some configuration file?

        my $log4perl_configuration;
        if($self->_has_configuration_string) {
            $log4perl_configuration = $self->_get_configuration_string;
        } else {
            my $log_configuration_file = $self->_has_configuration_file ?
                $self->_get_configuration_file :
                defined($self->get_configuration->{'conf'}) ?
                        $self->get_configuration->{'conf'} :
                        MM_CONFIG_LOGGER;
            $log4perl_configuration = read_file($log_configuration_file)
        }

        Log::Log4perl->init_once(\$log4perl_configuration);

        my $log_console_level = $self->_has_console_verbosity ?
            $self->_get_console_verbosity : (
                MM_VERBOSITY_LEVEL_BASE + (
                    defined($self->get_monkeyman->get_parameters->get_mm_be_verbose) ?
                            $self->get_monkeyman->get_parameters->get_mm_be_verbose :
                            0
                ) - (
                    defined($self->get_monkeyman->get_parameters->get_mm_be_quiet) ?
                            $self->get_monkeyman->get_parameters->get_mm_be_quiet :
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



method find_log4perl_logger(Str $module!) {
    $self->_get_log4perl_loggers->{$module} ?
        $self->_get_log4perl_loggers->{$module} :
       ($self->_get_log4perl_loggers->{$module} = Log::Log4perl->get_logger($module));
}



1;
