#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use ResourceCounter;

use TryCatch;
use DateTime;

my $collection = ResourceCounter->new;
ok($collection, "Object initialization");

$collection->init_period(
    { },
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 01,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    0,
    1
);
pass("Period initialization");

throws_ok {
    $collection->init_period(
        { },
        DateTime->new(
            year        => 1981,
            month       => 06,
            day         => 12,
            hour        => 00,
            minute      => 00,
            second      => 00,
            nanosecond  => 000000000,
            time_zone   => 'Europe/Kiev'
        ),
        DateTime->new(
            year        => 1981,
            month       => 06,
            day         => 12,
            hour        => 01,
            minute      => 00,
            second      => 00,
            nanosecond  => 000000000,
            time_zone   => 'Europe/Kiev'
        ),
        1,
        1
    )
} qr/period is already initialized/, "Initialization checks (1)";

throws_ok {
    $collection->init_period(
        { },
        DateTime->new(
            year        => 1981,
            month       => 06,
            day         => 11,
            hour        => 23,
            minute      => 30,
            second      => 00,
            nanosecond  => 000000000,
            time_zone   => 'Europe/Kiev'
        ),
        DateTime->new(
            year        => 1981,
            month       => 06,
            day         => 12,
            hour        => 00,
            minute      => 30,
            second      => 00,
            nanosecond  => 000000000,
            time_zone   => 'Europe/Kiev'
        ),
        2,
        1
    )
} qr/period overlaps/, "Initialization checks (2A)";

throws_ok {
    $collection->init_period(
        { },
        DateTime->new(
            year        => 1981,
            month       => 06,
            day         => 12,
            hour        => 00,
            minute      => 30,
            second      => 00,
            nanosecond  => 000000000,
            time_zone   => 'Europe/Kiev'
        ),
        DateTime->new(
            year        => 1981,
            month       => 06,
            day         => 12,
            hour        => 01,
            minute      => 30,
            second      => 00,
            nanosecond  => 000000000,
            time_zone   => 'Europe/Kiev'
        ),
        2,
        1
    )
} qr/period overlaps/, "Initialization checks (2B)";

$collection->add_resources(
    { r1 => 10, r2 => 20, r3 => 30 },
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 01,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    )
);
my $resources = $collection->get_resources(
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 01,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 10 && $resources->{'r2'} eq 20 && $resources->{'r3'} eq 30);

$collection->add_resources(
    { r1 => 10, r2 => 20, r3 => 30 },
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 01,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    )
);
$resources = $collection->get_resources(
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 01,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 20 && $resources->{'r2'} eq 40 && $resources->{'r3'} eq 60);

$collection->add_resources(
    { r1 => 10, r2 => 20, r3 => 30 },
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 11,
        hour        => 23,
        minute      => 30,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 30,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    )
);
$resources = $collection->get_resources(
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 30,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 20 && $resources->{'r2'} eq 40 && $resources->{'r3'} eq 60);
$resources = $collection->get_resources(
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 11,
        hour        => 23,
        minute      => 30,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 10 && $resources->{'r2'} eq 20 && $resources->{'r3'} eq 30);

done_testing;
