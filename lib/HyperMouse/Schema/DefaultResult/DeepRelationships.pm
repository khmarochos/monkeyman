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
    Str     :$resultset_class!,
    Int     :$search_permissions_default?   = 0b000111,
    Int     :$search_validations_default?   = 0b000111,
    HashRef :$search?,
    Int     :$fetch_permissions_default?    = 0b000111,
    Int     :$fetch_validations_default?    = 0b000111,
    HashRef :$fetch?,
    Bool    :$union?                        = 1,
    ...
) {

    my @resultsets;

    if(defined($fetch)) {

        my $resultset = $self;
        
        foreach my $fetch_key (keys(%{ $fetch })) {
        
            my $resultset = $self->search_related_rs($fetch_key);

            my $fetch_permissions = $fetch->{ $fetch_key }->{'permissions'};
            my $fetch_validations = $fetch->{ $fetch_key }->{'validations'};

            $resultset = $resultset->filter_validated(
                mask => $fetch_validations >= 0
                      ? $fetch_validations
                      : $fetch_validations_default
            )
                if(defined($fetch_validations));

            $resultset = $resultset->filter_permitted(
                mask => $fetch_permissions >= 0
                      ? $fetch_permissions
                      : $fetch_permissions_default
            )
                if(defined($fetch_permissions));

            push(@resultsets, scalar($resultset));

        }

    }

    if(defined($search)) {

        foreach my $search_key (keys(%{ $search })) {
        
            my $resultset = $self->search_related($search_key);

            my $search_permissions = $search->{ $search_key }->{'permissions'};
            my $search_validations = $search->{ $search_key }->{'validations'};

            $resultset = $resultset->filter_validated(
                mask => defined($search_validations) && $search_validations >= 0
                      ? $search_validations
                      : $search_validations_default
            )
                if(defined($search_validations));

            $resultset = $resultset->filter_permitted(
                mask => $search_permissions >= 0
                      ? $search_permissions
                      : $search_permissions_default
                )
                if(defined($search_permissions));

            my %search_parameters = %{ $search->{ $search_key } };
            $search_parameters{'resultset_class'}            = $resultset_class;
            $search_parameters{'fetch_permissions_default'}  = $fetch_permissions_default;
            $search_parameters{'fetch_validations_default'}  = $fetch_validations_default;
            $search_parameters{'search_permissions_default'} = $search_permissions_default;
            $search_parameters{'search_validations_default'} = $search_validations_default;
            foreach my $result ($resultset->all) {
                my $resultset = $result->search_related_deep(%search_parameters);
                push(@resultsets, scalar($resultset)) if($resultset->all > 0);
            }

        }

    }

    push(@resultsets, scalar($self->result_source->schema->resultset($resultset_class)->search({ id => undef })))
        unless(@resultsets);


    if($union) {
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
