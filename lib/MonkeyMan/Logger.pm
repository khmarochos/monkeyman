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
use MonkeyMan::Utils qw(mm_showref);
use MonkeyMan::Exception;

# Use 3rd-party libraries
use Method::Signatures;
use TryCatch;
use File::Slurp;
use Term::ANSIColor;
use Log::Log4perl qw(:no_extra_logdie_message);

use constant CONSOLE_LOGGER => 'CONSOLE';



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

has 'console_colored' => (
    is          => 'ro',
    isa         => 'Int',
    reader      => '_get_console_colored',
    writer      => '_set_console_colored',
    predicate   => '_has_console_colored'
);

has 'console_colorscheme' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_console_colorscheme',
    writer      =>   '_set_console_colorscheme',
    predicate   =>   '_has_console_colorscheme',
    builder     => '_build_console_colorscheme',
    lazy        => 1
);

method _build_console_colorscheme {
    return($self->get_configuration->{'colorscheme'});
}

method _get_console_color(Str $class? = 'NORMAL', HashRef $colorscheme? = $self->_get_console_colorscheme) {
    return(
        (
            defined($colorscheme) &&
            defined($colorscheme->{$class})
        ) ?
            color($colorscheme->{$class}) :
            color('reset')
    );
}

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

        # Let's prepare the Log::Log4perl configuration
        my $log4perl_configuration;
        if($self->_has_configuration_string) {
            # When the Log4perl configuration is given as a big string value
            $log4perl_configuration = $self->_get_configuration_string;
        } else {
            # Otherwise we'll try to fetch it from a file
            my $log_configuration_file = $self->_has_configuration_file ?
                # Is the file's name given in an attribute?
                $self->_get_configuration_file :
                defined($self->get_configuration->{'conf'}) ?
                    # Is the file's name fiven in a configuration structure?
                        $self->get_configuration->{'conf'} :
                        MM_CONFIG_LOGGER;
            # OK, let's read it from the file
            $log4perl_configuration = read_file($log_configuration_file)
        }

        Log::Log4perl->init_once(\$log4perl_configuration);
        Log::Log4perl->wrapper_register(__PACKAGE__);

        $self->_set_console_verbosity($self->_has_console_verbosity ?
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
            )
        );
        $self->_set_console_colored($self->_has_console_colored ?
            $self->_get_console_colored : (
                defined($self->get_monkeyman->get_parameters->get_mm_color) ?
                        $self->get_monkeyman->get_parameters->get_mm_color :
                        1
            )
        );
        my $logger_console_appender = Log::Log4perl::Appender->new(
            'Log::Log4perl::Appender::Screen',
            name            => 'console',
            stderr          => 1,
        );
        my $logger_console_layout;
        if($self->_get_console_colored) {
            Log::Log4perl::Layout::PatternLayout::add_global_cspec('U',
                func($layout, $message, $category, $priority, $caller_level) {
                    return(sprintf("%s%s%s",
                        $self->_get_console_color('LOG_' . $priority),
                        substr($priority, 0, 1),
                        color('reset')
                    ));
                }
            );
            $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
                '%d [%U] ' . $self->_get_console_color('CATEGORY') . '%c' . $self->_get_console_color('NORMAL') . ' %m%n'
            );
        } else {
            $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
                '%d [%p{1}] %c %m%n'
            );
        }
        $logger_console_appender->layout($logger_console_layout);
        $logger_console_appender->threshold((&MM_VERBOSITY_LEVELS)[$self->_get_console_verbosity]);
        $self->find_log4perl_logger(CONSOLE_LOGGER)->add_appender($logger_console_appender);

    }

    # Initialize helpers

    foreach my $helper_name (qw(fatal error warn info debug trace)) {

        my $log_straight    = sub { shift->_log($helper_name, (caller(0))[0], 0, "@_"); };
        my $log_formatted   = sub { shift->_log($helper_name, (caller(0))[0], 1, @_); };

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



method _log(Str $level!, Str $module!, Bool $formatted!, @message_chunks) {

    my $logger_primary = $self->find_log4perl_logger($module);
    my $logger_console = $self->find_log4perl_logger(CONSOLE_LOGGER . "::$module");

    my $message_primary;
    my $message_console;
    if($formatted) {
        $message_primary = $self->_sprintf(0, @message_chunks);
        $message_console = $self->_sprintf(1, @message_chunks);
    } else {
        $message_console = $message_primary = join(' ', @message_chunks);
    }

    $logger_primary->$level($message_primary);
    $logger_console->$level($message_console);

}



method _sprintf(Bool $colored!, Str $format!, @values?) {

    for(my $i = 0; $i < scalar(@_); $i++) {

        my $value_new;

        if(!defined($values[$i])) {
            $value_new = '[UNDEF]';
        } elsif(ref($values[$i])) {
            $value_new = mm_showref($values[$i]);
        } else {
            $value_new = $values[$i];
        }

        if(
            $colored &&
            $self->_get_console_colored &&
            (!defined($values[$i]) || ($value_new ne $values[$i]))
        ) {
            if($value_new =~ /^\[([^\@\/\]]+)(?:\@(0x[0-9a-f]+))?(?:\/([0-9a-f]+))?\]$/) {
                if(defined($1) && defined($2) && defined($3)) {
                    $value_new = sprintf(
                        '%s[%s%s%s@%s%s%s/%s%s%s]%s',
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('REF_CLASS'), $1,
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('REF_ADDRESS'), $2,
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('MD5_SUM'), $3,
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('NORMAL')
                    );
                } elsif(defined($1) && defined($2)) {
                    $value_new = sprintf(
                        '%s[%s%s%s@%s%s%s]%s',
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('REF_CLASS'), $1,
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('REF_ADDRESS'), $2,
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('NORMAL')
                    );
                } else {
                    $value_new = sprintf(
                        '%s[%s%s%s]%s',
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('REF_CLASS'), $1,
                        $self->_get_console_color('ACCENTED'),
                        $self->_get_console_color('NORMAL')
                    );
                }
            }
        }

        $values[$i] = $value_new;

    }

    return(sprintf($format, @values));

}



method find_log4perl_logger(Str $module = '') {

    if(Log::Log4perl->initialized) {
        return(
            $self->_get_log4perl_loggers->{$module} ?
                $self->_get_log4perl_loggers->{$module} :
               ($self->_get_log4perl_loggers->{$module} = Log::Log4perl->get_logger($module))
        );
    } else {
        return(undef);
    }

}



1;
