use utf8;
package HyperMouse::Schema::Result::Language;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::Language

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<language>

=cut

__PACKAGE__->table("language");

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

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 name_native

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 5

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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "name_native",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 5 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contractor_type_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ContractorTypeName>

=cut

__PACKAGE__->has_many(
  "contractor_type_names",
  "HyperMouse::Schema::Result::ContractorTypeName",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 countries

Type: has_many

Related object: L<HyperMouse::Schema::Result::Country>

=cut

__PACKAGE__->has_many(
  "countries",
  "HyperMouse::Schema::Result::Country",
  { "foreign.default_language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 currency_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::CurrencyName>

=cut

__PACKAGE__->has_many(
  "currency_names",
  "HyperMouse::Schema::Result::CurrencyName",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 people

Type: has_many

Related object: L<HyperMouse::Schema::Result::Person>

=cut

__PACKAGE__->has_many(
  "people",
  "HyperMouse::Schema::Result::Person",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 resource_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ResourceName>

=cut

__PACKAGE__->has_many(
  "resource_names",
  "HyperMouse::Schema::Result::ResourceName",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_family_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceFamilyName>

=cut

__PACKAGE__->has_many(
  "service_family_names",
  "HyperMouse::Schema::Result::ServiceFamilyName",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_group_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceGroupName>

=cut

__PACKAGE__->has_many(
  "service_group_names",
  "HyperMouse::Schema::Result::ServiceGroupName",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_level_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceLevelName>

=cut

__PACKAGE__->has_many(
  "service_level_names",
  "HyperMouse::Schema::Result::ServiceLevelName",
  { "foreign.lanuage_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceName>

=cut

__PACKAGE__->has_many(
  "service_names",
  "HyperMouse::Schema::Result::ServiceName",
  { "foreign.language_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-24 12:14:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b1E72BwgvqKLtY/gR92mmA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
