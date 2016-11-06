package MonkeyMan;

=head1 NAME

MonkeyMan - Apache CloudStack Management Framework

=head1 DESCRIPTION

This is a framework that makes possible to manage the
L<Apache CloudStack|http://cloudstack.apache.org/> based cloud infrastructure
with high-level Perl5-applications.

=begin markdown

![The mascot has been originaly created by D.Kolesnichenko for Tucha.UA](http://tucha.ua/wp-content/uploads/2013/08/monk.png)

=end markdown

=head1 SYNOPSIS

    MonkeyMan->new(
        app_code            => \&MyCoolApplication,
        app_name            => 'apps/cool/mine.pl',
        app_description     => "Discovers objects' relations",
        app_version         => '6.6.6',
        parameters_to_get   => {
            'd|domain_id=s'     => 'domain_id'
        }
    );

    sub MyCoolApplication {

        $mm  = shift;
        $log = $mm->get_logger;

        # The CloudStack API is amazingly easy to use, refer to the
        # MonkeyMan::CloudStack::API documentation
        $api = $mm->get_cloudstack->get_api;

        # Let's find the domain by its ID
        foreach my $d ($api->get_elements(
            type        => 'Domain',
            criterions  => {
                id  => $mm->get_parameters->get_domain_id
            }
        )) {

            # Okay, now let's find all the virtual machines
            # related to the domain we found
            foreach $vm ($d->get_related(type => 'VirtualMachine')) {
                $log->infof("The %s's ID is %s - got as %s\n",
                    $vm->get_type(noun => 1),
                    $vm->get_id,
                    $vm,
                );
            }

        }

    }

    # > apps/cool/mine.pl -d 01234567-89ab-cdef-fedc-ba9876543210
    # 2040/04/20 04:20:00 [I] [main] The virtual machine's ID is 01234567-dead-beef-cafe-899123456789 - got as [MonkeyMan::CloudStack::API::Element::VirtualMachine@0xdeadbee/badcaffefeeddeafbeefbabedeadface]
    # 
    # Hope you'll enjoy it :)
    #

=head1 MODULES' HIERARCHY

...

=cut

use 5.20.1;
use strict;
use warnings;

our $VERSION='v2.1.0-dev_melnik13_v3';

# Use Moose and be happy :)
use Moose 2.1604;
use namespace::autoclean;

# Add some roles
with 'MonkeyMan::Roles::WithTimer';
# This is a role to implement the timer attributes for the MonkeyMan class
# (the time_started attribute and some methods to work with it)

use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Utils qw(mm_load_package);
use MonkeyMan::Exception qw(CanNotLoadPackage);
use MonkeyMan::Parameters;
use MonkeyMan::Plug;

# Use 3rd-party libraries
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



=head1 METHODS

=head2 C<new()>

    MonkeyMan->new(%parameters => %Hash)

This method initializes the framework and runs the application.

=cut

method BUILD(...) {

    $self->_mm_init;

    if(defined($self->get_app_code)) {
        $self->_app_start;
        $self->_app_run;
        $self->_app_finish;
    }

    END { MonkeyMan->instance->_mm_shutdown; };

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

=head4 C<app_code>

MANDATORY. Contains a C<CodeRef> pointing to the code of the application that
needs to be run. The reader's name is C<get_app_code>.

=cut

has 'app_code' => (
    is          => 'ro',
    isa         => 'Maybe[CodeRef]',
    reader      => 'get_app_code',
    predicate   => 'has_app_code'
);

=head4 C<app_name>

MANDATORY. Contains a C<Str> of the application's full name. The reader's name
is C<get_app_name>.

=cut

has 'app_name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_name',
    writer      => '_set_app_name'
);

=head4 C<app_description>

MANDATORY. Contains a C<Str> of the application's description. The reader's name
is C<get_app_description>.

=cut

has 'app_description' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_description',
    writer      => '_set_app_description'
);

=head4 C<app_version>

MANDATORY. Contains a C<Str> of the application's version number. The reader's
name is C<get_app_version>.

=cut

has 'app_version' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    reader      =>  'get_app_version',
    writer      => '_set_app_version'
);

=head4 C<app_usage_help>

Optional. Contains a C<Str> to be displayed when the user asks for help. The
reader's name is C<get_app_usage_help>.

=cut

has 'app_usage_help' => (
    is          => 'ro',
    isa         => 'CodeRef|Str',
    required    => 0,
    reader      =>  'get_app_usage_help',
    predicate   =>  'has_app_usage_help',
    writer      => '_set_app_usage_help'
);



=head3 Configuration-Related Parameters

=head4 C<parameters_to_get>

THIS PARAMETER MAY BE DEPRECATED, ONE SHOULD USE C<parameters_to_get_and_check>

Optional. Contains a C<HashRef>. This parameter shall be a reference to a hash
containing parameters to be passed to the L<Getopt::Long>::GetOptions()
function.  It sets the the C<parameters> attribute with the C<get_parameters()>
accessor which returns a reference to the L<MonkeyMan::Parameters> object
containing the information about startup parameters. Thus,

    parameters_to_get => {
        'i|input=s'     => 'file_in',
        'o|output=s'    => 'file_out'
    }

