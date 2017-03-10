use utf8;
package HyperMouse::Schema::Result::CountryXContractorType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::CountryXContractorType

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::I18nRelationships>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components(
  "I18nRelationships",
  "InflateColumn::DateTime",
  "EncodedColumn",
);

=head1 TABLE: C<country_x_contractor_type>

=cut

__PACKAGE__->table("country_x_contractor_type");

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

=head2 country_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 contractor_type

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

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
  "country_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "contractor_type",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contractor_type

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ContractorType>

=cut

__PACKAGE__->belongs_to(
  "contractor_type",
  "HyperMouse::Schema::Result::ContractorType",
  { id => "contractor_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 country

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Country>

=cut

__PACKAGE__->belongs_to(
  "country",
  "HyperMouse::Schema::Result::Country",
  { id => "country_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-11 15:06:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wAsBMzQsgMJgPkwlz02c1A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
