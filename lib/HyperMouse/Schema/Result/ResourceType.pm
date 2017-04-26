use utf8;
package HyperMouse::Schema::Result::ResourceType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ResourceType

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<HyperMouse::Schema::DefaultResult::I18nRelationships>

=item * L<HyperMouse::Schema::DefaultResult::DeepRelationships>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components(
  "+HyperMouse::Schema::DefaultResult::I18nRelationships",
  "+HyperMouse::Schema::DefaultResult::DeepRelationships",
  "InflateColumn::DateTime",
  "EncodedColumn",
);

=head1 TABLE: C<resource_type>

=cut

__PACKAGE__->table("resource_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 valid_since

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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 resource_pieces

Type: has_many

Related object: L<HyperMouse::Schema::Result::ResourcePiece>

=cut

__PACKAGE__->has_many(
  "resource_pieces",
  "HyperMouse::Schema::Result::ResourcePiece",
  { "foreign.resource_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 resource_type_i18ns

Type: has_many

Related object: L<HyperMouse::Schema::Result::ResourceTypeI18n>

=cut

__PACKAGE__->has_many(
  "resource_type_i18ns",
  "HyperMouse::Schema::Result::ResourceTypeI18n",
  { "foreign.resource_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-26 08:31:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B4VzbU7fY1DLwAkxc2eGKQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
