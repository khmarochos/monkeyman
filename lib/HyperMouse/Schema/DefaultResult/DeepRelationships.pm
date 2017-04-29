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

        #
        # FROM person TO...
        #

        person_TO_person_FULL => {
            resultset_class => 'Person',
            join => [
                {
                    pipe => [
                        { callout => [ person_TO_contractor_VIA_corporation_INC_DIRECT => { } ] },
                        { callout => [ contractor_TO_person_VIA_provisioning_agreement_ALL_INC_DIRECT => { } ] },
                    ]
                }, {
                    pipe => [
                        { callout => [ person_TO_provisioning_agreement_INC_DIRECT => { } ] },
                        { callout => [ provisioning_agreement_TO_person => { } ] }
                    ]
                }
            ]
        },
 
        person_TO_contractor_VIA_corporation_INC_DIRECT => {
            resultset_class => 'Contractor',
            join => [
                {
                    pipe => [
                        { callout => [ 'person_TO_corporation_DIRECT' => { } ] },
                        { callout => [ 'corporation_TO_contractor_DIRECT' => { } ] },
                    ]
                }, {
                    callout => [ 'person_TO_contractor_DIRECT' => { } ]
                }
            ]
        },

        person_TO_contractor_DIRECT => {
            resultset_class => 'Contractor',
            search => [
                'person_x_contractors' => {
                    permissions => -1,
                    validations => -1,
                    fetch => [ 'contractor' => { validations => -1 } ]
                }
            ]
        },

        person_TO_corporation_FULL => {
            resultset_class => 'Corporation',
            join => [
                {
                    pipe => [
                        { callout => [ 'person_TO_contractor_VIA_corporation_INC_DIRECT' => { } ] },
                        { callout => [ 'contractor_TO_corporation_DIRECT' => { } ] },
                    ]
                }, {
                    pipe => [
                        { callout => [ 'person_TO_provisioning_agreement_INC_DIRECT' => { } ] },
                        { callout => [ 'provisioning_agreement_TO_contractor_ALL' => { } ] },
                        { callout => [ 'contractor_TO_corporation_DIRECT' => { } ] },
                    ]
                }, {
                    callout => [ 'person_TO_corporation_DIRECT' => { } ]
                }
            ]
        },

        person_TO_corporation_VIA_contractor => {
            resultset_class => 'Corporation',
            search => [
                'person_x_corporations' => {
                    permissions => -1,
                    validations => -1,
                    fetch => [ 'corporation' => { validations => -1 } ]
                }
            ]
        },

        person_TO_corporation_DIRECT => {
            resultset_class => 'Corporation',
            search => [
                'person_x_corporations' => {
                    permissions => -1,
                    validations => -1,
                    fetch => [ 'corporation' => { validations => -1 } ]
                }
            ]
        },

        person_TO_provisioning_agreement_INC_DIRECT => {
            resultset_class => 'ProvisioningAgreement',
            join => [
                {
                    pipe => [
                        { callout => [ 'person_TO_contractor_VIA_corporation_INC_DIRECT' => { } ] },
                        { callout => [ 'contractor_TO_provisioning_agreement_ALL' => { } ] },
                    ]
                }, {
                    callout => [ 'person_TO_provisioning_agreement_DIRECT' => { } ]
                }
            ]
        },

        person_TO_provisioning_agreement_DIRECT => {
            resultset_class => 'ProvisioningAgreement',
            search => [
                'person_x_provisioning_agreements' => {
                    validations => -1,
                    permissions => -1,
                    fetch => [ 'provisioning_agreement' => { validations => -1 } ]
                }
            ]
        },

        person_TO_provisioning_obligation => {
            resultset_class => 'ProvisioningObligation',
            pipe => [
                { callout => [ 'person_TO_provisioning_agreement_INC_DIRECT' => { } ] },
                { callout => [ 'provisioning_agreement_TO_provisioning_obligation' => { } ] }
            ]
        },

        person_TO_resource_piece => {
            resultset_class => 'ResourcePiece',
            pipe => [
                { callout => [ 'person_TO_provisioning_obligation' => { } ] },
                { callout => [ 'provisioning_obligation_TO_resource_piece' => { } ] }
            ]
        },

        #
        # FROM contractor TO ...
        #

        contractor_TO_person_VIA_provisioning_agreement_ALL_INC_DIRECT => {
            resultset_class => 'Person',
            join => [
                { callout => [ 'contractor_TO_person_VIA_provisioning_agreement_CLIENT' => { } ] },
                { callout => [ 'contractor_TO_person_VIA_provisioning_agreement_PROVIDER' => { } ] },
                { callout => [ 'contractor_TO_person_DIRECT' => { } ] }
            ]
        },

        contractor_TO_person_VIA_provisioning_agreement_CLIENT => {
            resultset_class => 'Person',
            search => [
                'provisioning_agreement_client_contractors' => {
                    validations => -1,
                    callout => [ 'provisioning_agreement_TO_person' => { } ]
                }
            ]
        },

        contractor_TO_person_VIA_provisioning_agreement_PROVIDER => {
            resultset_class => 'Person',
            search => [
                'provisioning_agreement_provider_contractors' => {
                    validations => -1,
                    callout => [ 'provisioning_agreement_TO_person' => { } ]
                }
            ]
        },

        contractor_TO_person_DIRECT => {
            resultset_class => 'Person',
            search => [
                'person_x_contractors'  => {
                    permissions => -1,
                    validations => -1,
                    fetch => [ 'person' => { validations => -1 } ]
                }
            ]
        },

        contractor_TO_corporation_DIRECT => {
            resultset_class => 'Corporation',
            search => [
                'corporation_x_contractors'  => {
                    validations => -1,
                    fetch => [ 'corporation' => { validations => -1 } ]
                }
            ]
        },

        contractor_TO_provisioning_agreement_ALL => {
            resultset_class => 'ProvisioningAgreement',
            join => [
                { callout => [ 'contractor_TO_provisioning_agreement_CLIENT' => { } ] },
                { callout => [ 'contractor_TO_provisioning_agreement_PROVIDER' => { } ] }
            ]
        },

        contractor_TO_provisioning_agreement_CLIENT => {
            resultset_class => 'ProvisioningAgreement',
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
            ]
        },

        contractor_TO_provisioning_agreement_PROVIDER => {
            resultset_class => 'ProvisioningAgreement',
            search => [
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
        },

        #
        # FROM corporation TO ...
        #

        corporation_TO_contractor_DIRECT => {
            resultset_class => 'Contractor',
            search => [
                'corporation_x_contractors' => {
                    validations => -1,
                    fetch => [ 'contractor' => { validations => -1 } ]
                }
            ]
        },

        #
        # FROM provisioning_agreement TO ...
        #

        provisioning_agreement_TO_person => {
            resultset_class => 'Person',
            search => [
                'person_x_provisioning_agreements' => {
                    validations => -1,
                    permissions => -1,
                    fetch => [ 'person' => { validations => -1 } ]
                }
            ]
        },

        provisioning_agreement_TO_contractor_ALL => {
            resultset_class => 'Contractor',
            join => [
                { callout => [ 'provisioning_agreement_TO_contractor_CLIENT' => { } ] },
                { callout => [ 'provisioning_agreement_TO_contractor_PROVIDER' => { } ] }
            ]
        },

        provisioning_agreement_TO_contractor_CLIENT => {
            resultset_class => 'Contractor',
            fetch => [ 'client_contractor' => { validations => -1 } ]
        },

        provisioning_agreement_TO_contractor_PROVIDER => {
            resultset_class => 'Contractor',
            fetch => [ 'provider_contractor' => { validations => -1 } ]
        },

        provisioning_agreement_TO_provisioning_obligation => {
            resultset_class => 'ProvisioningObligation',
            fetch => [ 'provisioning_obligations' => { validations => -1 } ]
        },

        provisioning_agreement_TO_resource_piece => {
            resultset_class => 'ResourcePiece',
            pipe => [
                { callout => [ 'provisioning_agreement_TO_provisioning_obligation' => { } ] },
                { callout => [ 'provisioning_obligation_TO_resource_piece' => { } ] }
            ],
        },

        #
        # FROM provisioning_obligation TO ...
        #

        provisioning_obligation_TO_resource_piece => {
            resultset_class => 'ResourcePiece',
            search => [
                'provisioning_obligation_x_resource_pieces' => {
                    validations => -1,
                    fetch => [ 'resource_piece' => { validations => -1 } ]
                }
            ]
        }

    }
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
            warn("*** callout: $callout_key ***");
            die("$callout_key") # FIXME: raise a proper exception
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
            warn("*** join: $join_element ***");
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
            warn("*** pipe: $pipe_element ***");
            $resultset = scalar($resultset->search_related_deep(
                %{ $search_parmeters_base },
                %{ $pipe_element },
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
