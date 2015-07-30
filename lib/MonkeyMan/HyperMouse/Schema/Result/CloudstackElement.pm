package MonkeyMan::HyperMouse::Schema::Result::CloudstackElement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::CloudstackElement

=cut

__PACKAGE__->table("cloudstack_element");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x3210b30)
  is_auto_increment: 1
  is_nullable: 0
  size: 10

=head2 hm_element_type

  data_type: SET
  default_value: undef
  extra: HASH(0x3210bc0)
  is_nullable: 0
  size: 9

=head2 hm_element_id

  data_type: INT
  default_value: undef
  extra: HASH(0x321c980)
  is_nullable: 0
  size: 10

=head2 cs_element_type

  data_type: SET
  default_value: undef
  extra: HASH(0x3083fa0)
  is_nullable: 0
  size: 14

=head2 cs_element_id

  data_type: VARCHAR
  default_value: undef
  is_nullable: 0
  size: 40

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
  "hm_element_type",
  {
    data_type => "SET",
    default_value => undef,
    extra => { list => ["provision"] },
    is_nullable => 0,
    size => 9,
  },
  "hm_element_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 10,
  },
  "cs_element_type",
  {
    data_type => "SET",
    default_value => undef,
    extra => { list => ["virtualmachine"] },
    is_nullable => 0,
    size => 14,
  },
  "cs_element_id",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vPZvUW0D/nLdx5nGxFfKmg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
