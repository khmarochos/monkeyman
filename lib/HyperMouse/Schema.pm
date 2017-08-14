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



use Parse::RecDescent;

# In case of trouble uncomment these:
#$::RD_ERRORS    = 1;
#$::RD_WARN      = 1;
#$::RD_HINT      = 1;
#$::RD_TRACE     = 1;

our $DeepRelationshipsGrammarParser = Parse::RecDescent->new(<<'__END_OF_GRAMMAR__');

    {
        use strict;
        no warnings;

        use HyperMouse::Exception qw(SourceClassUndefined);

        use String::CamelCase qw(decamelize);
        use Data::Dumper;

        my $op_stack = [
            {
                operator    => undef,
                join        => undef,
                pipe        => undef,
                pipe_type   => undef
            }
        ];

        my $macroses = {

            #
            # FROM Person TO ...
            #

            '@Person-[everything][myself]>-@Person' => {
                resultset_class => 'Person',
                callout => [ q{
                    @Person > (
                        (
                            (
                                (
                                    (
                                        @ > @Corporation > @Contractor
                                    ) & (
                                        @ > @Contractor
                                    )
                                ) [client|provider]> @ProvisioningAgreement
                            ) & (
                                @ > @ProvisioningAgreement
                            )
                        ) > (
                            (
                                @ [client|provider]> @Contractor > (
                                    (
                                        @ > @Corporation > @Person
                                    ) & (
                                        @ > @Person
                                    )
                                )
                            ) & (
                                @ > @Person
                            )
                        )
                    ) & (
                        @Person [children]> @Person
                    ) & (
                        @Person
                    )
                } => { } ]
            },

            '@Person-[children]>-@Person' => {
                resultset_class => 'Person',
                search => [
                    'person_x_person_parent_people' => {
                        validations => -1,
                        search => [
                            'child_person' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            '@Person->-@Corporation' => {
                resultset_class => 'Corporation',
                search => [
                    'person_x_corporations' => {
                        permissions => -1,
                        validations => -1,
                        search => [
                            'corporation' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            '@Person->-@Contractor' => {
                resultset_class => 'Contractor',
                search => [
                    'person_x_contractors' => {
                        permissions => -1,
                        validations => -1,
                        search => [
                            'contractor' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            '@Person->-@ProvisioningAgreement' => {
                resultset_class => 'ProvisioningAgreement',
                search => [
                    'person_x_provisioning_agreements' => {
                        validations => -1,
                        permissions => -1,
                        search => [
                            'provisioning_agreement' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            #
            # FROM ProvisioningAgreement TO ...
            #

            '@ProvisioningAgreement->-@Person' => {
                resultset_class => 'Person',
                search => [
                    'person_x_provisioning_agreements' => {
                        validations => -1,
                        permissions => -1,
                        search => [
                            'person' => {
                                validations => -1,
                                fetch       => 1
                            }
                        ]
                    }
                ]
            },

            '@ProvisioningAgreement-[client]>-@Contractor' => {
                resultset_class => 'Contractor',
                search => [
                    'client_contractor' => {
                        validations => -1,
                        fetch       =>  1
                    }
                ]
            },

            '@ProvisioningAgreement-[provider]>-@Contractor' => {
                resultset_class => 'Contractor',
                search => [
                    'provider_contractor' => {
                        validations => -1,
                        fetch       =>  1
                    }
                ]
            },

            '@ProvisioningAgreement-[client|provider]>-@Contractor' => {
                resultset_class => 'Contractor',
                join => [
                    { callout => [ '@ProvisioningAgreement-[client]>-@Contractor' => { } ] },
                    { callout => [ '@ProvisioningAgreement-[provider]>-@Contractor' => { } ] }
                ]
            },

            #
            # FROM Corporation TO ...
            #

            '@Corporation->-@Contractor' => {
                resultset_class => 'Contractor',
                search => [
                    'corporation_x_contractors' => {
                        validations => -1,
                        search => [
                            'contractor' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            '@Corporation->-@Person' => {
                resultset_class => 'Person',
                search => [
                    'person_x_corporations' => {
                        validations => -1,
                        permissions => -1,
                        search => [
                            'person' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            #
            # FROM Contractor TO ...
            #

            '@Corporation->-@Contractor' => {
                resultset_class => 'Contractor',
                search => [
                    'corporation_x_contractors' => {
                        validations => -1,
                        search => [
                            'contractor' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            '@Contractor-[client]>-@ProvisioningAgreement' => {
                resultset_class => 'ProvisioningAgreement',
                search => [
                    'provisioning_agreement_client_contractors' => {
                        validations => -1,
                        fetch       =>  1
                    }
                ]
            },

            '@Contractor-[provider]>-@ProvisioningAgreement' => {
                resultset_class => 'ProvisioningAgreement',
                search => [
                    'provisioning_agreement_provider_contractors' => {
                        validations => -1,
                        fetch       =>  1
                    }
                ]
            },

            '@Contractor-[client|provider]>-@ProvisioningAgreement' => {
                resultset_class => 'ProvisioningAgreement',
                join => [
                    { callout => [ '@Contractor-[client]>-@ProvisioningAgreement' => { } ] },
                    { callout => [ '@Contractor-[provider]>-@ProvisioningAgreement' => { } ] }
                ]
            },

            '@Contractor->-@Person' => {
                resultset_class => 'Person',
                search => [
                    'person_x_contractors'  => {
                        permissions => -1,
                        validations => -1,
                        search => [
                            'person' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            '@Contractor->-@Corporation' => {
                resultset_class => 'Corporation',
                search => [
                    'corporation_x_contractors'  => {
                        validations => -1,
                        search => [
                            'corporation' => {
                                validations => -1,
                                fetch       =>  1
                            }
                        ]
                    }
                ]
            },

            #
            # FROM ResourcePiece TO ...
            #

            '@ResourcePiece->-@ProvisioningObligation' => {
                resultset_class => 'ProvisioningObligation',
                search => [
                    'provisioning_obligations' => {
                        validations => -1,
                        fetch       =>  1
                    }
                ]
            },

            #
            # FROM ProvisioningObligation TO ...
            #

            '@ProvisioningObligation->-@ProvisioningAgreement' => {
                resultset_class => 'ProvisioningAgreement',
                search => [
                    'provisioning_agreement' => {
                        validations => -1,
                        fetch       =>  1
                    }
                ]
            },

        };

        sub _show_stack {
            warn(shift . ' ' . join('+',
                map( {
                    my $s = $_;
                    sprintf(
                        '[%.1s|%.4s|%.4s|%.4s]',
                        $s->{'operator'},
                        $s->{'join'},
                        $s->{'pipe'},
                        $s->{'pipe_type'}
                    );
                } @{ $op_stack })
            ));
        }

    }

    parse:                  operation end
        {
            $return = $item[1];
        }

    operation:              operand_first ( operator_and_operand )(s?)
        {
            my $i = 0;
            my $r = $item[1];
            while(defined(my $g = $item[2][$i++])) {
                $r = {
                    resultset_class     => $g->{'operand'}->{'resultset_class'},
                    $g->{'operator'}    => [ $r, $g->{'operand'} ],
                };
            }
            $return                 = $r;
        }

    operator_and_operand:   operator operand
        {
            $return = {
                operator    => $item[1],
                operand     => $item[2]
            };
        }

    operator:               operator_join | operator_pipe
        {
            $return = $item[1];
        }

    operator_join:          /-*&-*/
        {
            $op_stack->[-1]->{'pipe'} = $op_stack->[-1]->{'join'};
            $return = $op_stack->[-1]->{'operator'} = 'join';
        }

    operator_pipe:          /-*/ ( /\[.+\]/ )(?) />-*/
        {
            $op_stack->[-1]->{'pipe_type'} = $item[2][0];
            $return = $op_stack->[-1]->{'operator'} = 'pipe';
        }

    operand_first:          group | element_given
        {
            $return = $item[1];
        }

    operand:                group | element_macros | element_searched
        {
            $return = $item[1];
        }

    group:                  group_begin operation group_end
        {
            $return = $item[2];
        }

    group_begin:            '('
        {
            # _show_stack('(((');
            push(@{ $op_stack }, {
                operator    => $op_stack->[-1]->{'operator'},
                join        => $op_stack->[-1]->{'pipe'},
                pipe        => $op_stack->[-1]->{'pipe'},
                pipe_type   => $op_stack->[-1]->{'pipe_type'},
            } );
            $return = $item[1];
            # _show_stack('(((');
        }

    group_end:              ')'
        {
            # _show_stack(')))');
            # $op_stack->[-2]->{'join'} = $op_stack->[-1]->{'join'};
            $op_stack->[-2]->{'pipe'} = $op_stack->[-1]->{'pipe'};
            pop(@{ $op_stack });
            $return = $item[1];
            # _show_stack(')))');
        }

    element_given:          '@' ( /\w+/ )(?)
        {
            # _show_stack(' @ ');
            my $class_found;
            if(defined($item[2][0])) {
                $class_found = $item[2][0];
            } elsif(
                defined($op_stack->[-1])            &&
                defined($op_stack->[-1]->{'pipe'})
            ) {
                $class_found = $op_stack->[-1]->{'pipe'};
            } else {
                (__PACKAGE__ . '::Exception::SourceClassUndefined')->throw(
                    "Can't parse the expression, the source class isn't defined at the point where it should be"
                );
            }
            $op_stack->[-1]->{'pipe'} = $class_found;
            $op_stack->[-1]->{'join'} = $class_found
                unless(defined($op_stack->[-1]->{'join'}));
            $return = {
                resultset_class =>   $class_found,
                prepare         => [ $class_found, { } ]
            };
            # _show_stack(sprintf("%s\n", Dumper($return)));
            # _show_stack(' @ ');
        }

    element_macros:         '@' /\w+/
        {
            # _show_stack('@@@');
            unless(
                defined($op_stack->[-1])            &&
                defined($op_stack->[-1]->{'pipe'})
            ) {
                (__PACKAGE__ . '::Exception::SourceClassUndefined')->throw(
                    "Can't parse the expression, the source class isn't defined at the point where it should be"
                );
            }
            my $macros = sprintf('@%s-%s>-@%s',
                        $op_stack->[-1]->{'pipe'},
                defined($op_stack->[-1]->{'pipe_type'})
                      ? $op_stack->[-1]->{'pipe_type'}
                      : '',
                $item[2]
            );
            unless(defined($return = $macroses->{ $macros })) {
                $return = {
                    resultset_class => $item[2],
                    search          => [ decamelize($item[2]), { validations => -1, from => $op_stack->[-1]->{'pipe'} } ]
                };
            }
            # $op_stack->[-1]->{'pipe'} = $item[2];
            $op_stack->[-1]->{'join'} = $op_stack->[-1]->{'pipe'} = $item[2];
            # _show_stack('@@@');
        }

    element_searched:       /\w+/
        {
            $op_stack->[-1]->{'pipe'} = $item[1];
            $return = { search => [ $item[1], { validations => -1 } ] };
        }

    end:                    /^\Z/

__END_OF_GRAMMAR__



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
