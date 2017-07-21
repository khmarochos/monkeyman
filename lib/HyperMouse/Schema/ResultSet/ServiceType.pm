package HyperMouse::Schema::ResultSet::ServiceType;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use HyperMouse::Exception qw(UnknownServiceType);

use Method::Signatures;
use DateTime;



method find_by_full_name(
    Str         :$service_type_full_name!,
    Bool        :$strict?   = 1,
    DateTime    :$now?      = DateTime->now
) {

    my @name_pieces = split(/\./, $service_type_full_name);
    my $service_type;
    my $service_types = $self
        ->get_schema
        ->resultset('ServiceType')
        ->filter_validated(mask => 0b000111, now => $now);
    my $parent_service_type_id;

    while(my $name_piece = shift(@name_pieces)) {
        $service_type = $service_types
            ->find({
                defined($parent_service_type_id)
                    ? (parent_service_type_id  => $parent_service_type_id)
                    : (                                                  ),
                short_name => $name_piece,
            })
            // do {
                $strict
                    ? (__PACKAGE__ . '::Exception::UnknownServiceType')->throwf(
                            "Can't find the %s service type",
                            $service_type_full_name,
                    ) : return(undef);
            };
    }

    return($service_type);

}



__PACKAGE__->meta->make_immutable;

1;

