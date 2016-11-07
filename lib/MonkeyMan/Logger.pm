package MonkeyMan::Logger;

=head1 NAME

MonkeyMan::Logger - MonkeyMan's chronicler :)

=cut

use strict;
use warnings;

use constant CONSOLE_LOGGER_NAME        => 'console';
use constant CONSOLE_VERBOSITY_LEVELS   => qw(OFF FATAL ERROR WARN INFO DEBUG TRACE ALL);
use constant DUMP_ENABLED               => 0;
use constant DUMP_DIRECTORY             => undef;
use constant DUMP_INTROSPECT_XML        => 1;

# Use Moose and be happy :)
use Moose;
use Moose::Exporter;
use namespace::autoclean;

Moose::Exporter->setup_import_methods(
    as_is   => [
        \&MonkeyMan::Logger::mm_sprintf,
        \&MonkeyMan::Logger::mm_sprintfmm_sprintf_colored
    ]
);

use MonkeyMan::Exception;

# Use 3rd-party libraries
use Method::Signatures;
use TryCatch;
use File::Slurp;
use Term::ANSIColor;
use Log::Log4perl qw(:no_extra_logdie_message);
use Scalar::Util qw(blessed refaddr);
use Digest::MD5 qw(md5_hex);
use File::Path qw(make_path);



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>  'get_configuration',
    writer      => '_set_configuration',
    predicate   => '_has_configuration',
);

has 'log4perl_configuration_string' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => '_get_log4perl_configuration_string',
    writer      => '_set_log4perl_configuration_string',
    predicate   => '_has_log4perl_configuration_string'
);

has 'log4perl_configuration_file' => (
    is          => 'ro',
    isa         => 'Str',
    reader      => '_get_log4perl_configuration_file',
    writer      => '_set_log4perl_configuration_file',
    predicate   => '_has_log4perl_configuration_file'
);

has 'console_verbosity' => (
    is          => 'ro',
    isa         => 'Int',
    reader      => '_get_console_verbosity',
    writer      => '_set_console_verbosity',
    predicate   => '_has_console_verbosity',
    default     => 0
);

has 'console_colored' => (
    is          => 'ro',
    isa         => 'Int',
    reader      => '_get_console_colored',
    writer      => '_set_console_colored',
    predicate   => '_has_console_colored',
    default     => 1
);

has 'colorscheme' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_colorscheme',
    writer      =>   '_set_colorscheme',
    predicate   =>   '_has_colorscheme',
    builder     => '_build_colorscheme',
    lazy        => 1
);

method _build_colorscheme {
    return(
        defined($self->get_configuration->{'colorscheme'}) ?
                $self->get_configuration->{'colorscheme'}  :
                {}
    );
}

method get_color(
    Str     $class?         = 'NORMAL',
    HashRef $colorscheme?   = $self->_get_colorscheme
) {
    return(
        (
            defined($colorscheme) &&
            defined($colorscheme->{$class})
        ) ?
            color($colorscheme->{$class}) :
            color('reset')
    );
}

