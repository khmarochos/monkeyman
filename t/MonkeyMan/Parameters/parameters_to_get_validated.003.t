#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib("$FindBin::Bin/../../../lib");

use Method::Signatures;
use Test::More tests => 13;
use IPC::Open3;


# requires_each for self-required parameters

cmp_ok(test_validation(
    parameters  => [qw(-e)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    requires_each:
      - ebashevo
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '==', 0, 'A self-required parameter is given (should be OK)');

cmp_ok(test_validation(
    parameters  => [qw()],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    requires_each:
      - ebashevo
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '!=', 0, 'A self-required parameter is missing (should fail)');

# requires_each

cmp_ok(test_validation(
    parameters  => [qw(-e -z -p)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    requires_each:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '==', 0, 'All required parameres are given (should be OK)');

cmp_ok(test_validation(
    parameters  => [qw(-e -z)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    requires_each:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '!=', 0, 'Some of required parameters aren\'t given (should fail)');

# requires_any

cmp_ok(test_validation(
    parameters  => [qw(-e -z)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    requires_any:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '==', 0, 'At least one of required parameters is given (should be OK)');

cmp_ok(test_validation(
    parameters  => [qw(-e)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    requires_any:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '!=', 0, 'None of required parameters are given (should fail)');

# conflicts_any

cmp_ok(test_validation(
    parameters  => [qw(-e)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    conflicts_any:
      - zaloopa
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '==', 0, 'None of conflicting parameters are given (should be OK)');

cmp_ok(test_validation(
    parameters  => [qw(-e -z)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    conflicts_any:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '!=', 0, 'One of conflicting parameters is given (should be OK)');

# conflicts_each

cmp_ok(test_validation(
    parameters  => [qw(-e -z)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    conflicts_each:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '==', 0, 'Only one of conflicting parameters is given (should be OK)');

cmp_ok(test_validation(
    parameters  => [qw(-e -z -p)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    conflicts_each:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '!=', 0, 'All conflicting parameters are given (should fail)');

# Sorted rules

cmp_ok(test_validation(
    parameters  => [qw(-e -z -p)],
    yaml        => <<__YAML__
---
e|ebashevo:
  ebashevo:
    conflicts_each.ZALOOPA&PIZDETS:
      - zaloopa
      - pizdets
    conflicts_each.PIZDETS&ZALOOPA:
      - zaloopa
      - pizdets
z|zaloopa:
  zaloopa
p|pizdets:
  pizdets
__YAML__
), '!=', 0);

# Regexp matching

cmp_ok(test_validation(
    parameters  => [qw(-e 13)],
    yaml        => <<__YAML__
---
e|ebashevo=s:
  ebashevo:
    matches_each:
     - .+
     - 6+
__YAML__
), '==', 0);

cmp_ok(test_validation(
    parameters  => [qw(-e 666)],
    yaml        => <<__YAML__
---
e|ebashevo=s:
  ebashevo:
    matches_any:
     - 1+
     - 3+
__YAML__
), '!=', 0);


done_testing; exit;



func test_validation(
    ArrayRef    :$parameters!,
    Str         :$yaml!
) {
    my $pid = open3(
        \*PROBE_IN,
        \*PROBE_OUT,
        \*PROBE_ERR,
        $FindBin::Bin . '/parameters_to_get_validated.YAML-STDIN.t',
        @{ $parameters }
    );
    print(PROBE_IN $yaml); close(PROBE_IN);
    my $error = <PROBE_ERR>; close(PROBE_ERR); diag($error) if defined($error);
    close(PROBE_OUT);
    waitpid($pid, 0);
    return($?);
}

