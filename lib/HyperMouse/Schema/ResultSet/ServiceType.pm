package HyperMouse::Schema::ResultSet::ServiceType;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use HyperMouse::Exception qw(
    UnknownServiceFamily
    UnknownServiceGroup
    UnknownServiceType
);

use Method::Signatures;



method find_by_full_name(
    Str     :$service_type_full_name!,
    Bool    :$strict = 1
) {

    my(
        $service_family_short_name,
        $service_group_short_name,
        $service_type_short_name,
    ) = split(/\./, $service_type_full_name);

    my $service_family = $self
        ->get_schema
        ->resultset('ServiceFamily')
        ->search({ short_name => $service_family_short_name })
        ->filter_validated(mask => 0b000111)
        ->single;
    defined($service_family) || ($strict
        ? (__PACKAGE__ . '::Exception::UnknownServiceFamily')->throwf(
                "Can't find the %s service family",
                $service_family_short_name,
        ) : return(undef));

    my $service_group = $self
        ->get_schema
        ->resultset('ServiceGroup')
        ->search({
            short_name          => $service_group_short_name,
            service_family_id   => $service_family->id
        })
        ->filter_validated(mask => 0b000111)
        ->single;
    defined($service_group) || ($strict
        ? (__PACKAGE__ . '::Exception::UnknownServiceGroup')->throwf(
            "Can't find the %s.%s service group)",
            $service_family_short_name,
            $service_group_short_name,
        ) : return(undef));

    my $service_type = $self
        ->get_schema
        ->resultset('ServiceType')
        ->search({
            short_name          => $service_type_short_name,
            service_group_id    => $service_group->id
        })
        ->filter_validated(mask => 0b000111)
        ->single;
    defined($service_type) || ($strict
        ? (__PACKAGE__ . '::Exception::UnknownServiceType')->throwf(
            "Can't find the %s.%s.%s service type)",
            $service_family_short_name,
            $service_group_short_name,
            $service_type_short_name
        ) : return(undef));

    return($service_type);

}



__PACKAGE__->meta->make_immutable;

1;

