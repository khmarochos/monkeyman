package MonkeyMan;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::CloudStack::API;
use MonkeyMan::CloudStack::Cache;

use Config::General qw(ParseConfig);
use Log::Log4perl qw(:no_extra_logdie_message);
use Data::Dumper;

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'config_file' => (
    is          => 'ro',
    isa         => 'Str',
    default     => MMMainConfigFile,
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
has 'verbosity' => (
    is          => 'ro',
    isa         => 'Str',
    writer      => '_set_verbosity',
    predicate   => '_has_verbosity'
);
has 'cloudstack_api' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    writer      => '_set_cloudstack_api',
    predicate   => 'has_cloudstack_api',
);
has 'cloudstack_cache' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Cache',
    writer      => '_set_cloudstack_cache',
    predicate   => 'has_cloudstack_cache'
);


sub BUILD {

    my $self = shift;

    # Self-configuring

    unless($self->has_configuration) {
        my %configuration = eval {
            ParseConfig(
                -ConfigFile         => $self->_has_config_file ? $self->config_file : MMMainConfigFile,
                -UseApacheInclude   => 1
            );
        };
        if($@) {
            die("Can't Config::General::ParseConfig(): $@");
        }
        $self->_set_configuration(\%configuration);
    }

    # Initializing the logger if it haven't been defined yet

    unless(Log::Log4perl->initialized) {
        if($self->_has_verbosity) {
            $self->_set_verbosity(0) if($self->verbosity < 0);
            $self->_set_verbosity(7) if($self->verbosity > 7);
        } else {
            $self->_set_verbosity(&MMVerbosityLevel);
        }
        my $log_screen_loglevel = (&MMVerbosityLevels)[$self->verbosity];
        my $log_screen_pattern  = ($self->verbosity > 4) ?
            '%d [%p{1}] %m%n' :
            '%m%n';
        my $log_conf_filename = $self->configuration('log::log4perl');
        my $log_conf_loaded;
        my $log_conf_appenders;
        if(defined($log_conf_filename)) {
            open(LOG_CONF_FILE, $log_conf_filename) || die("Can't open(): $@");
            while(<LOG_CONF_FILE>) {
                $log_conf_loaded .= $_;
                if(/^\s*log4perl\.appender\.([^\s\.]+)\s+=/) {
                    $log_conf_appenders .= "$1, ";
                }
            }
            close(LOG_CONF_FILE);
        }
        my $log_conf = <<__END_LOGCONF__;
log4perl.category.MonkeyMan                         = ALL, ${log_conf_appenders}screen

$log_conf_loaded

log4perl.appender.screen                            = Log::Log4perl::Appender::Screen
log4perl.appender.screen.layout                     = Log::Log4perl::Layout::PatternLayout
log4perl.appender.screen.layout.ConversionPattern   = $log_screen_pattern
log4perl.appender.screen.Filter                     = screen
log4perl.filter.screen                              = Log::Log4perl::Filter::LevelRange
log4perl.filter.screen.LevelMin                     = $log_screen_loglevel
log4perl.filter.screen.AcceptOnMatch                = true
__END_LOGCONF__
        eval { Log::Log4perl::init_once(\$log_conf) };
        die("Can't Log::Log4perl::init_once(): $@")
            if($@);


    }

    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    die("Can't Log::Log4perl::init_once(): $@")
        if($@);

    # Okay, everything's fine now :)

    $log->debug("MonkeyMan has been initialized");

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



sub init_cloudstack_api {

    my $self = shift;

    my $cloudstack_api = eval {
        $self->_set_cloudstack_api(
            MonkeyMan::CloudStack::API->new(mm => $self)
        );
    };

    return($@ ?
        $self->error("Can't MonkeyMan::CloudStack::API::new(): $@") :
        $cloudstack_api
    );

}



__PACKAGE__->meta->make_immutable;

1;
