package HyperMouse::Schema::DefaultResult::DeepRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use Method::Signatures;



# Actually we don't need that anymore
#
# # We perform all the magic after the original register_relationship method
# func register_relationship(...) {
#    my $self = shift;
#    my $result = $self->next::method(@_);
#
#    # TODO: start mapping the relationships automatically after their registration
#
#    return($result);
#}



method search_related_deep(...) {
    $self
        ->self_rs
        ->search_related_deep(@_);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
