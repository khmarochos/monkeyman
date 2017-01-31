package MonkeyMan;

use 5.20.1;
use strict;
use warnings;
use English;

# Use Moose and be happy :)
use Moose 2.1604;
use namespace::autoclean;

# Add some roles
with 'MonkeyMan::Roles::WithTimer';
# This is a role to implement the timer attributes for the MonkeyMan class
# (the time_started attribute and some methods to work with it)

use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Exception qw(
    CanNotLoadPackage
    SecurityCheckFailed
    PluginConfigurationMissing
);
use MonkeyMan::Parameters;
use MonkeyMan::Plug;

our $VERSION = MM_VERSION;

use constant MM_DIRECTORY_LIB               => MM_DIRECTORY_ROOT . '/lib';
use constant MM_DIRECTORY_CONFIG_MAIN       => MM_DIRECTORY_ROOT . '/etc';
use constant MM_CONFIG_PLUGINS              => MM_DIRECTORY_LIB . '/MonkeyMan/plugins.yaml';
use constant MM_CONFIG_MAIN                 => MM_DIRECTORY_CONFIG_MAIN . '/monkeyman.conf';
use constant CONSOLE_VERBOSITY_LEVEL_BASE   => 4;
use constant DEFAULT_DATE_TIME_FORMAT       => '%Y/%m/%d %H:%M:%S';

# Use 3rd-party libraries
use POSIX qw(setuid setgid);
use MooseX::Singleton;
use Method::Signatures;
use TryCatch;
use Getopt::Long qw(:config no_ignore_case);
use Config::General;
use File::Slurp;
use String::CamelCase qw(camelize);
use YAML::XS;
use File::Slurp;

# I have to use Log::Log4perl here, because it adds the END-block which
# destroys all the loggers. I need this block to be added before I add my
# END-block which needs the loggers. I let the Log::Log4perl to add its
# block before mine, so my block will be executed before its one...
use Log::Log4perl;
# ...yes, it's ugly, but it works. :-P



method BUILD(...) {

    $self->_mm_init;

    if(defined($self->get_app_code)) {
        $self->_app_start;
        $self->_app_run;
        $self->_app_finish;
    }

}



=pod

There are a few parameters that can (and need to) be defined:

=head3 Application-Related Parameters

=cut

has 'mm_version' => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_mm_version',
    builder     => '_build_mm_version',
    init_arg    => undef
);

method _build_mm_version {

    MM_VERSION;

}

has 'app_code' => (
    is          => 'ro',
    isa         => 'Maybe[CodeRef]',
    reader      => 'get_app_code',
    predicate   => 'has_app_code'
);

has 'app_name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_name',
    writer      => '_set_app_name'
);

has 'app_description' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_description',
    writer      => '_set_app_description'
);

has 'app_version' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_version',
    writer      => '_set_app_version'
);

has 'app_usage_help' => (
    is          => 'ro',
    isa         => 'CodeRef|Str',
    required    => 0,
    reader      =>  'get_app_usage_help',
    predicate   =>  'has_app_usage_help',
    writer      => '_set_app_usage_help'
);



has 'parameters_to_get' => (
    is          => 'ro',
    isa         => 'HashRef[Str]',
    predicate   => '_has_parameters_to_get',
    reader      => '_get_parameters_to_get',
    builder     => '_build_parameters_to_get',
    lazy        => 0,
);

method _build_parameters_to_get(...) {
    return({});
}

has 'parameters_to_get_validated' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   => '_has_parameters_to_get_validated',
    reader      => '_get_parameters_to_get_validated',
    lazy        => 0
);

has 'parameters' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Parameters',
    reader      =>    'get_parameters',
    writer      =>   '_set_parameters',
    predicate   =>   '_has_parameters',
    builder     => '_build_parameters',
    lazy        => 1
);

