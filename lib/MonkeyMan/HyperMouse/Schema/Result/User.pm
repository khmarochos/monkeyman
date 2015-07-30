package MonkeyMan::HyperMouse::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::User

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x322cbe0)
  is_auto_increment: 1
  is_nullable: 0
  size: 10

=head2 email

  data_type: VARCHAR
  default_value: undef
  is_nullable: 0
  size: 128

=head2 password

  data_type: VARCHAR
  default_value: undef
  is_nullable: 0
  size: 41

=head2 fullname

  data_type: VARCHAR
  default_value: undef
  is_nullable: 1
  size: 128

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
  "email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 128,
  },
  "password",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 41,
  },
  "fullname",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("email", ["email"]);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ElWPm68PM8gv9RgfqoEDDw

__PACKAGE__->has_many(
    permissions => 'MonkeyMan::HyperMouse::Schema::Result::Permission', 'user_id'
);
__PACKAGE__->many_to_many(
    agreements => 'permissions', 'agreement'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
