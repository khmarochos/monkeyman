use utf8;
package HyperMouse::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-11 13:49:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UB8B/zvbNA6ST/vxTo012A

__PACKAGE__->load_namespaces(
    default_resultset_class => 'DefaultResultSet'
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
