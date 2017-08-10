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
} qr/period is already initialized/i, "Initialization checks (1)";

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
} qr/period overlaps/i, "Initialization checks (2A)";

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
# 1981-06-12 00:00:00 - 1981-06-12 01:00:00 { r1 => 10, r2 => 20, r3 => 30 }
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
ok($resources->{'r1'} eq 10 && $resources->{'r2'} eq 20 && $resources->{'r3'} eq 30, 'Adding and getting resources (1A)');

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
# 1981-06-12 00:00:00 - 1981-06-12 01:00:00 { r1 => 20, r2 => 40, r3 => 60 }
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
ok($resources->{'r1'} eq 20 && $resources->{'r2'} eq 40 && $resources->{'r3'} eq 60, 'Adding and getting resources (1B)');

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
# 1981-06-11 23:30:00 - 1981-06-12 00:00:00 { r1 => 10, r2 => 20, r3 => 30 }
# 1981-06-12 00:00:00 - 1981-06-12 00:30:00 { r1 => 30, r2 => 60, r3 => 90 }
# 1981-06-12 00:30:00 - 1981-06-12 01:00:00 { r1 => 20, r2 => 40, r3 => 60 }
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
ok($resources->{'r1'} eq 10 && $resources->{'r2'} eq 20 && $resources->{'r3'} eq 30, 'Adding and getting resources (2A)');
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
ok($resources->{'r1'} eq 30 && $resources->{'r2'} eq 60 && $resources->{'r3'} eq 90, 'Adding and getting resources (2B)');
$resources = $collection->get_resources(
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
        minute      => 00,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 20 && $resources->{'r2'} eq 40 && $resources->{'r3'} eq 60, 'Adding and getting resources (2C)');

$collection->add_resources(
    { r1 => 10, r2 => 20, r3 => 30 },
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 15,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 45,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    )
);
# 1981-06-11 23:30:00 - 1981-06-12 00:00:00 { r1 => 10, r2 => 20, r3 => 30 }
# 1981-06-12 00:00:00 - 1981-06-12 00:15:00 { r1 => 30, r2 => 60, r3 => 90 }
# 1981-06-12 00:15:00 - 1981-06-12 00:30:00 { r1 => 40, r2 => 80, r3 => 120 }
# 1981-06-12 00:30:00 - 1981-06-12 00:45:00 { r1 => 30, r2 => 60, r3 => 90 }
# 1981-06-12 00:45:00 - 1981-06-12 10:00:00 { r1 => 20, r2 => 40, r3 => 60 }
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
ok($resources->{'r1'} eq 10 && $resources->{'r2'} eq 20 && $resources->{'r3'} eq 30, 'Adding and getting resources (3A)');
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
        minute      => 15,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 30 && $resources->{'r2'} eq 60 && $resources->{'r3'} eq 90, 'Adding and getting resources (3B)');
$resources = $collection->get_resources(
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 15,
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
ok($resources->{'r1'} eq 40 && $resources->{'r2'} eq 80 && $resources->{'r3'} eq 120, 'Adding and getting resources (3C)');
$resources = $collection->get_resources(
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
        hour        => 00,
        minute      => 45,
        second      => 00,
        nanosecond  => 000000000,
        time_zone   => 'Europe/Kiev'
    ),
    1
);
ok($resources->{'r1'} eq 30 && $resources->{'r2'} eq 60 && $resources->{'r3'} eq 90, 'Adding and getting resources (3D)');
$resources = $collection->get_resources(
    DateTime->new(
        year        => 1981,
        month       => 06,
        day         => 12,
        hour        => 00,
        minute      => 45,
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
ok($resources->{'r1'} eq 20 && $resources->{'r2'} eq 40 && $resources->{'r3'} eq 60, 'Adding and getting resources (3E)');

throws_ok {
    $collection->get_resources(
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
    )
} qr/no such period/i, 'Period existance';

#TODO: add more tests to make sure that each possible scenario works properly

done_testing;
