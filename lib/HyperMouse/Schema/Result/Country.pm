use utf8;
package HyperMouse::Schema::Result::Country;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::Country

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<HyperMouse::Schema::DefaultResult::HyperMouse>

=item * L<HyperMouse::Schema::DefaultResult::I18nRelationships>

=item * L<HyperMouse::Schema::DefaultResult::DeepRelationships>

=item * L<DBIx::Class::Helper::Row::SelfResultSet>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components(
  "+HyperMouse::Schema::DefaultResult::HyperMouse",
  "+HyperMouse::Schema::DefaultResult::I18nRelationships",
  "+HyperMouse::Schema::DefaultResult::DeepRelationships",
  "Helper::Row::SelfResultSet",
  "InflateColumn::DateTime",
  "EncodedColumn",
);

=head1 TABLE: C<country>

=cut

__PACKAGE__->table("country");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 valid_from

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 valid_till

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 removed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 2

=head2 default_language_id

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
  "valid_from",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
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
  "code",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "default_language_id",
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

=head2 country_x_contractor_types

Type: has_many

Related object: L<HyperMouse::Schema::Result::CountryXContractorType>

=cut

__PACKAGE__->has_many(
  "country_x_contractor_types",
  "HyperMouse::Schema::Result::CountryXContractorType",
  { "foreign.country_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 default_language

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Language>

=cut

__PACKAGE__->belongs_to(
  "default_language",
  "HyperMouse::Schema::Result::Language",
  { id => "default_language_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 writeoffs

Type: has_many

Related object: L<HyperMouse::Schema::Result::Writeoff>

=cut

__PACKAGE__->has_many(
  "writeoffs",
  "HyperMouse::Schema::Result::Writeoff",
  { "foreign.currency_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-08-17 21:37:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b2pIe66swven9tg4jM1nMQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
