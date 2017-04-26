package HyperMouse::Schema::DefaultResult::DeepRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use Method::Signatures;
use Lingua::EN::Inflect::Phrase qw(to_S to_PL);



# We perform all the magic after the original register_relationship method
method register_relationship(...) {
    my $result = $self->next::method(@_);

    # TODO: start mapping the relationships automatically after their registration

    return($result);
}

method search_related_deep(
    Int     :$_permissions_default? = 0b000111,
    Int     :$_validations_default? = 0b000111,
    Str     :$_fetch?,
    Int     :$_fetch_union?         = 1,
    Int     :$_fetch_permissions?,
    Int     :$_fetch_validations?,
    HashRef :$_fetch_validations_failed?,
    HashRef :$_search?,
    Int     :$_search_permissions?,
    Int     :$_search_validations?,
    HashRef :$_search_validations_failed?,
) {

    my @resultsets;

    if(defined($_fetch)) {

        my $resultset = $self;
        
        $resultset = $resultset->search_related($_fetch);

        $resultset = $resultset->filter_validated(
            mask => $_fetch_validations >= 0
                  ? $_fetch_validations
                  : $_validations_default,
            defined($_fetch_validations_failed)
                  ? (checks_failed => $_fetch_validations_failed)
                  : ( )
        )
            if(defined($_fetch_validations));

        $resultset = $resultset->filter_permitted(
            mask => $_fetch_permissions >= 0
                  ? $_fetch_permissions
                  : $_permissions_default
        )
            if(defined($_fetch_permissions));

        push(@resultsets, $resultset);

    }

    if(defined($_search)) {

        foreach my $search_key (keys(%{ $_search })) {
        
            my $resultset = $self->search_related($search_key);

            my $search_permissions          = $_search->{ $search_key }->{'_search_permissions'};
            my $search_validations          = $_search->{ $search_key }->{'_search_validations'};
            my $search_validations_failed   = $_search->{ $search_key }->{'_search_validations'};

            $resultset = $resultset->filter_validated(
                mask => defined($search_validations) && $search_validations >= 0
                      ? $search_validations
                      : $_validations_default,
                defined($search_validations_failed) && ref($search_validations_failed) eq 'HASH'
                      ? (checks_failed => $search_validations_failed)
                      : ( )
            )
                if(defined($search_validations));

            $resultset = $resultset->filter_permitted(
                mask => $search_permissions >= 0
                      ? $search_permissions
                      : $_permissions_default
                )
                if(defined($search_permissions));

            foreach my $result ($resultset->all) {
                my $resultset = $result->search_related_deep(%{ $_search->{ $search_key } });
                push(@resultsets, $resultset) if($resultset->all > 0);
            }

        }

    }

    if($_fetch_union) {
        my $resultset = shift(@resultsets);
        return(
            defined($resultset)
                ? $resultset->union([ @resultsets ])
                : $resultset
        )
    } else {
        return(@resultsets);
    }

}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
