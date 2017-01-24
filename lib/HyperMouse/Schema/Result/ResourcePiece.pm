use utf8;
package HyperMouse::Schema::Result::ResourcePiece;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ResourcePiece

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<resource_piece>

=cut

__PACKAGE__->table("resource_piece");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 valid_since

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 valid_till

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 removed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 resource_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 resource_host_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 resource_handle

  data_type: 'varchar'
  is_nullable: 0
  size: 127

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "valid_since",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "valid_till",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "removed",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "resource_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "resource_host_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "resource_handle",
  { data_type => "varchar", is_nullable => 0, size => 127 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 resource_host

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ResourceHost>

=cut

__PACKAGE__->belongs_to(
  "resource_host",
  "HyperMouse::Schema::Result::ResourceHost",
  { id => "resource_host_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 resource_type

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ResourceType>

=cut

__PACKAGE__->belongs_to(
  "resource_type",
  "HyperMouse::Schema::Result::ResourceType",
  { id => "resource_type_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 service_obligation_x_resource_pieces

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceObligationXResourcePiece>

=cut

__PACKAGE__->has_many(
  "service_obligation_x_resource_pieces",
  "HyperMouse::Schema::Result::ServiceObligationXResourcePiece",
  { "foreign.resource_piece_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-24 14:37:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0usFl+3EZKHjhLD6kMO36w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;