method colorify(
    Str     $class!         = 'NORMAL',
    Str     $string!,
    Bool    $normalize?     = 0,
    HashRef $colorscheme?   = $self->_get_colorscheme
) {
    return(
        sprintf('%s%s%s',   
                         $self->get_color($class, $colorscheme),
                         $string,
            $normalize ? $self->get_color('NORMAL', $colorscheme) : ''
        )
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

method find_log4perl_logger(Str $name = '') {
    if(Log::Log4perl->initialized) {
        return(
            $self->_get_log4perl_loggers->{$name} ?
                $self->_get_log4perl_loggers->{$name} :
               ($self->_get_log4perl_loggers->{$name} = Log::Log4perl->get_logger($name))
        );
    } else {
        return(undef);
    }
}

has 'dump_enabled' => (
    is          => 'ro',
    isa         => 'Bool',
    reader      =>   '_get_dump_enabled',
    writer      =>   '_set_dump_enabled',
    predicate   =>   '_has_dump_enabled',
    builder     => '_build_dump_enabled',
    lazy        => 1
);

method _build_dump_enabled {
    return($self->get_configuration->{'dump'}->{'enabled'})
}

has 'dump_directory' => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>   '_get_dump_directory',
    writer      =>   '_set_dump_directory',
    predicate   =>   '_has_dump_directory',
    builder     => '_build_dump_directory',
    lazy        => 1
);

method _build_dump_directory {
    return($self->get_configuration->{'dump'}->{'directory'})
}

has 'dump_introspect_xml' => (
    is          => 'ro',
    isa         => 'Bool',
    reader      =>   '_get_dump_introspect_xml',
    writer      =>   '_set_dump_introspect_xml',
    predicate   =>   '_has_dump_introspect_xml',
    builder     => '_build_dump_introspect_xml',
    lazy        => 1
);

method _build_dump_introspect_xml {
    return($self->get_configuration->{'dump'}->{'introspect_xml'});
}



method BUILD(...) {

    unless(Log::Log4perl->initialized) {

        my $log4perl_configuration;
        if($self->_has_log4perl_configuration_string) {
            $log4perl_configuration = $self->_get_log4perl_configuration_string;
        } elsif($self->_has_log4perl_configuration_file) {
            $log4perl_configuration = read_file($self->_get_log4perl_configuration_file);
        }

        Log::Log4perl->init_once(\$log4perl_configuration);
        Log::Log4perl->wrapper_register(__PACKAGE__);

        my $logger_console_appender = Log::Log4perl::Appender->new(
            'Log::Log4perl::Appender::Screen',
            name            => 'console',
            stderr          => 1,
        );
        my $logger_console_layout;
        if($self->_get_console_colored) {
            Log::Log4perl::Layout::PatternLayout::add_global_cspec('U',
                func($layout, $message, $category, $priority, $caller_level) {
                    return($self->colorify('LEVEL_' . $priority, substr($priority, 0, 1), 1));
                }
            );
            $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
                '%d [%U] ' . $self->colorify('CATEGORY', '%c', 1) . ' %m%n'
            );
        } else {
            $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
                '%d [%p{1}] %c %m%n'
            );
        }
        $logger_console_appender->layout($logger_console_layout);
        $logger_console_appender->threshold((&CONSOLE_VERBOSITY_LEVELS)[$self->_get_console_verbosity]);
        $self->find_log4perl_logger(CONSOLE_LOGGER_NAME)->add_appender($logger_console_appender);

    }

    # Initialize methods

    foreach my $helper_name (qw(fatal error warn info debug trace)) {

        my $log_joined      = sub { shift->log($helper_name, (caller(0))[0], 0, join(' ', @_)); };
        my $log_formatted   = sub { shift->log($helper_name, (caller(0))[0], 1, @_); };

        $self->meta->add_method(
            $helper_name => Class::MOP::Method->wrap(
                $log_joined, (
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



method log(Str $level!, Str $module!, Bool $formatted!, @message_chunks) {

    my $logger_primary = $self->find_log4perl_logger($module);
    my $logger_console = $self->find_log4perl_logger(CONSOLE_LOGGER_NAME . "::$module");

    my $message_primary;
    my $message_console;
    if($formatted) {
        $message_primary = $self->mm_sprintf        (@message_chunks);
        $message_console = $self->mm_sprintf_colored(@message_chunks);
    } else {
        $message_console = $message_primary = join(' ', @message_chunks);
    }

    $logger_primary->$level($message_primary);
    $logger_console->$level($message_console);

}



func _find_myself(ArrayRef $values!) {
    return(
        (
            defined($values->[0]) &&
            blessed($values->[0]) &&
            $values->[0]->DOES(__PACKAGE__)
        ) ?
            shift(@{ $values }) :
            undef
    );
}

func mm_sprintf(...) {
    my $self    = _find_myself(\@_);
    my $format  = shift;
    return(
        _sprintf(
            self    => $self,
            format  => $format,
            values  => \@_,
            colored => 0
        )
    );
}

func mm_sprintf_colored(...) {
    my $self    = _find_myself(\@_);
    my $format  = shift;
    return(
        _sprintf(
            self    => $self,
            format  => $format,
            values  => \@_,
            colored => 1
        )
    );
}

func _sprintf(
    Maybe[Object] :$self?,
    Str         :$format?       = '',
    ArrayRef    :$values?       = [],
    Bool        :$colored?      = 0,
    HashRef     :$colorscheme?  = {}
) {

    my @values_new = @{ $values };

    for(my $i = 0; $i < scalar(@values_new); $i++) {

        my $value_new;

        if(!defined($values_new[$i])) {
            $value_new = '[UNDEF]';
        } elsif(ref($values_new[$i])) {
            $value_new = defined($self) ?
                $self->mm_showref($values_new[$i]) :
                       mm_showref($values_new[$i])
        } else {
            $value_new = $values_new[$i];
        }

        if(
            $colored && defined($self) && $self->_get_console_colored && (!defined($values_new[$i]) || ($value_new ne $values_new[$i]))
        ) {
            if($value_new =~ /^\[([^\@\/\]]+)(?:\@(0x[0-9a-f]+))?(?:\/([0-9a-f]+))?\]$/) {
                if(defined($1) && defined($2) && defined($3)) {
                    $value_new = 
                        $self->colorify('ACCENTED',     '[',    0) .
                        $self->colorify('REF_CLASS',    $1,     0) .
                        $self->colorify('ACCENTED',     '@',    0) .
                        $self->colorify('REF_ADDRESS',  $2,     0) .
                        $self->colorify('ACCENTED',     '/',    0) .
                        $self->colorify('REF_MD5SUM',   $3,     0) .
                        $self->colorify('ACCENTED',     ']',    1);
                } elsif(defined($1) && defined($2)) {
                    $value_new = 
                        $self->colorify('ACCENTED',     '[',    0) .
                        $self->colorify('REF_CLASS',    $1,     0) .
                        $self->colorify('ACCENTED',     '@',    0) .
                        $self->colorify('REF_ADDRESS',  $2,     0) .
                        $self->colorify('ACCENTED',     ']',    1);
                } else {
                    $value_new = 
                        $self->colorify('ACCENTED',     '[',    0) .
                        $self->colorify('LOG_ERROR',    $1,     0) .
                        $self->colorify('ACCENTED',     ']',    1);
                }
            }
        }

        $values_new[$i] = $value_new;

    }

    return(sprintf($format, @values_new));

}



func mm_showref(...) {

    # Am I being called as a class' method or as a regular function?
    my $self = (
        defined($_[0]) &&
        blessed($_[0]) &&
        $_[0]->DOES(__PACKAGE__)
    ) ?
        shift :
        undef;
    my $ref = shift;

    my $ref_id_short = sprintf(
        "%s\@0x%x",
        blessed($ref) ? blessed($ref) : ref($ref),
        refaddr($ref)
    );

    my $dumping;
    my $dumpdir;
    my $dumpxml;
    my $dumpfile;

    if(defined($self)) {
        $dumping    = $self->_get_dump_enabled;
        $dumpdir    = $self->_get_dump_directory;
        $dumpxml    = $self->_get_dump_introspect_xml;
    } else {
        $dumping    = DUMP_ENABLED;
        $dumpdir    = DUMP_DIRECTORY;
        $dumpxml    = DUMP_INTROSPECT_XML;
    }

    my $result;

    if(defined($dumping) && defined($dumpdir)) {

        my $dumper  = Data::Dumper->new([$ref]);
        my $dump    = Data::Dumper->new([$ref])->Indent(1)->Terse(0)->Dump;

        $dump = sprintf("%s\n%s", $dump, $ref->toString(1))
            if($dumpxml && blessed($ref) && $ref->DOES('XML::LibXML::Node'));

        my $ref_id_long = md5_hex($dump);

        $dumpfile = sprintf('%s/%s',
            $dumpdir = sprintf('%s/%d/%s',
                $dumpdir,
                $$,
                $ref_id_short
            ), $ref_id_long
        );

        try {
            make_path($dumpdir);
            open(my($filehandle), '>', $dumpfile) ||
                MonkeyMan::Exception->throwf(
                    "Can't open the %s file for writing: %s",
                        $dumpfile,
                        $!
                );
            print({$filehandle} $dump);
            close($filehandle) ||
                MonkeyMan::Exception->throwf(
                    "Can't close the %s file: %s",
                        $dumpfile,
                        $!
                );
        } catch($e) {
            my $message = sprintf("Can't dump: %s", $e);
            if(defined($self)) {
                $self->warn($message);
            } else {
                warn($message);
            }
            $result = 'CORRUPTED';
        }

        $result = sprintf("%s/%s", $ref_id_short, $ref_id_long)
            unless($result);

    } else {

        $result = sprintf("%s", $ref_id_short)
            unless($result);

    }

    return(sprintf("[%s]", $result));

}




1;