will create L<MonkeyMan::Parameters> object with C<get_file_in> and
C<get_file_out> read-only accessors, so you could address them as

    $monkeyman->get_parameters->get_file_in,
    $monkeyman->get_parameters->get_file_out

You can define various startup parameters, but there are some special
ones that shouldn't be redefined:

=over

=item C<-h>, C<--help>

The show-help-and-terminate mode. Sets the C<mm_show_help> attribute, the
accessor is C<get_mm_show_help()>.

=item C<-V>, C<--version>

The show-version-and-terminate mode. Sets the C<mm_show_version> attribute, the
accessor is C<get_mm_show_version()>.

=item C<<-c <filename> >>, C<< --configuration=<filename> >>

The name of the main configuration file. Sets the C<mm_configuration>
attribute. The accessor is C<get_mm_configuration()>.

=item C<-v>, C<--verbose>

Increases the debug level, the more times you add it, the higher level is. The
default level is INFO, for more information about logging see
L<MonkeyMan::Logger> documentation. Sets the C<mm_be_verbose> attribute, the
accessor is C<get_mm_be_verbose()>.

=item C<-q>, C<--quiet>

Does the opposite of what the previous one does - it decreases the debug level.
Sets the C<mm_be_quiet> attribute, the accessor is is C<get_mm_be_quiet()>.

=back

=cut

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

=head4 C<parameters_to_get_validated>

Optional. Contains a YAML-based configuration of the command-line parameters
need to be parsed and validated.

Overrides values of C<parameters_to_get>. Basically fucks C<parameters_to_get>
off to tell you the truth.

=cut

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

    return(MonkeyMan::Parameters->new(monkeyman => $self));

}



=head4 C<configuration>

Optional. Contains a reference to the hash containing the framework's
configuration tree. If it's not defined (in most cases), the framework will try
to parse the configuration file. The name of the file can be passed with the
C<-c|--configuration> startup parameter.

    # MM_DIRECTORY_ROOT/etc/monkeyman.conf contains:
    #          <log>
    #              <PRIMARY>
    #                  <dump>
    #                      enabled = 1
    $log->debugf("The dumper is %s,
        $mm->get_configuration
            ->{'log'}
                ->{'PRIMARY'}
                    ->{'dump'}
                        ->{'enabled'} ? 'enabled' : 'disabled'
    );

If the configuration is neither defined as the constructor parameter nor
defined by the startup parameter, the framework attempts to find the
configuration file at the location defined as the C<MM_CONFIG_MAIN> constant.

=cut

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

=head4 C<configuration_append>

=cut

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



=head3 Helpers-Related Parameters

=cut

=head2 get_app_code()

=head2 get_app_name()

=head2 get_app_description()

=head2 get_app_usage_help()

=head2 get_app_version()

Readers for corresponding modules attributes. These attributes are being set
when initializing the framework, so see L</MonkeyMan Application-Related
Parameters> for details.

=head2 get_parameters()

=head2 get_parameters_to_get()

The first accessor returns the reference to the L<MonkeyMan::Parameters> object
containing B<results> of parsing command-line parameters according to the rules
defined by the C<parameters_to_get> initialization parameter.

The second one returns the reference to the hash containing the B<ruleset> of
parsing the command-line parameters that have been defined by the
<parameters_to_get> initialization parameter, but with addition of some default
rules (such as C<'h|help'>, C<'V|version'> and so on) added by the framework on
its own.

See L</MonkeyMan Configuration-Related Parameters> section of the L</new()>
method's documentation for more information.

=head2 get_configuration()

This accessor returns the reference to the hash containing the framework's
configuration tree.

=head2 get_logger()

=head2 get_loggers()

The C<get_logger()> accessor returns the reference to L<MonkeyMan::Logger>
requested. If the ID hasn't been specified, it returns the default instance.

