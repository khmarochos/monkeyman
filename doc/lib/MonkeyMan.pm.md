# NAME

MonkeyMan - Apache CloudStack Management Framework

![The mascot has been originaly created by D.Kolesnichenko for Tucha.UA](http://tucha.ua/wp-content/uploads/2013/08/monk.png)

# SYNOPSIS

```perl
MonkeyMan->new(
    app_code            => \&MyCoolApplication,
    parse_parameters    => {
        'd|domain_id=s' => 'domain_id'
    }
);

sub MyCoolApplication {

    my $mm  = shift;
    my $log = $mm->get_logger;

    $log->debugf("We were asked to find the '%s' domain",
        $mm->get_parameters->domain_id
    );

    my $api = $mm->get_cloudstack->get_api;

    # Find the domain by its ID
    foreach my $d ($api->get_elements(
        type        => 'Domain',
        criterions  => { id  => '01234567-89ab-cdef-0123-456789abcdef' }
    )) {

        # Find the virtual machines related to the domain
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

    This attribute requires a reference to a hash containing parameters to be
    passed to the [Getopt::Long->GetOptions()](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/Getopt::Long->GetOptions\(\)) method (on the left
    corresponding names of sub-methods to get values of startup parameters. It
    creates the `parameters` method which returns a reference to the
    [MonkeyMan::Parameters](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Parameters) object containing the information of startup
    parameters accessible via corresponding methods. Thus,

    ```perl
    parameters_to_get => {
        'i|input=s'     => 'file_in',
        'o|output=s'    => 'file_out'
    }
    ```

    will create [MonkeyMan::Parameters](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::Parameters) object with `file_in` and `file_out`
    methods, so you could address them as

    ```
    $monkeyman->get_parameters->file_in,
    $monkeyman->get_parameters->file_out
    ```
