package MonkeyMan::Logger;

use strict;
use warnings;
use feature 'state';

use constant CONSOLE_LOGGER_NAME        => 'console';
use constant CONSOLE_VERBOSITY_LEVELS   => qw(OFF FATAL ERROR WARN INFO DEBUG TRACE ALL);
use constant DUMP_ENABLED               => 0;
use constant DUMP_DIRECTORY             => undef;
use constant DUMP_INTROSPECT_XML        => 1;
use constant SHOW_MONKEYMAN_INFO        => 1;
use constant COLOR_CLASS_DEFAULT        => 'NORMAL';
use constant COLORSCHEME_DEFAULT        => {
    NORMAL          => 'reset',
    ACCENTED        => 'bright_white',
    WARNING         => 'red',
    PARAMETER       => 'rgb332',
    LEVEL_TRACE     => 'bright_cyan',
    LEVEL_DEBUG     => 'cyan',
    LEVEL_INFO      => 'white',
    LEVEL_WARN      => 'magenta',
    LEVEL_ERROR     => 'red',
    LEVEL_FATAL     => 'bright_red',
    CATEGORY        => 'rgb541',
    REF_CLASS       => 'bright_cyan',
    REF_ADDRESS     => 'cyan',
    REF_MD5SUM      => 'cyan',
    REF_INFO_NAME   => 'rgb443',
    REF_INFO_VALUE  => 'rgb554'
};

# Use Moose and be happy :)
use Moose;
use Moose::Exporter;
use namespace::autoclean;

with 'MonkeyMan::Roles::WithTimer';

use MonkeyMan::Exception;

use Method::Signatures;
use TryCatch;
use File::Slurp;
use Term::ANSIColor;
use Log::Log4perl qw(:no_extra_logdie_message);
use Scalar::Util qw(blessed refaddr);
use Digest::MD5 qw(md5_hex);
use File::Path qw(make_path);
use Data::Dumper;
use POSIX qw(strftime);

state $_SINGLETON;

Moose::Exporter->setup_import_methods(
    as_is   => [
        \&MonkeyMan::Logger::mm_sprintf,
        \&MonkeyMan::Logger::mm_sprintfmm_sprintf_colored,
        \&MonkeyMan::Logger::mm_showref
    ]
);



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>   '_has_configuration',
    builder     => '_build_configuration'
);

method _build_configuration {
    return({});
}

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
    reader      => 'get_console_verbosity',
    writer      => 'set_console_verbosity',
    predicate   => 'has_console_verbosity',
    default     => 0
);

has 'console_colored' => (
    is          => 'ro',
    isa         => 'Int',
    reader      => 'get_console_colored',
    writer      => 'set_console_colored',
    predicate   => 'has_console_colored',
    default     => 1
);

has 'colorscheme' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_colorscheme',
    writer      =>    'set_colorscheme',
    predicate   =>    'has_colorscheme',
    builder     => '_build_colorscheme',
    lazy        => 1
);

method _build_colorscheme {
    return({});
}

method get_color(
    Str     $class?         = COLOR_CLASS_DEFAULT,
    HashRef $colorscheme?   = $self->get_colorscheme
) {
    return(
        (
            defined($colorscheme) &&
                ref($colorscheme) eq 'HASH' &&
            defined($colorscheme->{ $class })
        ) ?
            color($colorscheme->{ $class }) :
            (
                defined(COLORSCHEME_DEFAULT) &&
                    ref(COLORSCHEME_DEFAULT) eq 'HASH' &&
                defined(COLORSCHEME_DEFAULT->{ $class })
            ) ?
                color(COLORSCHEME_DEFAULT->{ $class }) :
                color('reset')
    );
}

