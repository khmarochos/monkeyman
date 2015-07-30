package MonkeyMan::HyperMouse::Schema::Result::Agreement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::Agreement

=cut

__PACKAGE__->table("agreement");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x3215c18)
  is_auto_increment: 1
  is_nullable: 0
  size: 11

=head2 agreement

  data_type: VARCHAR
  default_value: undef
  is_nullable: 0
  size: 32

=head2 customer_id

  data_type: INT
  default_value: undef
  extra: HASH(0x3214320)
  is_nullable: 0
  size: 10

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
  "agreement",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 32,
  },
  "customer_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 10,
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("agreement", ["agreement"]);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ozN3tSMOm+k6T5iqEYeIqg

__PACKAGE__->belongs_to(
    customer => 'MonkeyMan::HyperMouse::Schema::Result::Customer', 'customer_id'
);
__PACKAGE__->has_many(
    permissions => 'MonkeyMan::HyperMouse::Schema::Result::Permission', 'agreement_id'
);
__PACKAGE__->many_to_many(
    users => 'permissions', 'user'
);
__PACKAGE__->has_many(
    provisions => 'MonkeyMan::HyperMouse::Schema::Result::Provision', 'agreement_id'
);
__PACKAGE__->has_many(
    payments => 'MonkeyMan::HyperMouse::Schema::Result::Payment', 'agreement_id'
);
__PACKAGE__->many_to_many(
    charges => 'provisions', 'charges'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
