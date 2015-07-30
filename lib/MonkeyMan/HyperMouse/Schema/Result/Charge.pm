package MonkeyMan::HyperMouse::Schema::Result::Charge;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

MonkeyMan::HyperMouse::Schema::Result::Charge

=cut

__PACKAGE__->table("charge");

=head1 ACCESSORS

=head2 id

  data_type: INT
  default_value: undef
  extra: HASH(0x321c9e0)
  is_auto_increment: 1
  is_nullable: 0
  size: 10

=head2 provision_id

  data_type: INT
  default_value: undef
  extra: HASH(0x321c740)
  is_nullable: 0
  size: 10

=head2 charged_at

  data_type: TIMESTAMP
  default_value: CURRENT_TIMESTAMP
  is_nullable: 0
  size: 14

=head2 sum

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
  "provision_id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => 10,
  },
  "charged_at",
  {
    data_type => "TIMESTAMP",
    default_value => \"CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "sum",
  { data_type => "FLOAT", default_value => undef, is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2014-09-19 12:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hqU+GR71XbqkQlGvKZ91Fw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
