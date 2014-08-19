package MonkeyMan;

use strict;
use warnings;

use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack;

use Config::General qw(ParseConfig);
use Log::Log4perl qw(:no_extra_logdie_message);
use Text::Template;
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

    # Self-configuring

    unless($self->has_configuration) {
        my %configuration = eval {
            ParseConfig(
                -ConfigFile         => $self->_has_config_file ? $self->config_file : MMMainConfigFile,
                -UseApacheInclude   => 1
            );
        };
        if($@) {
            die(mm_sprintify("Can't Config::General::ParseConfig(): %s", $@));
        }
        $self->_set_configuration(\%configuration);
    }

    # Initializing connectors

    my $log = $self->_init_logger;
    die($self->error_message)
        unless(defined($log));

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



sub _init_logger {

    my $self = shift;

    unless(Log::Log4perl->initialized) {

        if($self->_has_verbosity) {
            $self->_set_verbosity(0) if($self->verbosity < 0);
            $self->_set_verbosity(7) if($self->verbosity > 7);
        } else {
            $self->_set_verbosity(&MMVerbosityLevel);
        }

        my $log_screen_loglevel = (&MMVerbosityLevels)[$self->verbosity];
        my $log_screen_pattern  = ($self->verbosity > 4) ?
            '%d %m%n' :
            '%d [%p{1}] %m%n';
        my $log_conf_filename = $self->configuration('log::log4perl');
        my $log_conf_template = Text::Template->new(
            TYPE        => 'FILE',
            SOURCE      => $log_conf_filename,
            DELIMITERS  => ['<%', '%>']
        );
        return($self->error(mm_sprintify("Can't Text::Template::new(): %s", $Text::Template::ERROR)))
            unless(defined($log_conf_template));
        my $log_conf = $log_conf_template->fill_in(
            HASH => {
                log_screen_loglevel => $log_screen_loglevel,
                log_screen_pattern  => $log_screen_pattern
            }
        );
        return($self->error(mm_sprintify("Can't %s->fill_in(): %s", $log_conf_template, $Text::Template::ERROR)))
            unless(defined($log_conf));

        eval { Log::Log4perl::init_once(\$log_conf) };
        return($self->error(mm_sprintify("Can't Log::Log4perl::init_once(): %s", $@)))
            if($@);

    }

    my $log = eval { Log::Log4perl::get_logger(__PACKAGE__) };
    return($self->error(mm_sprintify("Can't Log::Log4perl::get_logger(): %s", $@)))
        if($@);

    return($log);

}



sub init_cloudstack {

    my $self = shift;

    my $cloudstack = eval { MonkeyMan::CloudStack->new(mm => $self); };

    return($@ ?
        $self->error(mm_sprintify("Can't MonkeyMan::CloudStack::new(): %s", $@)) :
        $cloudstack
    );

}



__PACKAGE__->meta->make_immutable;

1;
