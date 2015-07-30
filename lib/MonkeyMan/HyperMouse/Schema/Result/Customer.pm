package MonkeyMan::HyperMouse::Schema::Result::Customer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::Customer

=cut

__PACKAGE__->table("customer");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x3211430)
  is_auto_increment: 1
  is_nullable: 0
  size: 11

=head2 name

  data_type: VARCHAR
  default_value: undef
  is_nullable: 0
  size: 256

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
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 256,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gKFhMseelnjEF+OmwgLvwg

MonkeyMan::HyperMouse::Schema::Result::Customer->has_many(
    agreements => 'MonkeyMan::HyperMouse::Schema::Result::Agreement', 'customer_id'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
