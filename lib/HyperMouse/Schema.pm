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

use Parse::RecDescent;



our $DeepRelationships = {

    #
    # FROM person TO ...
    #

    #  ... person

    'Person-[everything]>-Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout         => [ 'Person->-((((@->-Corporation->-Contractor)-&-(@->-Contractor))-[client|provider]>-ProvisioningAgreement)-&-(@->-ProvisioningAgreement))' => { } ] },
            { callout         => [ 'ProvisioningAgreement->-((@-[client|provider]>-Contractor->-((@->Corporation->-Person)-&-(@->-Person)))-&-(@->-Person))' => { } ] }
        ]
    },

    'Person->-((@->-Corporation->-Person)-&-((@->-Corporation->-Contractor)-&-(@->-Contractor))->-Person)' => {
        resultset_class => 'Person',
        join => [
            { callout => [ 'Person->-Corporation->-Person' => { } ] },
            {
                pipe => [
                    { callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ] },
                    { callout => [ 'Contractor->-Person' => { } ] }
                ]
            }
        ]
    },

    'Person->-Corporation->-Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person->-Corporation' => { } ] },
            { callout => [ 'Corporation->-Person' => { } ] },
        ]
    },

    'Person->-Contractor->-Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Person->-Contractor' => { } ] },
            { callout => [ 'Contractor->-Person' => { } ] },
        ]
    },

    #  ... contractor

    'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => {
        resultset_class => 'Contractor',
        join => [
            { callout => [ 'Person->-Corporation->-Contractor' => { } ] },
            { callout => [ 'Person->-Contractor' => { } ] }
        ]
    },

    'Person->-Corporation->-Contractor' => {
        resultset_class => 'Contractor',
        pipe => [
            { callout => [ 'Person->-Corporation' => { } ] },
            { callout => [ 'Corporation->-Contractor' => { } ] },
        ]
    },

    'Person->-Contractor' => {
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

    'Person->-Corporation' => {
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

    'Person->-((((@->-Corporation->-Contractor)-&-(@->-Contractor))-[client]>-ProvisioningAgreement)-&-(@->-ProvisioningAgreement))' => {
        resultset_class => 'ProvisioningAgreement',
        join => [
            {
                pipe => [
                    { callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ] },
                    { callout => [ 'Contractor-[client]>-ProvisioningAgreement' => { } ] }
                ]
            },
            { callout => [ 'Person->-ProvisioningAgreement' => { } ] }
        ]
    },

    'Person->-((((@->-Corporation->-Contractor)-&-(@->-Contractor))-[provider]>-ProvisioningAgreement)-&-(@->-ProvisioningAgreement))' => {
        resultset_class => 'ProvisioningAgreement',
        join => [
            {
                pipe => [
                    { callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ] },
                    { callout => [ 'Contractor-[provider]>-ProvisioningAgreement' => { } ] }
                ]
            },
            { callout => [ 'Person->-ProvisioningAgreement' => { } ] }
        ]
    },

    'Person->-((((@->-Corporation->-Contractor)-&-(@->-Contractor))-[client|provider]>-ProvisioningAgreement)-&-(@->-ProvisioningAgreement))' => {
        resultset_class => 'ProvisioningAgreement',
        join => [
            {
                pipe => [
                    { callout => [ 'Person->-((@->-Corporation->-Contractor)-&-(@->-Contractor))' => { } ] },
                    { callout => [ 'Contractor-[client|provider]>-ProvisioningAgreement' => { } ] }
                ]
            },
            { callout => [ 'Person->-ProvisioningAgreement' => { } ] }
        ]
    },

    'Person->-ProvisioningAgreement' => {
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

    'Contractor->-Corporation->-Person' => {
        resultset_class => 'Person',
        pipe => [
            { callout => [ 'Contractor->-Corporation' => { } ] },
            { callout => [ 'Corporation->-Person' => { } ] },
        ]
    },

    'Contractor->-Person' => {
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

    'Contractor->-Corporation' => {
        resultset_class => 'Corporation',
        search => [
            'corporation_x_contractors'  => {
                validations => -1,
                fetch => [ 'corporation' => { validations => -1 } ]
            }
        ]
    },

    #  ... provisioning_agreement

    'Contractor-[client]>-ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        fetch => [ 'provisioning_agreement_client_contractors' => { validations => -1 } ]
    },

    'Contractor-[provider]>-ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        fetch => [ 'provisioning_agreement_provider_contractors' => { validations => -1 } ]
    },

    'Contractor-[client|provider]>-ProvisioningAgreement' => {
        resultset_class => 'ProvisioningAgreement',
        join => [
            { callout => [ 'Contractor-[client]>-ProvisioningAgreement' => { } ] },
            { callout => [ 'Contractor-[provider]>-ProvisioningAgreement' => { } ] }
        ]
    },

    #
    # FROM corporation TO ...
    #

    #  ... person

    'Corporation->-Person' => {
        resultset_class => 'Person',
        search => [
            'person_x_corporations' => {
                validations => -1,
                permissions => -1,
                fetch => [ 'person' => { validations => '-1' } ]
            }
        ]
    },

    #  ... contractor

    'Corporation->-Contractor' => {
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

    'ProvisioningAgreement->-((@-[client]>-Contractor->-((@->Corporation->-Person)-&-(@->-Person)))-&-(@->-Person))' => {
        resultset_class => 'Person',
        join => [
            {
                pipe => [
                    { callout => [ 'ProvisioningAgreement-[client]>-Contractor' => { } ] },
                    {
                        join => [
                            { callout => [ 'Contractor->-Corporation->-Person' => { } ] },
                            { callout => [ 'Contractor->-Person' => { } ] }
                        ]
                    }
                ]
            },
            { callout => [ 'ProvisioningAgreement->-Person' => { } ] },
        ]
    },

    'ProvisioningAgreement->-((@-[provider]>-Contractor->-((@->Corporation->-Person)-&-(@->-Person)))-&-(@->-Person))' => {
        resultset_class => 'Person',
        join => [
            {
                pipe => [
                    { callout => [ 'ProvisioningAgreement-[provider]>-Contractor' => { } ] },
                    {
                        join => [
                            { callout => [ 'Contractor->-Corporation->-Person' => { } ] },
                            { callout => [ 'Contractor->-Person' => { } ] }
                        ]
                    }
                ]
            },
            { callout => [ 'ProvisioningAgreement->-Person' => { } ] },
        ]
    },

    'ProvisioningAgreement->-((@-[client|provider]>-Contractor->-((@->Corporation->-Person)-&-(@->-Person)))-&-(@->-Person))' => {
        resultset_class => 'Person',
        join => [
            {
                pipe => [
                    { callout => [ 'ProvisioningAgreement-[client|provider]>-Contractor' => { } ] },
                    {
                        join => [
                            { callout => [ 'Contractor->-Corporation->-Person' => { } ] },
                            { callout => [ 'Contractor->-Person' => { } ] }
                        ]
                    }
                ]
            },
            { callout => [ 'ProvisioningAgreement->-Person' => { } ] },
        ]
    },

    'ProvisioningAgreement->-Person' => {
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

    'ProvisioningAgreement-[client]>-Contractor' => {
        resultset_class => 'Contractor',
        fetch => [ 'client_contractor' => { validations => -1 } ]
    },

    'ProvisioningAgreement-[provider]>-Contractor' => {
        resultset_class => 'Contractor',
        fetch => [ 'provider_contractor' => { validations => -1 } ]
    },

    'ProvisioningAgreement-[client|provider]>-Contractor' => {
        resultset_class => 'Contractor',
        join => [
            { callout => [ 'ProvisioningAgreement-[client]>-Contractor' => { } ] },
            { callout => [ 'ProvisioningAgreement-[provider]>-Contractor' => { } ] }
        ]
    },

    #  ... provisioning_obligation

    'ProvisioningAgreement->-ProvisioningObligation' => {
        resultset_class => 'ProvisioningObligation',
        fetch => [ 'provisioning_obligations' => { validations => -1 } ]
    },

    #  ... resource_piece

    'ProvisioningAgreement->-ProvisioningObligation->-ResourcePiece' => {
        resultset_class => 'ResourcePiece',
        pipe => [
            { callout => [ 'ProvisioningAgreement->-ProvisioningObligation' => { } ] },
            { callout => [ 'ProvisioningObligation->-ResourcePiece' => { } ] }
        ],
    },

    #
    # FROM provisioning_obligation TO ...
    #

    #  ... resource_piece

    'ProvisioningObligation->-ResourcePiece' => {
        resultset_class => 'ResourcePiece',
        search => [
            'provisioning_obligation_x_resource_pieces' => {
                validations => -1,
                fetch => [ 'resource_piece' => { validations => -1 } ]
            }
        ]
    }

};


our $DeepRelationshipsGrammarParser = Parse::RecDescent->new(<<'__END_OF_GRAMMAR__');

    {
        use strict;
        use warnings;

        my @src_class = (undef);
        my @dst_class = (undef);
    }

    parse:                  operation end
        {
            $return = $item[1];
        }

    operation:              operand ( operation_join | operation_pipe )(s?)
        {
            my $i = 0;
            my $r = $item[1];
            while(1) {
                last unless(defined($item[2][$i]));
                $r = scalar(keys(%{ $r }))
                    ? { $item[2][$i]->{'operator'} => [ $r, $item[2][$i]->{'operand'} ] }
                    : { $item[2][$i]->{'operator'} => [     $item[2][$i]->{'operand'} ] };
                $i++;
            }
            $r->{'resultset_class'} = $dst_class[-1];
            $return                 = $r;
        }

    operation_join:         '-&-' operand
        {
            $return = {
                operand     => $item[2],
                operator    => 'join'
            };
        }

    operation_pipe:         /-(\[.+\])*>-/ operand
        {
            $return = {
                operand     => $item[2],
                operator    => 'pipe'
            };
        }

    operand:                group | element_class

    group:                  group_begin operation group_end
        {
            $return = $item[2];
        }

    group_begin:            '('
        {
            push(@src_class, $dst_class[-1]);
        }

    group_end:              ')'
        {
            pop(@src_class);
        }

    element_class:          element_class_given | element_class_exact
        {
            #$src_class[-1] = $item[1]->{'search'}->[0];
            $src_class[-1] = ($item[1]->{'callout'}->[0] =~ /^.*->-(\w+)$/\1/)[1];
            $dst_class[-1] = $src_class[-1];
            $return = $item[1];
        }

    element_class_given:    '@'
        {
            $return = { };
        }

    element_class_exact:    /\w+/
        {
            my %parameters = (validations => -1);
            $return = { search => [ $item[1], { from => $src_class[-2], %parameters } ] };
            $return = { callout => [ $src_class[-2] . '->-' . $item[1], { } ] };
        }

    end:                    /^\Z/

__END_OF_GRAMMAR__



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
