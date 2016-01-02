# NAME

MonkeyMan::CloudStack::API - Apache CloudStack API class

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

# DESCRIPTION

The [MonkeyMan::CloudStack::API](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::CloudStack::API) class encapsulates the interface to the
Apache CloudStack.

# METHODS

## `new`

```
$api = MonkeyMan::CloudStack::API->new(%parameters);
```

This method initializes the Apache CloudStack's API;

There are a few parameters that can (and need to) be defined:

- `cloudstack` ([MonkeyMan::CloudStack](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::CloudStack))

    MANDATORY. The reference to the [MonkeyMan::CloudStack](https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/MonkeyMan::CloudStack) object.

    The value is readable by `get_cloudstack()`.

- `configuration_tree` (HashRef)

    Optional. The configuration tree. If it's not defined, the builder will fetch
    it from the MonkeyMan::CloudStack's configuration tree.

    The value is readable by `get_configuration_tree()`.

- `useragent` (Object)

    Optional. By default it will create a new LWP::UserAgent object and use it for
    making calls to Apache CloudStack API. I don't recommend you to redefine it,
    but who I am to teach you, huh? :)

    The value is readable by `get_configuration_tree()`.

- `useragent_signature` (Str)

    Optional. The signature that will be used as the User-Agent header in all
    outgoing HTTP requests. By default it will looke like that:

    The value is readable by `get_useragent_signature()`, writeable as
    `set_useragent_signature()`.

    >     APP-6.6.6 (powered by MonkeyMan-6.6.6) (libwww-perl/6.6.6)

    Please, note: if you don't use the default useragent, your one should be aware
    of this parameter.

## `run_command`

## `get_doms`

## `get_elements`

## `qxp`
