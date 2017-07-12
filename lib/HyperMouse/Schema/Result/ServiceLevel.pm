use utf8;
package HyperMouse::Schema::Result::ServiceLevel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ServiceLevel

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

=head1 TABLE: C<service_level>

=cut

__PACKAGE__->table("service_level");

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

=head2 short_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

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
  "short_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 provisioning_obligations

Type: has_many

Related object: L<HyperMouse::Schema::Result::ProvisioningObligation>

=cut

__PACKAGE__->has_many(
  "provisioning_obligations",
  "HyperMouse::Schema::Result::ProvisioningObligation",
  { "foreign.service_level_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_level_i18ns

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceLevelI18n>

=cut

__PACKAGE__->has_many(
  "service_level_i18ns",
  "HyperMouse::Schema::Result::ServiceLevelI18n",
  { "foreign.service_level_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_prices

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServicePrice>

=cut

__PACKAGE__->has_many(
  "service_prices",
  "HyperMouse::Schema::Result::ServicePrice",
  { "foreign.service_level_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-07-12 13:30:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zcGFJCB4MgsqNUJQKhOV/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
