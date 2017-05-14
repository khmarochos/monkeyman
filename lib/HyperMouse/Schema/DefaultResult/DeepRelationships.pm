package HyperMouse::Schema::DefaultResult::DeepRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use HyperMouse::Exception qw(PatternAbsent);

use Method::Signatures;
use Lingua::EN::Inflect::Phrase qw(to_S to_PL);



has search_related_deep_shortcut => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_search_related_deep_shortcut',
    writer      =>   '_set_search_related_deep_shortcut',
    predicate   =>   '_has_search_related_deep_shortcut',
    builder     => '_build_search_related_deep_shortcut',
    lazy        => 1
);

method _build_search_related_deep_shortcut {
    return($HyperMouse::Schema::DeepRelationships);
}

method search_related_deep(
    Str         :$resultset_class!,
    ArrayRef    :$callout?,
    ArrayRef    :$pipe?,
    ArrayRef    :$join?,
    Int         :$search_permissions_default?   = 0b000111,
    Int         :$search_validations_default?   = 0b000111,
    ArrayRef    :$search?,
    Int         :$fetch_permissions_default?    = 0b000111,
    Int         :$fetch_validations_default?    = 0b000111,
    ArrayRef    :$fetch?,
    Bool        :$union?                        = 1,
    Maybe[Int]  :$permissions, # ...isn't being used at all
    Maybe[Int]  :$validations  # ..........................
) {

    my $logger = $self->get_logger;
    $logger->tracef(
        "Searching the %s records related to %s (%s)",
        $resultset_class, $self, { (@_) }
    );

    my $search_parmeters_base = {
        resultset_class             => $resultset_class,
        search_permissions_default  => $search_permissions_default,
        search_validations_default  => $search_validations_default,
        fetch_permissions_default   => $fetch_permissions_default,
        fetch_validations_default   => $fetch_validations_default
    };

    my @resultsets;

    if(defined($callout)) {

        my @callout_local = @{ $callout };
        while(my($callout_key, $callout_val) = splice(@callout_local, 0, 2)) {

            $logger->tracef("Calling out the %s search pattern", $callout_key);

            (__PACKAGE__ . '::Exception::PatternAbsent')->throwf(
                "Can't call out the %s search pattern",
                "$callout_key"
            )
                unless(defined($self->_get_search_related_deep_shortcut->{ $callout_key }));

            push(@resultsets, scalar($self->search_related_deep(
                %{ $search_parmeters_base },
                %{ $self->_get_search_related_deep_shortcut->{ $callout_key } },
                %{ $callout_val }
            )));

        }

    }

    if(defined($join)) {

        foreach my $join_element (@{ $join }) {
            my $resultset = scalar($self->search_related_deep(
                %{ $search_parmeters_base },
                %{ $join_element },
                union => 1
            ));
            push(@resultsets, $resultset);
        }

    }

    if(defined($pipe)) {

        my $resultset = $self;
        foreach my $pipe_element (@{ $pipe }) {
            $resultset = scalar($resultset->search_related_deep(
                %{ $search_parmeters_base },
                %{ $pipe_element },
                union => 1
            ));
        }
        push(@resultsets, $resultset) if($resultset != $self);

    }



    # TODO: Join the following 2 blocks into a single foreach(qw/fetch search/) one

    if(defined($fetch)) {

        my $resultset = $self;
        
        my @fetch_local = @{ $fetch };
        while(my($fetch_key, $fetch_val) = splice(@fetch_local, 0, 2)) {
       
            my $resultset = $self->search_related_rs($fetch_key);

            my $fetch_permissions = $fetch_val->{'permissions'};
            my $fetch_validations = $fetch_val->{'validations'};

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

        my @search_local = @{ $search };
        while(my($search_key, $search_val) = splice(@search_local, 0, 2)) {
        
            my $resultset = $self->search_related($search_key);

            my $search_permissions = $search_val->{'permissions'};
            my $search_validations = $search_val->{'validations'};

            $resultset = $resultset->filter_validated(
                mask => $search_validations >= 0
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

            foreach my $result ($resultset->all) {
                my $resultset = $result->search_related_deep(
                    %{ $search_parmeters_base },
                    %{ $search_val }
                );
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

# We perform all the magic after the original register_relationship method
func register_relationship(...) {
    my $self = shift;
    my $result = $self->next::method(@_);

    # TODO: start mapping the relationships automatically after their registration

    return($result);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