method _build_parameters {
    my %reserved = (
        'h|help'            => 'mm_show_help',
        'V|version'         => 'mm_show_version',
        'C|configuration=s' => 'mm_configuration',
        'v|verbose+'        => 'mm_be_verbose',
        'q|quiet+'          => 'mm_be_quiet',
        'color!'            => 'mm_color'
    );
    foreach my $plugin_name (keys(%{ $self->get_plugins_loaded })) {
        my $plugin_configuration   = $self->get_plugins_loaded->{$plugin_name};
        $reserved{
            $plugin_configuration->{'parameter_key'} . '=s'
        } = $plugin_configuration->{'parameter_name'};
    }
    return(
        MonkeyMan::Parameters->new(
            (%reserved) ?
                (parameters_reserved         => \%reserved) : (),
            $self->_has_parameters_to_get ?
                (parameters_to_get           => $self->_get_parameters_to_get) : (),
            $self->_has_parameters_to_get_validated ?
                (parameters_to_get_validated => $self->_get_parameters_to_get_validated) : ()
        )
     )
}



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    predicate   =>    'has_configuration',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {

    my $configuration_string;

    if($self->has_configuration_string) {
        $configuration_string = $self->get_configuration_string;
    } else {
        $configuration_string = read_file($self->get_configuration_filename);
    }

    if($self->has_configuration_append) {
        $configuration_string .=
            "\n# APPENDED BY THE configuration_append ATTRIBUTE\n" .
            $self->get_configuration_append;
    }

    my $config = Config::General->new(
        -String                 => $configuration_string,
        -UseApacheInclude       => 1,
        -ExtendedAccess         => 1,
        -MergeDuplicateBlocks   => 1
    );

    return({ $config->getall });

}

=head4 C<configuration_filename>

=cut

has 'configuration_filename' => (
    is          => 'ro',
    isa         => 'Str',
    predicate   =>    'has_configuration_filename',
    reader      =>    'get_configuration_filename',
    writer      =>   '_set_configuration_filename',
    builder     => '_build_configuration_filename',
    lazy        => 1
);

method _build_configuration_filename {
    return(
        defined($self->get_parameters->get_mm_configuration) ?
                $self->get_parameters->get_mm_configuration :
                MM_CONFIG_MAIN
    );
}

=head4 C<configuration_string>

=cut

has 'configuration_string' => (
    is          => 'ro',
    isa         => 'Maybe[Str]',
    predicate   =>    'has_configuration_string',
    reader      =>    'get_configuration_string',
    writer      =>   '_set_configuration_string',
    builder     => '_build_configuration_string',
    lazy        => 1
);

method _build_configuration_string {
    return(undef);
}

has 'configuration_append' => (
    is          => 'ro',
    isa         => 'Maybe[Str]',
    predicate   =>    'has_configuration_append',
    reader      =>    'get_configuration_append',
    writer      =>   '_set_configuration_append',
    builder     => '_build_configuration_append',
    lazy        => 1
);

method _build_configuration_append {
    return(undef);
}



has 'plugins_loaded' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>  'get_plugins_loaded',
    writer      => '_set_plugins_loaded',
    predicate   => '_has_plugins_loaded',
    builder     => '_build_plugins_loaded',
    lazy        => 1
);

method _build_plugins_loaded {

    Load(scalar(read_file(MM_CONFIG_PLUGINS)));

}



