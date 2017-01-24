use utf8;
package HyperMouse::Schema::Result::ServiceType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ServiceType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<service_type>

=cut

__PACKAGE__->table("service_type");

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

=head2 service_group_id

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
  "service_group_id",
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

=head2 service_group

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::ServiceGroup>

=cut

__PACKAGE__->belongs_to(
  "service_group",
  "HyperMouse::Schema::Result::ServiceGroup",
  { id => "service_group_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 service_i18ns

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceI18n>

=cut

__PACKAGE__->has_many(
  "service_i18ns",
  "HyperMouse::Schema::Result::ServiceI18n",
  { "foreign.service_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_obligations

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceObligation>

=cut

__PACKAGE__->has_many(
  "service_obligations",
  "HyperMouse::Schema::Result::ServiceObligation",
  { "foreign.service_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_prices

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServicePrice>

=cut

__PACKAGE__->has_many(
  "service_prices",
  "HyperMouse::Schema::Result::ServicePrice",
  { "foreign.service_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-24 14:37:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ComC4k9LBq0a+rf2iAVR2A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
