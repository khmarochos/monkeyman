package MonkeyMan;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Utils;
use MonkeyMan::Exception;
use MonkeyMan::CloudStack;

# Use 3rd party libraries
use TryCatch;
use Config::General qw(ParseConfig);
use Log::Log4perl qw(:no_extra_logdie_message);
use Text::Template;
use Data::Dumper;

# Use Moose :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



has 'config_file' => (
    is          => 'ro',
    isa         => 'Str',
    default     => MM_CONFIG_MAIN,
    predicate   => '_has_config_file',
    required    => 'yes'
);
has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      => '_get_configuration',
    writer      => '_set_configuration',
    predicate   => 'has_configuration',
);
has 'skip_init' => (
    is          => 'ro',
    isa         => 'HashRef',
    default     => sub {{}}
);
has 'verbosity' => (
    is          => 'ro',
    isa         => 'Str',
    writer      => '_set_verbosity',
    predicate   => '_has_verbosity'
);



sub BUILD {

    my $self = shift;
    my $log;

    # Self-configuring

    unless($self->has_configuration) {
        my %configuration;
        try {
            %configuration = ParseConfig(
                -ConfigFile         => ($self->_has_config_file ? $self->config_file : MM_CONFIG_MAIN),
                -UseApacheInclude   => 1
            );
        } catch($e) {
            MonkeyMan::Exception::Initialization->throw_f("Can't Config::General::ParseConfig(): %s", $e);
        }
        $self->_set_configuration(\%configuration);
    }

    # Initializing the logger

    try {
        $log = $self->init_logger;
    } catch(MonkeyMan::Exception::Initialization::Logger $e) {
        MonkeyMan::Exception->throw($e);
    } catch($e) {
        MonkeyMan::Exception::Initialization->throw_f("Can't MonkeyMan::init_logger(): %s", $e);
    }

    # Okay, everything's fine now :)

    $log->trace("MonkeyMan has been initialized");

}



sub configuration {

    my($self, $parameter) = @_;

    if(defined($parameter)) {

        my $node = $self->_get_configuration;
        foreach (split('::', $parameter)) {
            return(undef) unless(ref($node));
            $node = $node->{$_};
        }
        return($node);

    } else {

        return($self->_get_configuration)

    };

}



sub init_logger {

    my $self = shift;
    my $log;
    my $warn;

    if(Log::Log4perl->initialized) {

        $warn = 1;

    } else {

        if($self->_has_verbosity) {
            $self->_set_verbosity(0) if($self->verbosity < 0);
            $self->_set_verbosity(7) if($self->verbosity > 7);
        } else {
            $self->_set_verbosity(&MM_VERBOSITY_LEVEL_DEFAULT);
        }

        my $log_screen_loglevel = (&MM_VERBOSITY_LEVELS)[$self->verbosity];
        my $log_screen_pattern  = ($self->verbosity > 4) ?
            '%d %m%n' :
            '%d [%p{1}] %m%n';
        my $log_conf_filename = $self->configuration('log::log4perl');
        my $log_conf_template = Text::Template->new(
            TYPE        => 'FILE',
            SOURCE      => $log_conf_filename,
            DELIMITERS  => ['<%', '%>']
        );
        MonkeyMan::Exception::Initialization::Logger->throw_f("Can't Text::Template::new(): %s", $Text::Template::ERROR)
            unless(defined($log_conf_template));
        my $log_conf = $log_conf_template->fill_in(
            HASH => {
                log_screen_loglevel => $log_screen_loglevel,
                log_screen_pattern  => $log_screen_pattern
            }
        );
        MonkeyMan::Exception::Initialization::Logger->throw_f("Can't %s->fill_in(): %s", $log_conf_template, $Text::Template::ERROR)
            unless(defined($log_conf));

        try {
            Log::Log4perl::init_once(\$log_conf);
        } catch($e) {
            MonkeyMan::Exception::Initialization::Logger->throw_f("Can't Log::Log4perl::init_once(): %s", $e);
        }

    }



    try {
        $log = Log::Log4perl::get_logger(__PACKAGE__);
    } catch($e) {
        MonkeyMan::Exception::Initialization::Logger->throw_f("Can't Log::Log4perl::get_logger(): %s", $e);
    }

    $log->warn("The logger has been re-initialized")
        if($warn);



    return($log);

}



sub init_cloudstack {

    my $self = shift;
    my $cloudstack;
    
    try {
        $cloudstack = MonkeyMan::CloudStack->new(mm => $self);
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception::Initialization::CloudStack->throw_f("Can't MonkeyMan::CloudStack->new(): %s", $e);
    }

    return($cloudstack);

}



__PACKAGE__->meta->make_immutable;

1;