method _mm_init {

    my $meta = $self->meta;

    my %plugin_parameters;
    my @plugins_to_load;
    my @postponed_messages;
    my $logger;

    push(
        @postponed_messages,
        [ "We've got the set of command-line parameters: %s", $self->get_parameters ]
    );
    if($self->get_parameters->get_mm_show_help) {
        $self->print_full_version_info;
        $self->print_full_usage_help;
        exit;
    } elsif($self->get_parameters->get_mm_show_version) {
        $self->print_full_version_info;
        exit;
    }

    push(
        @postponed_messages,
        [ "We've got the configuration: %s", $self->get_configuration ]
    );

    my $euid_egid_ok = $self->check_euid_egid(
        security_configuration  => $self->get_configuration->{'security'},
        try_to_set              => 1
    );
    if(!defined($euid_egid_ok)) {
        push(@postponed_messages, [
            "Our effective UID (%d) and GID (%d) don't need to be checked",
            $EFFECTIVE_USER_ID,
            $EFFECTIVE_GROUP_ID
        ]);
    } elsif($euid_egid_ok == 1) {
        push(@postponed_messages, [
            'Our effective UID (%d) and GID (%d) are OK',
            $EFFECTIVE_USER_ID,
            $EFFECTIVE_GROUP_ID
        ]);
    } elsif($euid_egid_ok == 0) {
        MonkeyMan::Exception::SecurityCheckFailed->throwf(
            "Our effective UID (%d) and/or GID (%d) aren't OK",
            $EFFECTIVE_USER_ID,
            $EFFECTIVE_GROUP_ID
        );
    }

    foreach (keys(%{ $self->get_plugins_loaded })) {
        if($_ eq 'logger') {
            # The logger always goes first
            unshift(@plugins_to_load, $_);
            # The logger needs some extra parameters to set console verbosity
            $plugin_parameters{$_} = $self->_configure_logger_parameters(
                 $self->get_parameters->has_mm_default_logger ?
                 $self->get_parameters->get_mm_default_logger :
                 MM_DEFAULT_ACTOR
            );
        } else {
            push(@plugins_to_load, $_);
        }
    }

    foreach my $plugin_name (@plugins_to_load) {

        my $plugin_configuration = $self->get_plugins_loaded->{$plugin_name};
        push(@postponed_messages, [
            'Plugging the %s module according to the %s configuration',
            $plugin_name,
            $plugin_configuration
        ]);

        my %p;
        # Assigning the name of the plugin
        $p{'plugin_name'}               =   defined($plugin_configuration->{'plugin_name'}) ?
                                                    $plugin_configuration->{'plugin_name'} :
                                                    $plugin_name;
        # Passing some extra parameters to the actor's new() method
        $p{'actor_parameters'}          =   {
            # Do we have any special messages for the actor?
            scalar(keys(%{ $plugin_parameters{ $p{'plugin_name'} } })) ?
                        %{ $plugin_parameters{ $p{'plugin_name'} } } :
                        (),
        };
        # The plugin should have the monkeyman attribute pointing to the MonkeyMan-classed object
        $p{'actor_parent'}              =   $self;
        $p{'actor_parent_as'}           =   'monkeyman';
        # Of course, we'll need to know the class name
        $p{'actor_class'}               =   defined($plugin_configuration->{'actor_class'}) ?
                                                    $plugin_configuration->{'actor_class'} :
                                                    'MonkeyMan::' . camelize($p{'plugin_name'});
        # What will be the name of the attribute containing the default actor's name?
        my $n_actor_default_parameter   =   defined($plugin_configuration->{'actor_default_parameter'}) ?
                                                    $plugin_configuration->{'actor_default_parameter'} :
                                                    'get_mm_default_' . $p{'plugin_name'};
        # What actor is the default one?
        $p{'actor_default'}             =   defined($self->get_parameters->$n_actor_default_parameter) ?
                                                    $self->get_parameters->$n_actor_default_parameter :
                                                    defined($plugin_configuration->{'actor_default_actor'}) ?
                                                            $plugin_configuration->{'actor_default_actor'} :
                                                            MM_DEFAULT_ACTOR;
        # We'll add some methods to the parent class, so let's determine their names
        $p{'actor_handle'}              =   defined($plugin_configuration->{'actor_handle'}) ?
                                                    $plugin_configuration->{'actor_handle'} :
                                                    $p{'plugin_name'};
        my $n_actor_handle              =   'get_'. $p{'actor_handle'};
        $p{'plug_handle'}               =   defined($plugin_configuration->{'plug_handle'}) ?
                                                    $plugin_configuration->{'plug_handle'} :
                                                    $p{'plugin_name'} . '_plug';
        my $n_plug_handle               =   'get_'. $p{'plug_handle'};
        # And the last (not the least, though) - the configuration branch
        $p{'configuration_index'}       =   defined($plugin_configuration->{'configuration_index_branch'}) ?
                                                  $self->
                                                      get_configuration->
                                                          { $plugin_configuration->{'configuration_index_branch'} } :
                                                  $self->get_configuration->{ $p{'plugin_name'} };
        # The primary actor's configuration shall be present, we can't plug the module if it isn't
        unless(ref($p{'configuration_index'}) eq 'HASH' && defined($p{'configuration_index'}->{ $p{'actor_default'} })) {
            MonkeyMan::Exception::PluginConfigurationMissing->throwf(
                "The primary (ID: %s) actor's configuration for the %s plugin is missing",
                $p{'actor_default'},
                $p{'plugin_name'}
            );
        }

        MonkeyMan::Plug->plug(%p);

        if($plugin_name eq 'logger') { $logger = $self->$n_actor_handle }

        push(@postponed_messages, [
            "The %s module has been plugged, " .
                "so we've got the primary (ID: %s) actor: %s",
            $self->$n_plug_handle,
            $self->$n_plug_handle->get_actor_default,
            $self->$n_actor_handle
        ]);

        if(defined($logger)) {
            while(my $postponed = shift(@postponed_messages)) {
                $logger->tracef(@{$postponed});
            }
        }

    }

    $logger->tracef("We've got the framework %s initialized by PID %d at %s",
        $self,
        $$,
        $self->get_time_started_formatted
    );

    $logger->debugf("<%s> The framework has been initialized: %s",
        $self->get_time_passed_formatted,
        $self
    );

}



method _app_start {

    $self->get_logger->debugf("<%s> The application has been started",
        $self->get_time_passed_formatted
    );

}



