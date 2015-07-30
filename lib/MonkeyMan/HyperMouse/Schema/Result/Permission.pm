package MonkeyMan::HyperMouse::Schema::Result::Permission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::Permission

=cut

__PACKAGE__->table("permission");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x321cba8)
  is_auto_increment: 1
  is_nullable: 0
  size: 10

=head2 user_id

  data_type: INT
  default_value: undef
  extra: HASH(0x32267a0)
  is_nullable: 0
  size: 11

=head2 agreement_id

  data_type: INT
  default_value: undef
  extra: HASH(0x32210d8)
  is_nullable: 0
  size: 11

=head2 granted_at

  data_type: TIMESTAMP
  default_value: CURRENT_TIMESTAMP
  is_nullable: 0
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
    size => 10,
  },
  "user_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
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
  "granted_at",
  {
    data_type => "TIMESTAMP",
    default_value => \"CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X27zS6beGhidu+hW6oL/6A

MonkeyMan::HyperMouse::Schema::Result::Permission->belongs_to(
    agreement => 'MonkeyMan::HyperMouse::Schema::Result::Agreement', 'agreement_id'
);
MonkeyMan::HyperMouse::Schema::Result::Permission->belongs_to(
    user => 'MonkeyMan::HyperMouse::Schema::Result::User', 'user_id'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