You should keep in mind that the default instance can be reassigned by
the C<--default-logger> framework-wide command-line parameter. By
default, the default logger's ID is C<PRIMARY>, as it's defined by the
C<MM_DEFAULT_LOGGER_ID> constant.

    $default_logger_given   = $mm->get_parameters->default_logger;
    $default_logger_used    = $mm->_get_default_logger;

    if(defined($default_logger_given) {
        ok($default_logger_used eq $default_logger_given);
        ok($mm->get_logger == $mm->get_logger($default_logger_used));
    } else {
        ok($default_logger_used eq &MM_DEFAULT_LOGGER_ID);
        ok($mm->get_logger == $mm->get_logger(&MM_DEFAULT_LOGGER_ID));
    }

The default logger is being initialized proactively by the framework, but
it's also possible to initialize it by oneself in the case one needs it.

    $my_loggers = {
        zaloopa => MonkeyMan::Logger->new(...),
        ebuchka => MonkeyMan::Logger->new(...),
        pizdets => MonkeyMan::Logger->new(...)
    };
    $mm = MonkeyMan->new(
        loggers             => $my_loggers,
        default_logger_id   => 'zaloopa'
    );

The C<get_loggers> returns the reference to the hash containing the loggers'
index, which leads to the following:

    ok($mm->get_logger('zaloopa') == $mm->get_loggers->{'zaloopa'});

=head2 get_cloudstack()

=head2 get_cloudstacks()

These accessors behave very similar to C<get_logger()> and C<get_loggers()>,
but the index contains references to L<MonkeyMan::CloudStack> objects
initialized.

The default CloudStack instance's ID can be set by the
C<--default-cloudstack> parameter, by default it's C<PRIMARY>, as it's
defined as the C<MM_DEFAULT_CLOUDSTACK_ID> constant.

=head2 get_password_generator()

=head2 get_password_generators()

...

=cut

=head2 get_mm_version()

The name of the method is pretty self-descriptive: the accessor returns the
framework's version ID.

=cut



method plug(
    Str             :$plugin_name!,
    Str             :$actor_class!,
    Object          :$actor_parent,
    Maybe[Str]      :$actor_parent_as?,
    Maybe[Str]      :$actor_name_as?,
    Maybe[Str]      :$actor_default?,
    Maybe[HashRef]  :$actor_parameters?,
    Maybe[Str]      :$actor_handle?         = $plugin_name              when undef,
    Maybe[Str]      :$plug_handle?          = $plugin_name . '_plug'    when undef,
    Maybe[HashRef]  :$configuration_index?
) {

    my %p;
    $p{'plugin_name'}           = $plugin_name;
    $p{'actor_class'}           = $actor_class;
    $p{'actor_parent'}          = $actor_parent;
    $p{'actor_parent_as'}       = $actor_parent_as      if(defined($actor_parent_as));
    $p{'actor_name_as'}         = $actor_name_as        if(defined($actor_name_as));
    $p{'actor_default'}         = $actor_default        if(defined($actor_default));
    $p{'actor_parameters'}      = $actor_parameters     if(defined($actor_parameters));
    $p{'actor_handle'}          = $actor_handle;
    $p{'plug_handle'}           = $plug_handle;
    $p{'configuration_index'}   = $configuration_index  if(defined($configuration_index));

    my $plug_object = MonkeyMan::Plug->new(%p);

    my $parent_meta = $actor_parent->meta;
    # FIXME: I should check now if the plug nasn't been initalized yet, so we
    # wouldn't install the plugin's method and attribute again, as it would
    # lead to exception raising

    # Now we'll add the method get_SOMETHING (where SOMETHING is the value of
    # the actor_handle parameter) to the parent class
    $parent_meta->add_method(
        "get_$actor_handle" => sub { shift; $plug_object->get_actor($_[0]); }
    );
    # And don't forget to add the attribute with the name taken from the
    # plug_handle parameter to the parent class as well
    $parent_meta->add_attribute(
        $plug_handle        => (
            isa         => 'MonkeyMan::Plug',
            is          => 'ro',
            reader      =>          'get_' . $plug_handle,
            writer      => my $w = '_set_' . $plug_handle,
            predicate   =>         '_has_' . $plug_handle,
        )
    );
    # And initialize its value (add the reference to the plug)
    $actor_parent->$w($plug_object);

    # We'll definitely need it later
    mm_load_package($actor_class);

    return($plug_object);

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

    # Connecting plugins
    foreach my $plugin_name (keys(%{ $self->get_plugins_loaded })) {

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
        # The plugin should have the monkeyman attribute pointing to MonkeyMan
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
        unless(ref($p{'configuration_index'}) eq 'HASH' && defined($p{'configuration_index'}->{ $p{'actor_default'} })) {
            push(@postponed_messages, [
                'The primary (ID: %s) actor\'s configuration is missing, skipping the %s module',
                $p{'actor_default'},
                $p{'plugin_name'}
            ]);
            next; # The rest aint going to happen, dude!
        }

        $self->plug(%p);

        push(@postponed_messages, [
            "The %s module has been plugged, " .
                "so we've got the primary (ID: %s) actor: %s",
            $self->$n_plug_handle,
            $self->$n_plug_handle->get_actor_default,
            $self->$n_actor_handle
        ]);

        if($plugin_name eq 'logger') { $logger = $self->$n_actor_handle }

    }

    while(my $postponed = shift(@postponed_messages)) { $logger->tracef(@{$postponed}); }

    $logger->tracef("We've got the framework %s initialized by PID %d at %s",
        $self,
        $$,
        $self->get_time_started_formatted
    );

    $logger->debugf("<%s> The framework has been initialized",
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
        $self->get_logger->debugf("<%s> The framework is shutting itself down",
            $self->get_time_passed_formatted,
            $self
        );
    }

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
        , $app_usage_help ? ' also ' : ' ',
        , $plugins_usage_help ? ("It also handles the following selectors:\n\n" . $plugins_usage_help) : ''
    );

}



#__PACKAGE__->meta->make_immutable;

1;



=head1 HOW IT WORKS

...

=cut
