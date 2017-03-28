use utf8;
package HyperMouse::Schema::Result::ProvisioningObligation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ProvisioningObligation

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

=head1 TABLE: C<provisioning_obligation>

=cut

__PACKAGE__->table("provisioning_obligation");

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

=head2 provisioning_agreement_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 service_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 service_level_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 quantity

  data_type: 'integer'
  extra: {unsigned => 1}
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
  "provisioning_agreement_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "service_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "service_level_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "quantity",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 partnership_obligations

Type: has_many

Related object: L<HyperMouse::Schema::Result::PartnershipObligation>

=cut

__PACKAGE__->has_many(
  "partnership_obligations",
  "HyperMouse::Schema::Result::PartnershipObligation",
  { "foreign.provisioning_obligation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 provisioning_agreement

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ProvisioningAgreement>

=cut

__PACKAGE__->belongs_to(
  "provisioning_agreement",
  "HyperMouse::Schema::Result::ProvisioningAgreement",
  { id => "provisioning_agreement_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 provisioning_obligation_x_resource_pieces

Type: has_many

Related object: L<HyperMouse::Schema::Result::ProvisioningObligationXResourcePiece>

=cut

__PACKAGE__->has_many(
  "provisioning_obligation_x_resource_pieces",
  "HyperMouse::Schema::Result::ProvisioningObligationXResourcePiece",
  { "foreign.provisioning_obligation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_level

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ServiceLevel>

=cut

__PACKAGE__->belongs_to(
  "service_level",
  "HyperMouse::Schema::Result::ServiceLevel",
  { id => "service_level_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 service_type

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ServiceType>

=cut

__PACKAGE__->belongs_to(
  "service_type",
  "HyperMouse::Schema::Result::ServiceType",
  { id => "service_type_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 writeoffs

Type: has_many

Related object: L<HyperMouse::Schema::Result::Writeoff>

=cut

__PACKAGE__->has_many(
  "writeoffs",
  "HyperMouse::Schema::Result::Writeoff",
  { "foreign.provisioning_obligation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-28 01:07:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mPEr/QqqJG+WtN4Y1vHjuQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
