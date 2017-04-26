package HyperMouse::Schema::DefaultResult::DeepRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use Method::Signatures;
use Lingua::EN::Inflect::Phrase qw(to_S to_PL);



has search_selated_deep_shortcut => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_search_related_deep_shortcut',
    writer      =>   '_set_search_related_deep_shortcut',
    predicate   =>   '_het_search_related_deep_shortcut',
    builder     => '_build_search_related_deep_shortcut',
    lazy        => 1
);

method _build_search_related_deep_shortcut {
    {
        person_to_person => {
            search => [
                'person_x_corporations' => {
                    permissions => -1,
                    validations => -1,
                    search => [
                        'corporation' => {
                            validations => -1,
                            search => [
                                'person_x_corporations' => {
                                    permissions => -1,
                                    validations => -1,
                                    fetch => { 'person' => { validations => -1 } }
                                },
                                'corporation_x_contractors' => {
                                    validations => -1,
                                    search => [
                                        'contractor' => {
                                            validations => -1,
                                            search => [
                                                'person_x_contractors'  => {
                                                    permissions => -1,
                                                    validations => -1,
                                                    fetch => [ 'person' => { validations => -1 } ]
                                                },
                                                'provisioning_agreement_client_contractors' => {
                                                    validations => -1,
                                                    search => [
                                                        'person_x_provisioning_agreements' => {
                                                            validations => -1,
                                                            permissions => -1,
                                                            fetch => [ 'person' => { validations => -1 } ]
                                                        }
                                                    ]
                                                },
                                                'provisioning_agreement_provider_contractors' => {
                                                    validations => -1,
                                                    search => [
                                                        'person_x_provisioning_agreements' => {
                                                            validations => -1,
                                                            permissions => -1,
                                                            fetch => [ 'person' => { validations => -1 } ]
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                'person_x_contractors' => {
                    permissions => -1,
                    validations => -1,
                    search => [
                        'contractor' => {
                            validations => -1,
                            search => [
                                'person_x_contractors'  => {
                                    permissions => -1,
                                    validations => -1,
                                    fetch => [ 'person' => { validations => -1 } ]
                                },
                                'provisioning_agreement_client_contractors' => {
                                    validations => -1,
                                    search => [
                                        'person_x_provisioning_agreements' => {
                                            validations => -1,
                                            permissions => -1,
                                            fetch => [ 'person' => { validations => -1 } ]
                                        }
                                    ]
                                },
                                'provisioning_agreement_provider_contractors' => {
                                    validations => -1,
                                    search => [
                                        'person_x_provisioning_agreements' => {
                                            validations => -1,
                                            permissions => -1,
                                            fetch => [ 'person' => { validations => -1 } ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                'person_x_provisioning_agreements' => {
                    validations => -1,
                    permissions => -1,
                    fetch => [ 'person' => { validations => -1 } ]
                }
            ]
        },
        person_to_provisioning_agreement => {
            search => [
                'person_x_corporations' => {
                    permissions => -1,
                    validations => -1,
                    search => [
                        'corporation' => {
                            validations => -1,
                            search => [
                                'corporation_x_contractors' => {
                                    validations => -1,
                                    search => [
                                        'contractor' => {
                                            validations => -1,
                                            search => [
                                                'provisioning_agreement_client_contractors' => {
                                                    validations => -1,
                                                    search => [
                                                        'person_x_provisioning_agreements' => {
                                                            validations => -1,
                                                            permissions => -1,
                                                            fetch => [ 'provisioning_agreement' => { validations => -1 } ]
                                                        }
                                                    ]
                                                },
                                                'provisioning_agreement_provider_contractors' => {
                                                    validations => -1,
                                                    search => [
                                                        'person_x_provisioning_agreements' => {
                                                            validations => -1,
                                                            permissions => -1,
                                                            fetch => [ 'provisioning_agreement' => { validations => -1 } ]
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                'person_x_contractors' => {
                    permissions => -1,
                    validations => -1,
                    search => [
                        'contractor' => {
                            validations => -1,
                            search => [
                                'provisioning_agreement_client_contractors' => {
                                    validations => -1,
                                    search => [
                                        'person_x_provisioning_agreements' => {
                                            validations => -1,
                                            permissions => -1,
                                            fetch => [ 'provisioning_agreement' => { validations => -1 } ]
                                        }
                                    ]
                                },
                                'provisioning_agreement_provider_contractors' => {
                                    validations => -1,
                                    search => [
                                        'person_x_provisioning_agreements' => {
                                            validations => -1,
                                            permissions => -1,
                                            fetch => [ 'provisioning_agreement' => { validations => -1 } ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                'person_x_provisioning_agreements' => {
                    validations => -1,
                    permissions => -1,
                    fetch => [ 'provisioning_agreement' => { validations => -1 } ]
                }
            ]
        },
        person_to_provisioning_obligation => {
            callout_pipe => [
                person_to_provisioning_agreement => { },
                provisioning_agreement_to_provisioning_obligation => { }
            ]
        },
        provisioning_agreement_to_person => {
            search => [
                'person_x_provisioning_agreements' => {
                    validations => -1,
                    permissions => -1,
                    fetch => [ 'person' => { validations => -1 } ]
                }
            ]
        },
        provisioning_agreement_to_provisioning_obligation => {
            fetch => [ 'provisioning_obligations' => { validations => -1 } ]
        }
    }
}

method search_related_deep(
    Str         :$resultset_class!,
    ArrayRef    :$callout_pipe?,
    ArrayRef    :$callout_join?,
    Int         :$search_permissions_default?   = 0b000111,
    Int         :$search_validations_default?   = 0b000111,
    ArrayRef    :$search?,
    Int         :$fetch_permissions_default?    = 0b000111,
    Int         :$fetch_validations_default?    = 0b000111,
    ArrayRef    :$fetch?,
    Bool        :$union?                        = 1,
    ...
) {

    my $search_parmeters_base = {
        resultset_class             => $resultset_class,
        search_permissions_default  => $search_permissions_default,
        search_validations_default  => $search_validations_default,
        fetch_permissions_default   => $fetch_permissions_default,
        fetch_validations_default   => $fetch_validations_default
    };

    my @resultsets;

    if(defined($callout_join)) {

        my @callout_join_local = @{ $callout_join };
        while(my($callout_join_key, $callout_join_val) = splice(@callout_join_local, 0, 2)) {
            push(@resultsets, scalar($self->search_related_deep(
                %{ $search_parmeters_base },
                %{ $self->_get_search_related_deep_shortcut->{ $callout_join_key } },
                %{ $callout_join_val }
            )));
        }

    }

    if(defined($callout_pipe)) {

        my $resultset = $self;
        my @callout_pipe_local = @{ $callout_pipe };
        while(my($callout_pipe_key, $callout_pipe_val) = splice(@callout_pipe_local, 0, 2)) {
            $resultset = scalar($resultset->search_related_deep(
                %{ $search_parmeters_base },
                %{ $self->_get_search_related_deep_shortcut->{ $callout_pipe_key } },
                %{ $callout_pipe_val },
                union => 1
            ));
        }
        push(@resultsets, $resultset) if($resultset != $self);

    }

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
method register_relationship(...) {
    my $result = $self->next::method(@_);

    # TODO: start mapping the relationships automatically after their registration

    return($result);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
