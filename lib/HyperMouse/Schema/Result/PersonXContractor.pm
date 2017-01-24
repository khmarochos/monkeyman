use utf8;
package HyperMouse::Schema::Result::PersonXContractor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::PersonXContractor

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<person_x_contractor>

=cut

__PACKAGE__->table("person_x_contractor");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 valid_since

  data_type: 'integer'
  is_nullable: 0

=head2 valid_till

  data_type: 'integer'
  is_nullable: 1

=head2 removed

  data_type: 'integer'
  is_nullable: 1

=head2 person_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 contractor_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 admin

  data_type: 'tinyint'
  is_nullable: 0

=head2 billing

  data_type: 'tinyint'
  is_nullable: 0

=head2 tech

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "valid_since",
  { data_type => "integer", is_nullable => 0 },
  "valid_till",
  { data_type => "integer", is_nullable => 1 },
  "removed",
  { data_type => "integer", is_nullable => 1 },
  "person_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "contractor_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "admin",
  { data_type => "tinyint", is_nullable => 0 },
  "billing",
  { data_type => "tinyint", is_nullable => 0 },
  "tech",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contractor

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Contractor>

=cut

__PACKAGE__->belongs_to(
  "contractor",
  "HyperMouse::Schema::Result::Contractor",
  { id => "contractor_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 person

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "HyperMouse::Schema::Result::Person",
  { id => "person_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-24 14:37:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2KK5KdOEJwspglBU/DcVpw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
