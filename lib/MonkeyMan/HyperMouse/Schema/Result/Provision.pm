package MonkeyMan::HyperMouse::Schema::Result::Provision;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::Provision

=cut

__PACKAGE__->table("provision");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x3226f20)
  is_auto_increment: 1
  is_nullable: 0
  size: 11

=head2 agreement_id

  data_type: INT
  default_value: undef
  extra: HASH(0x3227610)
  is_nullable: 0
  size: 11

=head2 service_id

  data_type: INT
  default_value: undef
  extra: HASH(0x3226460)
  is_nullable: 0
  size: 11

=head2 pricelist_id

  data_type: INT
  default_value: undef
  extra: HASH(0x32256b0)
  is_nullable: 0
  size: 11

=head2 activated_at

  data_type: TIMESTAMP
  default_value: undef
  is_nullable: 1
  size: 14

=head2 deactivated_at

  data_type: TIMESTAMP
  default_value: undef
  is_nullable: 1
  size: 14

=head2 expires_at

  data_type: TIMESTAMP
  default_value: undef
  is_nullable: 1
  size: 14

=head2 quantity

  data_type: INT
  default_value: undef
  extra: HASH(0x3226c20)
  is_nullable: 0
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
    size => 11,
  },
  "agreement_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 11,
  },
  "service_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 11,
  },
  "pricelist_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 11,
  },
  "activated_at",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => 14,
  },
  "deactivated_at",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => 14,
  },
  "expires_at",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => 14,
  },
  "quantity",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 10,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lq7zhSDjPxFCtld4jZH14Q

__PACKAGE__->belongs_to(
    agreement => 'MonkeyMan::HyperMouse::Schema::Result::Agreement', 'agreement_id'
);
__PACKAGE__->belongs_to(
    pricelist => 'MonkeyMan::HyperMouse::Schema::Result::Pricelist', 'pricelist_id'
);
__PACKAGE__->belongs_to(
    service => 'MonkeyMan::HyperMouse::Schema::Result::Service', 'service_id'
);
__PACKAGE__->has_many(
    cloudstack_elements => 'MonkeyMan::HyperMouse::Schema::Result::CloudstackElement', sub {
        my $args = shift;
        {
            "$args->{'foreign_alias'}.hm_element_id"    => { '-ident', "$args->{'self_alias'}.id" },
            "$args->{'foreign_alias'}.hm_element_type"  => { '=', 'provision' }
        };
    }
);
__PACKAGE__->has_many(
    charges => 'MonkeyMan::HyperMouse::Schema::Result::Charge', 'provision_id'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