method colorify(
    Str     $class!         = COLOR_CLASS_DEFAULT,
    Str     $string!,
    Bool    $normalize?     = 0,
    HashRef $colorscheme?   = $self->get_colorscheme
) {
    return(
        sprintf('%s%s%s',   
                         $self->get_color($class, $colorscheme),
                         $string,
            $normalize ? $self->get_color(COLOR_CLASS_DEFAULT, $colorscheme) : ''
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

has 'dump_enabled_limited' => (
    is          => 'rw',
    isa         => 'Int',
    reader      =>    'get_dump_enabled_limited',
    writer      =>    'set_dump_enabled_limited',
    predicate   =>    'has_dump_enabled_limited',
    default     => 0,
    lazy        => 0
);

has 'dump_enabled' => (
    is          => 'rw',
    isa         => 'Bool',
    reader      =>    'get_dump_enabled',
    writer      =>    'set_dump_enabled',
    predicate   =>    'has_dump_enabled',
    builder     => '_build_dump_enabled',
    lazy        => 1
);

method _build_dump_enabled {
    return(
        defined($self->get_configuration->{'dump'}->{'enabled'}) ?
               ($self->get_configuration->{'dump'}->{'enabled'}) :
               DUMP_ENABLED
    );
}

has 'dump_directory' => (
    is          => 'rw',
    isa         => 'Str',
    reader      =>    'get_dump_directory',
    writer      =>    'set_dump_directory',
    predicate   =>    'has_dump_directory',
    builder     => '_build_dump_directory',
    lazy        => 1
);

method _build_dump_directory {
    return(
        defined($self->get_configuration->{'dump'}->{'directory'}) ?
               ($self->get_configuration->{'dump'}->{'directory'}) :
               DUMP_DIRECTORY
    );
}

has 'dump_introspect_xml' => (
    is          => 'rw',
    isa         => 'Bool',
    reader      =>    'get_dump_introspect_xml',
    writer      =>    'set_dump_introspect_xml',
    predicate   =>    'has_dump_introspect_xml',
    builder     => '_build_dump_introspect_xml',
    lazy        => 1
);

method _build_dump_introspect_xml {
    return(
        defined($self->get_configuration->{'dump'}->{'introspect_xml'}) ?
               ($self->get_configuration->{'dump'}->{'introspect_xml'}) :
               DUMP_INTROSPECT_XML
    );
}

has 'show_monkeyman_info' => (
    is          => 'rw',
    isa         => 'Bool',
    reader      =>    'get_show_monkeyman_info',
    writer      =>    'set_show_monkeyman_info',
    predicate   =>    'has_show_monkeyman_info',
    builder     => '_build_show_monkeyman_info',
    lazy        => 1
);

method _build_show_monkeyman_info {
    return(
        defined($self->get_configuration->{'monkeyman_info'}) ?
               ($self->get_configuration->{'monkeyman_info'}) :
               SHOW_MONKEYMAN_INFO
    );
}



method BUILD(...) {

    unless(Log::Log4perl->initialized) {

        my $log4perl_configuration = <<__LOG4PERL_DEFAULT_CONFIGURATION__;
log4perl.logger                     = ALL, default
log4perl.appender.default           = Log::Dispatch::File
log4perl.appender.default.layout    = Log::Log4perl::Layout::SimpleLayout
log4perl.appender.default.filename  = /dev/null
__LOG4PERL_DEFAULT_CONFIGURATION__
        if($self->_has_log4perl_configuration_string) {
            $log4perl_configuration = $self->_get_log4perl_configuration_string;
        } elsif($self->_has_log4perl_configuration_file) {
            $log4perl_configuration = read_file($self->_get_log4perl_configuration_file);
        }

        Log::Log4perl->init_once(\$log4perl_configuration);
        Log::Log4perl->wrapper_register(__PACKAGE__);

        # TODO: Actually we should add the Screen-appender only if it hasn't been added yet!
        my $logger_console_appender = Log::Log4perl::Appender->new(
            'Log::Log4perl::Appender::Screen',
            name            => CONSOLE_LOGGER_NAME,
            stderr          => 1,
        );
        my $logger_console_layout;
        if($self->get_console_colored) {
            Log::Log4perl::Layout::PatternLayout::add_global_cspec('U',
                func($layout, $message, $category, $priority, $caller_level) {
                    return($self->colorify('LEVEL_' . $priority, substr($priority, 0, 1), 1));
                }
            );
            $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
                '%d [%P] [%U] [' . $self->colorify('CATEGORY', '%c', 1) . '] %m%n'
            );
        } else {
            $logger_console_layout = Log::Log4perl::Layout::PatternLayout->new(
                '%d [%P] [%p{1}] [%c] %m%n'
            );
        }
        $logger_console_appender->layout($logger_console_layout);
        $logger_console_appender->threshold((&CONSOLE_VERBOSITY_LEVELS)[$self->get_console_verbosity]);
        $self->find_log4perl_logger(CONSOLE_LOGGER_NAME)->add_appender($logger_console_appender);

        # We wouldn't like to see the messages intended for the console in the file
        if(my $appender = $Log::Log4perl::Logger::APPENDER_BY_NAME{'full'}) {
            $appender->filter(
                Log::Log4perl::Filter->new('filter', sub {
                    my %p = @_; return(! index($p{'log4p_category'}, CONSOLE_LOGGER_NAME . '.', 0) == 0);
                })
            )
        }

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

    $MonkeyMan::Logger::_SINGLETON = $self;

}



func instance(...) {

    if(defined($MonkeyMan::Logger::_SINGLETON)) {
        return($MonkeyMan::Logger::_SINGLETON);
    } else {
        return(__PACKAGE__->new);
    }

}



method log(Str $level!, Str $module!, Bool $formatted!, @message_chunks) {

    my $logger_primary = $self->find_log4perl_logger($module);
    my $logger_console = $self->find_log4perl_logger(CONSOLE_LOGGER_NAME . "::$module");

    my $message_primary;
    my $message_console;
    if($formatted) {
        $self->set_dump_enabled_limited($self->get_dump_enabled_limited + 1) if($self->get_dump_enabled_limited);
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
            scalar(@{ $values }) > 1 &&
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

    my %shall_be_colored;
    if($colored && defined($self) && $self->get_console_colored) {
        my $parameter_number = 0;
        while($format =~ /
            % (
                % | (?:
                    (?:\d+\$)?
                    [ +0#\-]*
                    (?:\*?v)?
                    \d*
                    (?:\.\d+|\.\*)?
                    (?:hh|h|j|l|q|L|ll|t|z)?
                    [BDEFGOUXbcdefginopsux]
                )
            )
        /xg) {
            if($1 eq 's') {
                $shall_be_colored{$parameter_number} = 1;
            } elsif($1 eq '%') {
                next;
            }
            $parameter_number++;
        }
    }

    my @values_new = @{ $values };

    for(my $i = 0; $i < scalar(@values_new); $i++) {

        my $value_new;

        if(!defined($values_new[$i])) {
            $value_new = $shall_be_colored{$i} ?
                '[' . $self->colorify('WARNING', 'UNDEF', 1) . ']' :
                '[UNDEF]'
#        } elsif(ref($values_new[$i]) eq 'ARRAY') {
#            $value_new = '(' . join(', ', map {
#                _sprintf(
#                    self        => $self,
#                    format      => '%s',
#                    values      => [$_],
#                    colored     => $colored,
#                    colorscheme => $colorscheme
#                )
#            } (@{ $values_new[$i] })) . ')';
        } elsif(ref($values_new[$i])) {
            $value_new = defined($self) ?
                $self->mm_showref($values_new[$i]) :
                       mm_showref($values_new[$i]);
            if($shall_be_colored{$i} && $value_new =~ /
                ^
                    \[
                        (       [^\@\/\]]+                  )
                        (?:     \@          (0x[0-9a-f]+)   )?
                        (?:     \/            ([0-9a-f]+)   )?
                        (?:     \|            (.+)          )?
                    \]
                $
            /x) {
                $value_new = '';
                if(defined($4)) {
                    $value_new = ' ' .
                        join(' ', (
                            map {
                                ($_ =~ /^(.+):(.+)$/) ? (
                                    $self->colorify('REF_INFO_NAME',  $1, 1) . ':' .
                                    $self->colorify('REF_INFO_VALUE', $2, 1)
                                ) : (
                                    $self->colorify('REF_INFO_NAME',  $_, 1)
                                )
                            } split(/\|/, $4)
                        ));
                }
                if(defined($3)) {
                    $value_new = '/' .
                        $self->colorify('REF_MD5SUM',   $3, 1) .
                        $value_new;
                }
                if(defined($1) && defined($2)) {
                    $value_new =
                        $self->colorify('REF_CLASS',    $1, 1) . '@' .
                        $self->colorify('REF_ADDRESS',  $2, 1) .
                        $value_new;
                }
                unless(length($value_new)) {
                    $value_new =
                        $self->colorify('LOG_ERROR',    $1, 1);
                }
                $value_new = '[' . $value_new . ']';
            }
        } else {
            $value_new = $shall_be_colored{$i} ?
                $self->colorify('PARAMETER', $values_new[$i], 1) :
                $values_new[$i];
        }

        $values_new[$i] = $value_new;

    }

    return(sprintf($format, @values_new));

}



func mm_showref(...) {

    # Am I being called as a class' method or as a regular function?
    my $self = _find_myself(\@_);

    my $ref = shift;

    my $ref_id_short = sprintf(
        '%s@0x%x',
        blessed($ref) ? blessed($ref) : ref($ref),
        refaddr($ref)
    );

    my $result;

    my $showinfo;
    my $dumping;
    my $dumpdir;
    my $dumpxml;
    my $dumpfile;

    if(defined($self)) {
        $showinfo   = $self->get_show_monkeyman_info;
        $dumping    = $self->get_dump_enabled_limited &&
                     ($self->set_dump_enabled_limited($self->get_dump_enabled_limited - 1) || 1) ||
                      $self->get_dump_enabled;
        $dumpdir    = $self->get_dump_directory;
        $dumpxml    = $self->get_dump_introspect_xml;
    } else {
        $showinfo   = SHOW_MONKEYMAN_INFO;
        $dumping    = DUMP_ENABLED;
        $dumpdir    = DUMP_DIRECTORY;
        $dumpxml    = DUMP_INTROSPECT_XML;
    }

    if($dumping && defined($dumpdir)) {

        my $dumper  = Data::Dumper->new([$ref]);
        my $dump    = Data::Dumper->new([$ref])->Indent(1)->Terse(0)->Dump;

        $dump = sprintf("%s\n%s", $dump, $ref->toString(1))
            if($dumpxml && blessed($ref) && $ref->DOES('XML::LibXML::Node'));

        my $ref_id_long = md5_hex($dump);

        $dumpfile = sprintf('%s/%s',
            $dumpdir = sprintf('%s/%s/%d/%s',
                $dumpdir,
                defined($self) ?
                    strftime('%Y.%m.%d.%H.%M.%S', localtime($self->get_time_started->[0])) :
                    strftime('%Y.%m.%d.%H.%M.%S', localtime),
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
            if(defined($self)) { $self->warn($message); } else { warn($message); }
            $result = 'CORRUPTED';
        }

        $result = sprintf("%s/%s", $ref_id_short, $ref_id_long)
            unless($result);

    } else {

        $result = $ref_id_short;

    }

    if(
            defined($ref)                   &&
            blessed($ref)                   &&
          $ref->can('monkeyman_info')       &&
            defined($ref->monkeyman_info)   &&
             length($ref->monkeyman_info)
    ) {
        $result = sprintf("%s|%s", $result, $ref->monkeyman_info);
    }

    return('[' . $result . ']');

}




1;

=head1 NAME

MonkeyMan::Logger - MonkeyMan's chronicler :)

=cut

