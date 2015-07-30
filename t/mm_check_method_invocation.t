#!/usr/bin/env perl

use strict;
use warnings;

use Test::More ( tests => 11 );
use TryCatch;

use FindBin qw($Bin); use lib "$Bin/../lib";
use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::Elements::VirtualMachine;

my $mm;
my $cs;
my $element;

try {
    $mm = MonkeyMan->new();
} catch(MonkeyMan::Error $e) {
    $e->throw;
} catch($e) {
    MonkeyMan::Error->throw_f("Can't MonkeyMan->new(): %s", $e);
}

try {
    $cs = $mm->init_cloudstack;
} catch(MonkeyMan::Error $e) {
    $e->throw;
} catch($e) {
    MonkeyMan::Error->throw_f("Can't %s->init_cloudstack(): %s", $mm, $e);
}

try {
    $element = MonkeyMan::CloudStack::Elements::VirtualMachine->new(
        cs  => $cs
    );
} catch(MonkeyMan::Error $e) {
    $e->throw;
} catch($e) {
    MonkeyMan::Error->throw_f("Can't  MonkeyMan::CloudStack::Elements::VirtualMachine->init_cloudstack(): %s", $e);
}

my $test_variable;

# 1

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => 13,
                variable    => \$test_variable
            }
        }
    );
    is($test_variable, 13);
} catch($e) {
    fail($e);
}

# 2

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => 13,
                variable    => $test_variable
            }
        }
    );
    fail;
} catch(MonkeyMan::Error::MethodInvocationCheck::TargetInvalid $e) {
    pass;
} catch($e) {
    fail($e);
}

# 3

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => [],
                isaref      => 'ARRAY'
            }
        }
    );
    pass;
} catch($e) {
    fail($e);
}

# 4

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {}
        }
    );
    fail;
} catch(MonkeyMan::Error::MethodInvocationCheck::ParameterUndefined $e) {
    pass;
} catch($e) {
    fail($e);
}

# 5

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => {},
                isaref      => 'HOOSH'
            }
        }
    );
    fail;
} catch(MonkeyMan::Error::MethodInvocationCheck::ParameterInvalid $e) {
    pass;
} catch($e) {
    fail($e);
}

# 6

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => {},
                isaref      => 'HOOSH',
                error       => 'OOPS'
            }
        }
    );
    fail;
} catch(MonkeyMan::Error::MethodInvocationCheck::ParameterInvalid $e where { $_->message eq 'OOPS' }) {
    pass;
} catch($e) {
    fail($e);
}

# 7

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => undef,
            }
        }
    );
    fail;
} catch($e) {
    pass;
}

# 8

try {
    mm_check_method_invocation(
        object  => $mm,
        checks  => {
            '$something' => {
                value       => undef,
                careless    => 1
            }
        }
    );
    pass;
} catch($e) {
    fail($e);
}

# 9

try {
    mm_check_method_invocation(
        object  => $cs,
        checks  => {
            'mm'    => {
                variable    => \$test_variable
            }
        }
    );
    isa_ok($test_variable, 'MonkeyMan');
} catch($e) {
    fail($e);
}

# 10

try {
    mm_check_method_invocation(
        object  => $element,
        checks  => {
            'cs_api' => {
                variable    => \$test_variable
            }
        }
    );
    isa_ok($test_variable, 'MonkeyMan::CloudStack::API');
} catch($e) {
    fail($e);
}

# 11

try {
    mm_check_method_invocation(
        object  => $element,
        checks  => {
            'cs_cache' => {
                variable    => \$test_variable
            }
        }
    );
    isa_ok($test_variable, 'MonkeyMan::CloudStack::Cache');
} catch($e) {
    fail($e);
}
