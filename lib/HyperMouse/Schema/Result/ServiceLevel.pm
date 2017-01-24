use utf8;
package HyperMouse::Schema::Result::ServiceLevel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::ServiceLevel

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
  is_nullable: 0

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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 service_level_names

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceLevelName>

=cut

__PACKAGE__->has_many(
  "service_level_names",
  "HyperMouse::Schema::Result::ServiceLevelName",
  { "foreign.service_level_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 service_obligations

Type: has_many

Related object: L<HyperMouse::Schema::Result::ServiceObligation>

=cut

__PACKAGE__->has_many(
  "service_obligations",
  "HyperMouse::Schema::Result::ServiceObligation",
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-24 12:14:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eSjGyTvwPbtCUZb65VmXKQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
