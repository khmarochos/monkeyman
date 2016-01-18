#!/usr/bin/env perl

use ExtUtils::MakeMaker;

WriteMakefile(
    ABSTRACT_FROM   => 'lib/MonkeyMan.pm',
    AUTHOR          => 'Volodymyr Melnyk <vladimir@melnik.net.ua>',
    LICENSE         => 'Apache',
    NAME            => 'MonkeyMan',
    VERSION_FROM    => 'lib/MonkeyMan.pm',
    test            => {
        RECURSIVE_TEST_FILES    => 1
    }
);
