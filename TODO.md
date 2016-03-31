Things To Do
============

Code
----

 - [ ] Get rid of `MonkeyMan::CloudStack::API::Element::*::_magic_words` and
       other ugly things, use the brand new `%*::vocabulary` hashtree.
 - [ ] Add the `fatal` parameter to all vocabulary-related methods.
        - suggested on `2016.02.09` by `melnik13`
 - [ ] Make it possible to dump all data structures right to the same log-file
       where it has been mentioned.
        - suggested on `2016.01.28` by `melnik13`
 - [ ] Move command-line parameters manupulations to `MonkeyMan::Parameters`
        - suggested on `2016.01.19` by `melnik13`
 - [ ] Make some helper to find the framework's library directory
        - on `2016.01.17` by `melnik13`
 - [ ] Build a proper `Makefile`
        - suggested on `2016.01.17` by `melnik13`
 - [ ] Use the `MonkeyMan::CloudStack::Types::*` types everywhere
        - on `2016.01.18` by `melnik13`
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

 - [ ] Port bin/makesnapshots.pl from the `stables` branch to
       the `dev_melnik13_v3` one
        - suggested on `2016.01.18` by `melnik13`
 - [x] Let the user set the default `MonkeyMan::Logger` instance
        - suggested on `2016.01.19` by `melnik13`
        - completed on `2016.01.19`
 - [x] Let the user set the default `MonkeyMan::CloudStack` instance
        - suggested on `2016.01.19` by `melnik13`
        - completed on `2016.01.19`
