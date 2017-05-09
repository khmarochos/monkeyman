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



our $DeepRelationships = {

    #
    # FROM person TO ...
    #

    #  ... person

    'Person>[FULL]>Person' => {
        resultset_class => 'Person',
        join => [
            { callout => [ 'Person>Contractor>Person' => { } ] },
            { callout => [ 'Person>Contractor>[PROVIDER]>ProvisioningAgreement>Person' => { } ] },
            { callout => [ 'Person>Contractor>[CLIENT]>ProvisioningAgreement>Person' => { } ] },
            { callout => [ 'Person>Corporation>Person' => { } ] },
            { callout => [ 'Person>Corporation>Contractor>Person' => { } ] },
            { callout => [ 'Person>Corporation>Contractor>[PROVIDER]>ProvisioningAgreement>Person' => { } ] },
            { callout => [ 'Person>Corporation>Contractor>[CLIENT]>ProvisioningAgreement>Person' => { } ] },
        ]
    },

    'Person>Contractor>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Contractor' => { } ] },
            { callout => [ 'Contractor>Person' => { } ] },
        ]
    },

    'Person>Contractor>[PROVIDER]>ProvisioningAgreement>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Contractor>[PROVIDER]>ProvisioningAgreement' => { } ] },
            { callout => [ 'ProvisioningAgreement>Person' => { } ] },
        ]
    },

    'Person>Contractor>[CLIENT]>ProvisioningAgreement>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Contractor>[CLIENT]>ProvisioningAgreement' => { } ] },
            { callout => [ 'ProvisioningAgreement>Person' => { } ] },
        ]
    },

    'Person>Corporation>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Corporation' => { } ] },
            { callout => [ 'Corporation>Person' => { } ] },
        ]
    },

    'Person>Corporation>Contractor>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Corporation>Contractor' => { } ] },
            { callout => [ 'Contractor>Person' => { } ] },
        ]
    },

    'Person>Corporation>Contractor>[CLIENT]>ProvisioningAgreement>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Corporation>Contractor>[CLIENT]>ProvisioningAgreement' => { } ] },
            { callout => [ 'ProvisioningAgreement>Person' => { } ] },
        ]
    },

    'Person>Corporation>Contractor>[PROVIDER]>ProvisioningAgreement>Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person>Corporation>Contractor>[PROVIDER]>ProvisioningAgreement' => { } ] },
            { callout => [ 'ProvisioningAgreement>Person' => { } ] },
        ]
    },

    #  ... contractor

    'Person>[FULL]>Contractor' => {
        resultset_class => 'Contractor',
        join => [
            { callout => [ 'Person>Corporation>Contractor' => { } ] },
            { callout => [ 'Person>Contractor' => { } ] }
        ]
    },

    'Person>Corporation>Contractor' => {
        resultset_class => 'Contractor',
        pipe => [
            { callout => [ 'Person>Corporation' => { } ] },
            { callout => [ 'Corporation>Contractor' => { } ] },
        ]
    },

    'Person>Contractor' => {
        resultset_class => 'Contractor',
        search => [
            'person_x_contractors' => {
                permissions => -1,
                validations => -1,
                fetch => [ 'contractor' => { validations => -1 } ]
            }
        ]
    },

    #  ... corporation

    'Person>[FULL]>Corporation' => {
        resultset_class => 'Corporation',
        join => [
            {
                pipe => [
                    { callout => [ 'Person>Corporation>Contractor' => { } ] },
                    { callout => [ 'Contractor>Corporation' => { } ] },
                ]
            }, {
                pipe => [
                    { callout => [ 'Person>Corporation>Contractor>[PROVIDER]>ProvisioningAgreement' => { } ] },
                    { callout => [ 'ProvisioningAgreement>Contractor' => { } ] },
                    { callout => [ 'Contractor>Corporation' => { } ] },
                ]
            }, {
                callout => [ 'Person>Corporation' => { } ]
            }
        ]
    },

    'Person>Corporation' => {
        resultset_class => 'Corporation',
        search => [
            'person_x_corporations' => {
                permissions => -1,
                validations => -1,
                fetch => [ 'corporation' => { validations => -1 } ]
            }
        ]
    },

    #  ... provisioning_agreement

    'Person>Corporation>Contractor>[PROVIDER]>ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        pipe => [
            { callout => [ 'Person>Corporation>Contractor' => { } ] },
            { callout => [ 'Contractor>[PROVIDER]>ProvisioningAgreement' => { } ] }
        ]
    },

    'Person>Corporation>Contractor>[CLIENT]>ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        pipe => [
            { callout => [ 'Person>Corporation>Contractor' => { } ] },
            { callout => [ 'Contractor>[CLIENT]>ProvisioningAgreement' => { } ] }
        ]
    },

    'Person>Contractor>[PROVIDER]>ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        pipe => [
            { callout => [ 'Person>Contractor' => { } ] },
            { callout => [ 'Contractor>[PROVIDER]>ProvisioningAgreement' => { } ] }
        ]
    },

    'Person>Contractor>[CLIENT]>ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        pipe => [
            { callout => [ 'Person>Contractor' => { } ] },
            { callout => [ 'Contractor>[CLIENT]>ProvisioningAgreement' => { } ] }
        ]
    },

    'Person>ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        search => [
            'person_x_provisioning_agreements' => {
                validations => -1,
                permissions => -1,
                fetch => [ 'provisioning_agreement' => { validations => -1 } ]
            }
        ]
    },

    #  ... provisioning_obligation

    person_TO_provisioning_obligation => {
        resultset_class => 'ProvisioningObligation',
        pipe => [
            { callout => [ '(Person>Corporation>Contractor+Person>Contractor)>ProvisioningAgreement[ALL]+Person>ProvisioningAgreement' => { } ] },
            { callout => [ 'provisioning_agreement_TO_provisioning_obligation' => { } ] }
        ]
    },

    #  ... resource_piece

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

    #  ... person

    'Contractor>ProvisioningAgreement[ALL]>Person+Contractor>Person' => {
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

    'Contractor>Person' => {
        resultset_class => 'Person',
        search => [
            'person_x_contractors'  => {
                permissions => -1,
                validations => -1,
                fetch => [ 'person' => { validations => -1 } ]
            }
        ]
    },

    #  ... corporation

    contractor_TO_corporation_DIRECT => {
        resultset_class => 'Corporation',
        search => [
            'corporation_x_contractors'  => {
                validations => -1,
                fetch => [ 'corporation' => { validations => -1 } ]
            }
        ]
    },

    #  ... provisioning_agreement

    'Contractor>ProvisioningAgreement[ALL]' => {
        resultset_class => 'ProvisioningAgreement',
        join => [
            { callout => [ 'contractor_TO_provisioning_agreement_CLIENT' => { } ] },
            { callout => [ 'contractor_TO_provisioning_agreement_PROVIDER' => { } ] }
        ]
    },

    'Contractor>[CLIENT]>ProvisioningAgreement' => {
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

    'Contractor>[PROVIDER]>ProvisioningAgreement' => {
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
            },
        ]
    },

    #
    # FROM corporation TO ...
    #

    #  ... contractor

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

    #  ... person

    'ProvisioningAgreement>Person' => {
        resultset_class => 'Person',
        search => [
            'person_x_provisioning_agreements' => {
                validations => -1,
                permissions => -1,
                fetch => [ 'person' => { validations => -1 } ]
            }
        ]
    },

    #  ... contractor

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

    #  ... provisioning_obligation

    provisioning_agreement_TO_provisioning_obligation => {
        resultset_class => 'ProvisioningObligation',
        fetch => [ 'provisioning_obligations' => { validations => -1 } ]
    },

    #  ... resource_piece

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

    #  ... resource_piece

    provisioning_obligation_TO_resource_piece => {
        resultset_class => 'ResourcePiece',
        search => [
            'provisioning_obligation_x_resource_pieces' => {
                validations => -1,
                fetch => [ 'resource_piece' => { validations => -1 } ]
            }
        ]
    }

};



__PACKAGE__->load_namespaces(
    default_resultset_class => 'DefaultResultSet'
);



has 'hypermouse' => (
    is          => 'rw',
    isa         => 'HyperMouse',
    reader      => 'get_hypermouse',
    writer      => 'set_hypermouse',
    predicate   => 'has_hypermouse',
    lazy        => 0,
    required    => 1
);



# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
