package HyperMouse::Schema::ResultSet::ResourceType;

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'HyperMouse::Schema::DefaultResultSet';

use HyperMouse::Exception qw(UnknownResourceType);

use Method::Signatures;
use DateTime;



method find_by_full_name(
    Str         :$resource_type_full_name!,
    Bool        :$strict?   = 1,
    DateTime    :$now?      = DateTime->now
) {

    my @name_pieces = split(/\./, $resource_type_full_name);
    my $resource_type;
    my $resource_types = $self
        ->get_schema
        ->resultset('ResourceType')
        ->filter_validated(mask => 0b000111, now => $now);
    my $parent_resource_type_id;

    while(my $name_piece = shift(@name_pieces)) {
        $resource_type = $resource_types
            ->find({
                defined($parent_resource_type_id)
                    ? (parent_resource_type_id  => $parent_resource_type_id)
                    : (                                                  ),
                short_name => $name_piece,
            })
            // do {
                $strict
                    ? (__PACKAGE__ . '::Exception::UnknownResourceType')->throwf(
                            "Can't find the %s resource type",
                            $resource_type_full_name,
                    ) : return(undef);
            };
    }

    return($resource_type);

}



__PACKAGE__->meta->make_immutable;

1;

