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
    app_name            => 'apps/cool/mine',
    app_description     => 'It does good job',
    app_version         => '6.6.6',
    parse_parameters    => {
        'd|domain_id=s' => 'domain_id'
    }
);

sub MyCoolApplication {

    my $mm  = shift;
    my $log = $mm->get_logger;

    $log->debugf("We were asked to find the '%s' domain",
        $mm->get_parameters->get_domain_id
    );

    # The CloudStack API is amazingly easy to use, refer to the
    # MonkeyMan::CloudStack::API documentation
    my $api = $mm->get_cloudstack->get_api;

    # Let's find the domain by its ID
    foreach my $d ($api->get_elements(
        type        => 'Domain',
        criterions  => {
            id  => $mm->get_parameters->get_domain_id
        }
    )) {

        # Okay, now let's find all the virtual machines
        # related to the domain we found
        foreach my $vm ($d->get_related(type => 'VirtualMachine')) {
            $log->infof("The %s %s's ID is %s\n",
                $vm,
                $vm->get_type(noun => 1),
                $vm->get_id
            );
        }

    }

}
```

# METHODS

## `new`

```perl
MonkeyMan->new(%parameters => %Hash)
```

This method initializes the framework and runs the application.

There are a few parameters that can (and need to) be defined:

- `app_code` (CodeRef)

    MANDATORY.  The reference to the subroutine that will do all the job.

- `app_name` (Str)

    MANDATORY. The application's full name.

- `app_description` (Str)

    MANDATORY. The application's description.

- `app_version` (Str)

    MANDATORY. The application's version number.

- `app_usage_help` (Str)

    Optional. The text to be displayed when the user asks for help.

- `parameters_to_get` (HashRef)

    Optional. This parameter shall be a reference to a hash containing parameters
    to be passed to the [Getopt::Long->GetOptions()](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/Getopt::Long->GetOptions\(\)) method (on the left
    corresponding names of accessors to values of startup parameters. It sets the
    the `parameters` attribute which returns a reference to the
    [MonkeyMan::Parameters](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Parameters) object containing the information about startup
    parameters. Thus,

    ```perl
    parameters_to_get => {
        'i|input=s'     => 'file_in',
        'o|output=s'    => 'file_out'
    }
    ```

    will create [MonkeyMan::Parameters](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Parameters) object with `get_file_in` and
    `get_file_out` read-only accessors, so you could address them as

    ```
    $monkeyman->get_parameters->get_file_in,
    $monkeyman->get_parameters->get_file_out
    ```

    You can define various startup parameters, but there are some special
    ones that shouldn't be redefined:

    - `-h`, `--help`

        The print-help-and-exit mode. Sets the `mm_show_help` attribute, the accessor
        is `get_mm_show_help()`.

    - `-V`, `--version`

        The print-version-and-exit mode. Sets the `mm_show_version` attribute, the
        accessor is `get_mm_show_version()`.

    - `-c [filename]`, `--configuration=[filename]`

        The name of the main configuration file. Sets the `mm_configuration`
        attribute. The accessor is `get_mm_configuration()`.

    - `-v`, `--verbose`

        Increases the debug level, the more times you add it, the higher level is. The
        default level is INFO, for more information about logging see
        [MonkeyMan::Logger](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Logger) documentation. Sets the `mm_be_verbose` attribute, the
        accessor is `get_mm_be_verbose()`.

    - `-q`, `--quiet`

        Does the opposite of what the previous one does - it decreases the debug level.
        Sets the `mm_be_quiet` attribute, the accessor is is `get_mm_be_quiet()`.

- `configuration` ([MonkeyMan::Configuration](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Configuration))

    Optional. You can create a configuration object and pass its reference to
    the framework. If it's not defined, the framework will try to fetch the
    configuration from the file. The name of the configuration file can be passed
    with the `-c|--configuration` startup parameter. If it isn't hasn't defined as
    this constructor parameter and hasn't been defined by the startup parameter, the
    framework attempts to find the configuration file at the location defined as the
    `MM_CONFIG_MAIN` constant.

    [MonkeyMan::Configuration](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Configuration) provides the `get_tree()` accessor, which returns
    the reference to the hash containing all the configuration loaded.

    ```
    # MM_DIRECTORY_ROOT/etc/monkeyman.conf contains:
    #   <log>
    #     <PRIMARY>
    #       <dump>
    #         enabled = 1
    $log->infof("The dumper is %s,
        $mm->get_configuration->get_tree
            ->{'log'}
                ->{'PRIMARY'}
                    ->{'dump'} ? 'enabled' | 'disabled'
    );
    ```

## 
