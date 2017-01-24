use utf8;
package HyperMouse::Schema::Result::PartnerAgreement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::PartnerAgreement

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<partner_agreement>

=cut

__PACKAGE__->table("partner_agreement");

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
  size: 32

=head2 provider_contractor_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 client_contractor_id

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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "provider_contractor_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "client_contractor_id",
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

=head2 client_contractor

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Contractor>

=cut

__PACKAGE__->belongs_to(
  "client_contractor",
  "HyperMouse::Schema::Result::Contractor",
  { id => "client_contractor_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 partner_obligations

Type: has_many

Related object: L<HyperMouse::Schema::Result::PartnerObligation>

=cut

__PACKAGE__->has_many(
  "partner_obligations",
  "HyperMouse::Schema::Result::PartnerObligation",
  { "foreign.partner_agreement_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_x_partner_agreements

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonXPartnerAgreement>

=cut

__PACKAGE__->has_many(
  "person_x_partner_agreements",
  "HyperMouse::Schema::Result::PersonXPartnerAgreement",
  { "foreign.partner_agreement_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 provider_contractor

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Contractor>

=cut

__PACKAGE__->belongs_to(
  "provider_contractor",
  "HyperMouse::Schema::Result::Contractor",
  { id => "provider_contractor_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-24 12:14:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DA6BNCR1CNOfISazBc+a9A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
