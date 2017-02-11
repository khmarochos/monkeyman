use utf8;
package HyperMouse::Schema::Result::ServiceObligation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ServiceObligation

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

=head1 TABLE: C<service_obligation>

=cut

__PACKAGE__->table("service_obligation");

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

=head2 service_agreement_id

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
  "service_agreement_id",
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

=head2 partner_obligations

Type: has_many

Related object: L<HyperMouse::Schema::Result::PartnerObligation>

=cut

__PACKAGE__->has_many(
  "partner_obligations",
  "HyperMouse::Schema::Result::PartnerObligation",
  { "foreign.service_obligation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_agreement

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ServiceAgreement>

=cut

__PACKAGE__->belongs_to(
  "service_agreement",
  "HyperMouse::Schema::Result::ServiceAgreement",
  { id => "service_agreement_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
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

=head2 service_obligation_x_resource_pieces

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceObligationXResourcePiece>

=cut

__PACKAGE__->has_many(
  "service_obligation_x_resource_pieces",
  "HyperMouse::Schema::Result::ServiceObligationXResourcePiece",
  { "foreign.service_obligation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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
  { "foreign.service_obligation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-11 15:06:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sKbTLul/Go55ZoBbZXG57w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
