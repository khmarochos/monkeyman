# NAME

MonkeyMan - Apache CloudStack Management Framework

# DESCRIPTION

This is a framework that makes possible to manage the
[Apache CloudStack](http://cloudstack.apache.org/) based cloud infrastructure
with high-level Perl5-applications.

![The mascot has been originaly created by D.Kolesnichenko for Tucha.UA](http://tucha.ua/wp-content/uploads/2013/08/monk.png)

# SYNOPSIS

```perl
MonkeyMan->new(
    app_code            => \&MyCoolApplication,
    app_name            => 'apps/cool/mine.pl',
    app_description     => "Discovers objects' relations",
    app_version         => '6.6.6',
    parse_parameters    => {
        'd|domain_id=s' => 'domain_id'
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
# 2040/04/20 04:20:00 [I] [main] The  virtual machine's ID is 01234567-dead-beef-cafe-899123456789 - got as [MonkeyMan::CloudStack::API::Element::VirtualMachine@0xdeadbee/badcaffefeeddeafbeefbabedeadface]
# 
# Hope you'll enjoy it :)
#
```

# MODULES' HIERARCHY

...

# METHODS

## `new()`

```perl
MonkeyMan->new(%parameters => %Hash)
```

This method initializes the framework and runs the application.

There are a few parameters that can (and need to) be defined:

### Application-Related Parameters

#### `app_code`

MANDATORY. Contains a `CodeRef` pointing to the code of the application that
needs to be run. The reader's name is `get_app_code`.

#### `app_name`

MANDATORY. Contains a `Str` of the application's full name. The reader's name
is `get_app_name`.

#### `app_description`

MANDATORY. Contains a `Str` of the application's description. The reader's name
is `get_app_description`.

#### `app_version`

MANDATORY. Contains a `Str` of the application's version number. The reader's
name is `get_app_version`.

#### `app_usage_help`

Optional. Contains a `Str` to be displayed when the user asks for help. The
reader's name is `get_app_usage_help`.

### Configuration-Related Parameters

#### `parameters_to_get`

Optional. Contains a `HashRef`. This parameter shall be a reference to a hash
containing parameters to be passed to the [Getopt::Long](https://metacpan.org/pod/Getopt::Long)::GetOptions()
function.  It sets the the `parameters` attribute with the `get_parameters()`
accessor which returns a reference to the [MonkeyMan::Parameters](https://metacpan.org/pod/MonkeyMan::Parameters) object
containing the information about startup parameters. Thus,

```perl
parameters_to_get => {
    'i|input=s'     => 'file_in',
    'o|output=s'    => 'file_out'
}
```

will create [MonkeyMan::Parameters](https://metacpan.org/pod/MonkeyMan::Parameters) object with `get_file_in` and
`get_file_out` read-only accessors, so you could address them as

```
$monkeyman->get_parameters->get_file_in,
$monkeyman->get_parameters->get_file_out
```

You can define various startup parameters, but there are some special
ones that shouldn't be redefined:

- `-h`, `--help`

    The show-help-and-terminate mode. Sets the `mm_show_help` attribute, the
    accessor is `get_mm_show_help()`.

- `-V`, `--version`

    The show-version-and-terminate mode. Sets the `mm_show_version` attribute, the
    accessor is `get_mm_show_version()`.

- `<-c <filename` >>, `--configuration=<filename>`

    The name of the main configuration file. Sets the `mm_configuration`
    attribute. The accessor is `get_mm_configuration()`.

- `-v`, `--verbose`

    Increases the debug level, the more times you add it, the higher level is. The
    default level is INFO, for more information about logging see
    [MonkeyMan::Logger](https://metacpan.org/pod/MonkeyMan::Logger) documentation. Sets the `mm_be_verbose` attribute, the
    accessor is `get_mm_be_verbose()`.

- `-q`, `--quiet`

    Does the opposite of what the previous one does - it decreases the debug level.
    Sets the `mm_be_quiet` attribute, the accessor is is `get_mm_be_quiet()`.

#### `configuration`

Optional. Contains a reference to the hash containing the framework's
configuration tree. If it's not defined (in most cases), the framework will try
to parse the configuration file. The name of the file can be passed with the
`-c|--configuration` startup parameter.

```
# MM_DIRECTORY_ROOT/etc/monkeyman.conf contains:
#          <log>
#  .           <PRIMARY>
#                  <dump>
#                      enabled = 1
$log->debugf("The dumper is %s,
    $mm->get_configuration
        ->{'log'}
            ->{'PRIMARY'}
                ->{'dump'}
                    ->{'enabled'} ? 'enabled' : 'disabled'
);
```

If the configuration is neither defined as the constructor parameter nor
defined by the startup parameter, the framework attempts to find the
configuration file at the location defined as the `MM_CONFIG_MAIN` constant.

### Helpers-Related Parameters

#### `loggers`

Optional. Contains a `HashRef` with links to [MonkeyMan::Logger](https://metacpan.org/pod/MonkeyMan::Logger)
modules, so you can use multiple interfaces to multiple cloudstack with the
`get_logger()` method described below.

#### `cloudstacks`

Optional. Contains a `HashRef` with links to [MonkeyMan::CloudStack](https://metacpan.org/pod/MonkeyMan::CloudStack) modules.
The `get_cloudstack()` method helps to get the CloudStack instance by its
handle is described below.

## get\_app\_code()

## get\_app\_name()

## get\_app\_description()

## get\_app\_usage\_help()

## get\_app\_version()

Readers for corresponding modules attributes. These attributes are being set
when initializing the framework, so see ["MonkeyMan Application-Related
Parameters"](#monkeyman-application-related-parameters) for details.

## get\_parameters()

## get\_parameters\_to\_get()

The first accessor returns the reference to the [MonkeyMan::Parameters](https://metacpan.org/pod/MonkeyMan::Parameters) object
containing **results** of parsing command-line parameters according to the rules
defined by the `parameters_to_get` initialization parameter.

The second one returns the reference to the hash containing the **ruleset** of
parsing the command-line parameters that have been defined by the
&lt;parameters\_to\_get> initialization parameter, but with addition of some default
rules (such as `'h|help'`, `'V|version'` and so on) added by the framework on
its own.

See ["MonkeyMan Configuration-Related Parameters"](#monkeyman-configuration-related-parameters) section of the ["new()"](#new)
method's documentation for more information.

## get\_configuration()

This accessor returns the reference to the hash containing the framework's
configuration tree.

## get\_logger()

## get\_loggers()

The `get_logger()` accessor returns the reference to [MonkeyMan::Logger](https://metacpan.org/pod/MonkeyMan::Logger)
requested. If the ID hasn't been specified, it returns the instance identified
as `PRIMARY`.

```
ok($mm->get_logger() == $mm->get_logger(&MM_PRIMARY_LOGGER));
ok($mm->get_logger() == $mm->get_logger('PRIMARY');
```

The `PRIMARY` logger is being initialized proactively by the framework, but
it's also possible to initialize it by oneself in the case will you need it.

```perl
%my_loggers = (&MM_PRIMARY_LOGGER => MonkeyMan::Logger->new(...));
$mm = MonkeyMan->new(loggers => \%my_loggers, ...);
```

Please, keep in mind that `PRIMARY` is the default logger's handle, it's
defined by the `MM_PRIMARY_LOGGER` constant.

The `get_loggers` returns the reference to the hash containing the loggers'
index, which means the following:

```
ok($mm->get_logger('Log-13') == $mm->get_loggers->{'Log-13'});
```

## get\_cloudstack()

## get\_cloudstacks()

These accessors behaves very similar to `get_logger()` and `get_loggers()`,
but the index contains references to [MonkeyMan::CloudStack](https://metacpan.org/pod/MonkeyMan::CloudStack) objects
initialized. The default CloudStack instance's name is `PRIMARY`, it's defined
as the `MM_PRIMARY_CLOUDSTACK` constant.

## get\_mm\_version()

The name of the method is pretty self-descriptive: the accessor returns the
framework's version ID.

# HOW IT WORKS

...
