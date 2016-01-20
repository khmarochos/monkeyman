Change Log
==========



`v2.1.1-dev_melnik13_v3`
------------------------

### Added

 - Now we can not only just handle multiple `MonkeyMan::Logger` and
   `MonkeyMan::CloudStack` objects configured and used, we can set the default
   one by the `--default-logger` and `--default-cloudstack` framework-wide
   command-line parameters.
 - The command-line parameters defined by the `parameters_to_get` attribute of
   the `MonkeyMan` class are being more strictly checked now.
 - The `MonkeyMan::Parameters` now has the `only_one()` method to check if some
   parameters given are superflous.
 - The `bin/runcmd.pl` utility has been added.
 - The `bin/vminfo.pl` now proceeds multiple XPath queries.
 - Added the `MonkeyMan::CloudStack::Types` library with some types.
 - Some new bugs have been added too.

### Fixed

 - Fixed a bug in `MonkeyMan::CloudStack:API' which used to make us neglecting
   the `ignore_431_code` configuration parameter.
 - Fixed a bug in `MooseX::Handies` which led to some epic fails.



`v2.1.0-dev_melnik13_v3`
------------------------

Released on 2016-01-16

### Notes

 - The initial release

