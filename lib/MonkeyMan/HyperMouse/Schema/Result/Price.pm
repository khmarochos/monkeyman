package MonkeyMan::HyperMouse::Schema::Result::Price;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::Price

=cut

__PACKAGE__->table("price");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x321cf68)
  is_auto_increment: 1
  is_nullable: 0
  size: 10

=head2 service_id

  data_type: INT
  default_value: undef
  extra: HASH(0x32269f8)
  is_nullable: 0
  size: 11

=head2 pricelist_id

  data_type: INT
  default_value: undef
  extra: HASH(0x3209578)
  is_nullable: 0
  size: 11

=head2 price

  data_type: FLOAT
  default_value: undef
  is_nullable: 0
  size: 32

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
  "price",
  { data_type => "FLOAT", default_value => undef, is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aZU/ecRMwJT2bWdmNlVbCQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
