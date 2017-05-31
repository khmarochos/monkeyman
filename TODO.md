Things To Do 1
============

Bugs
----

 - [ ] Make `HyperMouse` see the exceptions of `MonkeyMan`.
        - suggested on `2017.05.31` by `melnik13`
 - [x] Fix `MonkeyMan::CloudStack::API::Vocabulary::interpret_response`.
        - suggested on `2016.07.25` by `melnik13`
        - completed on `2016.07.25`

Code
----

 - [ ] Make all the lists' templates (templates/*/list.html.ep) using
       the same approach as templates/provisioning_agreement/list.html.ep
       does when it calls the snippet/table.html.ep: passing an ArrayRef
       with to the list of the tables to be displayed
        - suggested on `2017.05.30` by `melnik13`
 - [ ] Make all the buttons on the /list/* pages working properly and
       displaying the tables of the related stuff
        - suggested on `2017.05.30` by `melnik13`
 - [ ] Translate the vocabularies to YAML.
        - suggested on `2017.01.30` by `melnik13`
 - [ ] Get rid of the `is_dom_expired()` method and the `dom_updated` and
       `dom_best_before` attributes of the
       `MonkeyMan::CloudStack::API::Roles::Element` class.
 - [ ] Make sure that the `best_before` parameter works fine for all methods.
        - suggested on `2017.01.10` by `melnik13`
 - [ ] Encapsulate all the shit!
        - suggested on `2016.11.06` by `melnik13`
 - [ ] Make the `MonkeyMan`'s `plug` method checking if the plugin has been
       installed already.
        - suggested on `2016.07.04` by `melnik13`
 - [ ] Add the `EXCEPTION` method on demand when loading the
       `MonkeyMan::Exception` package.
        - suggested on `2016.04.07` by `melnik13`
 - [ ] Add the `fatal` parameter to all vocabulary-related methods.
        - suggested on `2016.02.09` by `melnik13`
 - [ ] Make some helper to find the framework's library directory
        - on `2016.01.17` by `melnik13`
 - [ ] Build a proper distribution.
        - suggested on `2016.01.17` by `melnik13`
 - [ ] Use the `MonkeyMan::CloudStack::Types::*` types everywhere.
        - on `2016.01.18` by `melnik13`
 - [x] Let other applications use `MonkeyMan` as a module, not as a framework
        - suggested on `2016.11.04` by `melnik13`
	- completed on `2017.01.10`
 - [x] Make handies pluggable with `MonkeyMan::Plugin` role, get rid of
       `MooseX::Handies` and "handies".
        - suggested on `2016.04.23` by `melnik13`
        - completed on `2016.04.26`
 - [x] Rebase handies initializers to roles
        - suggested on `2016.04.21` by `melnik13`
        - rejected on `2016.04.25` by `melnik13`
 - [x] Make `MonkeyMan::CloudStack` being initialized by the method referenced
       in the `_initialize_cloudstack` handies' attribute.
        - suggested on `2016.04.20` by `melnik13`
        - completed on `2016.04.20`
 - [x] Make `MonkeyMan::Logger` being initialized by the method referenced
       in the `_initialize_logger` handies' attribute.
        - suggested on `2016.04.20` by `melnik13`
        - completed on `2016.04.20`
 - [x] Make `MonkeyMan::PasswordGenerator` configurable.
        - suggested on `2016.04.18` by `melnik13`
        - completed on `2016.04.19`
 - [x] Move command-line parameters manupulations to `MonkeyMan::Parameters`
        - suggested on `2016.01.19` by `melnik13`
        - completed on `2016.04.17`
 - [x] Get rid of `MonkeyMan::CloudStack::API::Element::*::_magic_words` and
       other ugly things, use the brand new `%*::vocabulary` hashtree.
        - completed on `2016.04.17`
 - [x] Add the `compose_command()` and `interpret_response()` methods to the
       `MonkeyMan::CloudStack::API` class.
        - suggested on `2016.02.09` by `melnik13`
	- completed on `2016.02.16`
 - [x] Add the `perform_action()` method to the `MonkeyMan::CloudStack::API`
       class.
        - suggested on `2016.02.09` by `melnik13`
        - completed on `2016.02.16`
 - [x] Use `%::*::_magic_words in t/qxp.t`
        - suggested on `2016.01.17` by `melnik13`
        - completed on `2016.01.17`

Functionality
-------------

 - [ ] Make `bin/cloudstack/makesnapshots.pl` support more than one queues
       for the same domain (see `Tucha#2016062913000542`)
        - suggested on `2016.06.13` by `melnik13`
 - [ ] Make it possible to dump all the data structures right to the same
       log-file where it has been mentioned (as an option).
        - suggested on `2016.01.28` by `melnik13`
 - [x] Port `bin/cloudstack/makesnapshots.pl` from the `stables` branch to
       the current one
        - suggested on `2016.01.18` by `melnik13`
 - [x] Let the user set the default `MonkeyMan::Logger` instance
        - suggested on `2016.01.19` by `melnik13`
        - completed on `2016.01.19`
 - [x] Let the user set the default `MonkeyMan::CloudStack` instance
        - suggested on `2016.01.19` by `melnik13`
        - completed on `2016.01.19`

Documentation
-------------

 - [ ] Just describe some shit for the god's sake...
        - suggested on `2017.05.30` by `melnik13`
 - [ ] Present brand new `parameters_to_get_validated` attribute of
       `MonkeyMan::Parameters`, it's really worth to be mentioned
        - suggested on `2016.04.17` by `melnik13`
