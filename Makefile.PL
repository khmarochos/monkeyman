#!/usr/bin/env perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'MonkeyMan',
    VERSION_FROM    => 'lib/MonkeyMan.pm',
    test            => {
        RECURSIVE_TEST_FILES    => 1
    }
);
