# NAME

MonkeyMan::CloudStack::API - Apache CloudStack API class

# DESCRIPTION

The [MonkeyMan::CloudStack::API](https://metacpan.org/pod/MonkeyMan::CloudStack::API) class encapsulates the interface to the
Apache CloudStack.

# SYNOPSIS

```perl
my $api = MonkeyMan::CloudStack::API->new(
    cloudstack = 
);

my $result = $api->run_command(
    parameters  => {
        command     => 'login',
        username    => 'admin',
        password    => '1z@Lo0pA3',
        domain      => 'ZALOOPA'
    },
    wait        => 0,
    fatal_empty => 1,
    fatal_fail  => 1
);
```

# METHODS

## `new`

```
$api = MonkeyMan::CloudStack::API->new(%parameters);
```

This method initializes the Apache CloudStack's API;

There are a few parameters that can (and need to) be defined:

- `cloudstack` ([MonkeyMan::CloudStack](https://metacpan.org/pod/MonkeyMan::CloudStack))

    MANDATORY. The reference to the [MonkeyMan::CloudStack](https://metacpan.org/pod/MonkeyMan::CloudStack) object.

    The value is readable by `get_cloudstack()`.

- `configuration_tree` (HashRef)

    Optional. The configuration tree. If it's not defined, the builder will fetch
    it from the MonkeyMan::CloudStack's configuration tree.

    The value is readable by `get_configuration_tree()`.

- `useragent` (Object)

    Optional. By default it will create a new [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) object and use it 
    for making calls to Apache CloudStack API. I don't recommend you to redefine
    it, but who I am to teach you, huh? :)

    The value is readable by `get_useragent()`.

- `useragent_signature` (Str)

    Optional. The signature that will be used as the User-Agent header in all
    outgoing HTTP requests. By default it will looke like that:

    >     APP-6.6.6 (powered by MonkeyMan-6.6.6) (libwww-perl/6.6.6)

    The value is readable by `get_useragent_signature()`, writeable as
    `set_useragent_signature()`.

    Please, note: if you use your own useragent instead of the default one, you
    should make it always taking into consideration this parameter's value!

## `test`

```
$api->test;
```

This method doesn't do anything but testing connection to the API. It raises
an exception if something's wrong with it.

## `run_command`

```perl
This method is needed to run an API command.

# Defining some options
my %options = (
    wait        => 0,
    fatal_empty => 1,
    fatal_fail  => 1,
    fatal_431   => 0
);

# Running a command with a list of parameters
my $parameters => {
    command => 'listApis',
    listAll => 'true'
};
$api->run_command(
    parameters => $parameters,
    %options
);

# Running a pre-defined command object
my $command = MonkeyMan::CloudStack::API::Command->new(
    parameters => $parameters
);
$api->run_command(
    command => $command,
    %options
);

# Touching a pre-defined URL
$url = $command->get_url;
$api->run_command(
    url => $url
    %options
);
```

This method recognizes the following parameters:

- `parameters` (HashRef)

    The command can be run with a hash of parameters including the command's name.
    The key and the signature will be applied automatically.

- `command` ([MonkeyMan::CloudStack::API::Command](https://metacpan.org/pod/MonkeyMan::CloudStack::API::Command))

    The command can be set as a pre-created object. Although, it's being created
    automatically when `parameters` are set.

- `url` (Str)

    The command can be run by touching an URL containing the command, its
    parameters, the key and the signature.

It's mandatory to set one of 3 above-mentioned parameters. If there are no
`parameters`, `command` or `url` defined, the exception will be raised.

- `wait` (Int)
- `fatal_empty` (Bool)
- `fatal_fail` (Bool)
- `fatal_431` (Bool)

## `get_doms`

## `get_elements`

## `qxp`