method _app_run {

    &{ $self->{'app_code'}; }($self);

    $self->get_logger->debugf("<%s> The application has been executed",
        $self->get_time_passed_formatted
    );

}



method _app_finish {

    $self->get_logger->debugf("<%s> The application has been finished",
        $self->get_time_passed_formatted
    );

}



method _mm_shutdown {

    if(
        $self->can('get_logger') &&
        $self->get_logger->can('debugf')
    ) {
        $self->get_logger->debugf("<%s> The framework (%s) is shutting itself down",
            $self->get_time_passed_formatted,
            $self
        );
    }

}

END { try { MonkeyMan->instance->_mm_shutdown; } };




method _configure_logger_parameters(Str $actor_name) {

my %parameters;
    $parameters{'log4perl_configuration_file'} =
        defined($self->get_configuration->{'logger'}->{$actor_name}->{'log4perl'}) ?
                $self->get_configuration->{'logger'}->{$actor_name}->{'log4perl'} :
                undef;
    $parameters{'console_verbosity'} = CONSOLE_VERBOSITY_LEVEL_BASE + (
        defined($self->get_parameters->get_mm_be_verbose) ?
                $self->get_parameters->get_mm_be_verbose :
                0
    ) - (
        defined($self->get_parameters->get_mm_be_quiet) ?
                $self->get_parameters->get_mm_be_quiet :
                0
    );
    $parameters{'console_colored'} = 
        defined($self->get_parameters->get_mm_color) ?
                $self->get_parameters->get_mm_color :
                1;
    return(\%parameters);

}



method print_full_version_info {

    printf(<<__END_OF_VERSION_INFO__
%s (%s) driven by MonkeyMan (%s):

    %s

__END_OF_VERSION_INFO__
        ,   $self->get_app_name,
            $self->get_app_version,
            $self->get_mm_version,
            $self->get_app_description,
    );

}



method print_full_usage_help {

    my $app_usage_help = ref($self->get_app_usage_help) eq 'CODE' ?
        &{ $self->get_app_usage_help } :
           $self->get_app_usage_help;

    my $plugins_usage_help;
    foreach my $plugin_name (keys(%{ $self->get_plugins_loaded })) {
        my $plugin_configuration   = $self->get_plugins_loaded->{$plugin_name};
        $plugins_usage_help .= sprintf(
                (' ' x 4) . "--%s <ID> (the default actor is %s)\n" .
                (' ' x 8) . '[opt]' . (' ' x 7) . "%s\n",
            $plugin_configuration->{'parameter_key'},
            $plugin_configuration->{'actor_default_actor'},
            $plugin_configuration->{'parameter_help'}
        );
    }

    printf(<<__END_OF_USAGE_HELP__
%sIt%shandles the following set of MonkeyMan-wide parameteters:

    -h, --help
        [opt]       Print usage help text and do nothing
    -V, --version
        [opt]       Print version number and do nothing
    -C <filename>, --configuration <filename>
        [opt]       The main configuration file
    -v, --verbose
        [opt] [mul] Increases verbosity
    -q, --quiet
        [opt] [mul] Decreases verbosity
    --no-color
        [opt]       Suppresses colored output to console

%s
__END_OF_USAGE_HELP__
        , $app_usage_help ? ($app_usage_help . "\n") : ''
        , $app_usage_help ? ' also ' : ' '
        , $plugins_usage_help ? ("It also handles the following selectors:\n\n" . $plugins_usage_help) : ''
    );

}



method check_euid_egid(
    Maybe[HashRef]  :$security_configuration,
    Bool            :$try_to_set
) {

    unless(
        defined($security_configuration) &&
            ref($security_configuration) eq 'HASH'
    ) {
        return(undef);
    }

    for(my $i = 0; $i <= 1; $i++) {
        if(defined($security_configuration->{'desired_egid'})) {
            unless($security_configuration->{'desired_egid'} == $EFFECTIVE_GROUP_ID) {
                if($try_to_set && $i < 1) {
                    setgid($security_configuration->{'desired_egid'});
                } else {
                    return(0);
                }
            }
        }
        if(defined($security_configuration->{'desired_euid'})) {
            unless($security_configuration->{'desired_euid'} == $EFFECTIVE_USER_ID) {
                if($try_to_set && $i < 1) {
                    setuid($security_configuration->{'desired_euid'});
                } else {
                    return(0);
                }
            }
        }
    }

    return(1);

}



#__PACKAGE__->meta->make_immutable;

1;



