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

## `new()`

```
$api = MonkeyMan::CloudStack::API->new(%parameters);
```

This method initializes the Apache CloudStack's API connector;

There are a few parameters that can (and need to) be defined:

### Parental Object Parameters

#### `cloudstack`

MANDATORY. Supposed to be a reference to the [MonkeyMan::CloudStack](https://metacpan.org/pod/MonkeyMan::CloudStack) object. The
connecter can't be initialized outside of MonkeyMan, so you need to have the
parental object initialized if you need to use CloudStack's API.

The value is readable by `get_cloudstack()`.

### Configuration-Related Parameters

#### `configuration`

Optional. A `HashRef` pointing to the configuration tree. If it's not defined,
the builder will try to fetch it from the parental [MonkeyMan::CloudStack](https://metacpan.org/pod/MonkeyMan::CloudStack)'s
configuration tree.

The value is readable by `get_configuration()`.

### Useragent-Related Parameters

#### `useragent`

Optional. By default the builder creates a new [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) object and use it
for making calls to Apache CloudStack API. I don't recommend you to redefine it,
but you can do it.

The value is readable by `get_useragent()`.

#### `useragent_signature`

Optional. Contains a `Str` of the signature that will be used as the User-Agent
header in all outgoing HTTP requests. By default it looks like that:

> APP-6.6.6 (powered by MonkeyMan-6.6.6) (libwww-perl/6.6.6)

The value is readable by `get_useragent_signature()`, writeable as
`set_useragent_signature()`.

Please, note: if you use your own useragent instead of the default one, you
should make it always taking into consideration this parameter's value!

### Caching Parameters

#### `cache`

## `test()`

```
$api->test;
```

This method doesn't do anything but testing connection to the API. It raises
an exception if something's wrong with it.

## `run_command()`

This method is needed to run an API command.

```perl
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

Reurns a reference to the [XML::LibXML::Document](https://metacpan.org/pod/XML::LibXML::Document) DOM containing the responce.

This method recognizes the following parameters:

### What To Run?

It's mandatory to set one of below-mentioned parameters. If there are no
`parameters`, `command` or `url` defined, the exception will be raised.

#### `parameters`

The command can be run with a hash of parameters including the command's name.
The key and the signature will be applied automatically.

#### `command`

The command can be set as a pre-created [MonkeyMan::CloudStack::API::Command](https://metacpan.org/pod/MonkeyMan::CloudStack::API::Command)
object. Although, it's being created automatically when `parameters` are set.

#### `url`

The command can be run by touching an URL containing the command, its
parameters, the key and the signature.

### How To Run?

Also it accepts the following optional parameters.

#### `wait`

Contains and `Int`. If it turns out to be an asynchronous job, how much time
should we wait for the result.

If it's greater than 0, we'll wait N seconds for the asynchronous job
to complete, where N is the parameter's value.

```perl
$api->run(
    parameters => { command => 'performSomeCoolThing', id => '...' },
    wait => 300
);
# Will wait for 300 seconds and either return the result or raise an
# exception if timeout occures.
```

If it less than 0, we'll wait N seconds, where N will be got either
from the `$self-`get\_configuration->{'wait'}> configuration optopm or from the
`MM_CLOUDSTACK_API_WAIT_FOR_FINISH` constant.

```perl
$api->run(
    parameters => { command => 'performSomeCoolThing', id => '...' },
    wait => -1
);
# Will wait as long as possible.
```

If it eqials 0, we won't wait for the result, but we won't raise an
exception, we'll just pass the result to the caller as is.

```perl
$api->run(
    parameters => { command => 'performSomeCoolThing', id => '...' },
    wait => 0
);
# Won't wait for anything, just returns the job information.
```

#### `fatal_empty`

Contains `Bool`. Raises an exception if the result is empty. Deafault value is
0.

#### `fatal_fail`

Contains `Bool`. Raises an exception if the failure is occured. Deafault value
is 1.

#### `fatal_431`

...

## `get_doms()`

The method returns the list of DOMs of elements of type defined matching
XPath-condtions defined. You probably won't need it, because it only performs
dirty work for `get_elements()` which can return DOMs as well.

Anyhow, it consumes the following parameters:

#### `type`

MANDATORY. The type of elements that needs to be found, types are described in
the [MonkeyMan::CloudStack::API::Element::TYPE](https://metacpan.org/pod/MonkeyMan::CloudStack::API::Element::TYPE) manual.

#### `criterions`

Optional. 

#### `xpaths`

## `get_elements()`

This method finds infrastructure elements by the criterions defined.

```perl
foreach my $vm ($api->get_elements(
    type        => 'VirtualMachine',
    criterions  => { host => 'hX.cX.pX.zX' },
    xpaths      => [ '/virtualmachine[host = "hX.cX.pX.zX"]' ]
)) {
    ok($vm->get_id, $vm->get_dom->findvalue('/virtualmachine/id');
}
```

## `qxp()`

This method queries the DOM (as [XML::LibXML::Document](https://metacpan.org/pod/XML::LibXML::Document)) provided 
with the XPath-query provided.

```perl
$dom = $api->run_command(
    command     => 'listVirtualMachines',
    listAll     => 'true'
);
```

It can give you values:

```perl
foreach my $id ($api->qxp(
    dom         => $dom,
    query       => '/listvirtualmachinesresponse' .
                        '/virtualmachine' .
                        '[nic/ipaddress = "13.13.13.13"]' .
                        '/id',
    return_as   => 'value'
) {
    $log->tracef("Found %s", $id);
}
```

It can give you elements:

```perl
foreach my $vm ($api->qxp(
    dom         => $dom,
    query       => '/listvirtualmachinesresponse' .
                        '/virtualmachine' .
                        '[nic/ipaddress = "13.13.13.13"]'
    return_as   => 'element[VirtualMachine]'
) {
    $log->tracef("Found %s", $vm->get_id);
}
```

See below the full list of possible values for the `return_as` parameter.

#### `dom`

#### `query`

#### `return_as`

This parameter defines what kind of results are expected.

- `value`

    Returns results as regular scalars.

- `dom`

    Returns results as new [XML::LibXML::Document](https://metacpan.org/pod/XML::LibXML::Document) DOMs.

- `element[TYPE]`

    Returns results as `MonkeyMan::CloudStack::API::Element::TYPE` objects.

- `id[TYPE]`

    Returns results as IDs fetched from freshly-created
    `MonkeyMan::CloudStack::API::Element::TYPE` objects.

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 741:

    '=item' outside of any '=over'
