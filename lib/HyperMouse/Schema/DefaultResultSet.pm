package HyperMouse::Schema::DefaultResultSet;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends
    'DBIx::Class::ResultSet',
    'HyperMouse::Schema::ValidityCheck',
    'HyperMouse::Schema::PermissionCheck';

use HyperMouse::Exception qw(PatternAbsent InvalidClass);

use Method::Signatures;
use DateTime;
use DateTime::TimeZone;
use Switch;



__PACKAGE__->load_components('Helper::ResultSet');



method get_schema {
    $self->result_source->schema;
}

method get_hypermouse {
    $self->get_schema->get_hypermouse;
}

method get_logger {
    $self->get_hypermouse->get_logger;
}




method datetime_parser {
    $self->result_source->storage->datetime_parser;
}

method format_datetime(
    DateTime $datetime!
) {
    $self->datetime_parser->format_datetime($datetime);
}



method search_related_deep(
    Str         :$resultset_class!,
    ArrayRef    :$callout?,
    ArrayRef    :$pipe?,
    ArrayRef    :$join?,
    Int         :$fetch_permissions_default?    = 0b000111,
    Int         :$fetch_validations_default?    = 0b000111,
    Int         :$search_permissions_default?   = 0b000111,
    Int         :$search_validations_default?   = 0b000111,
    ArrayRef    :$search?,
    ArrayRef    :$prepare?,
    Int         :$prepare_permissions_default?  = 0b000111,
    Int         :$prepare_validations_default?  = 0b000111,
    Bool        :$union?                        = 1,
    Maybe[Int]  :$permissions,
    Maybe[Int]  :$validations,
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
    };

    my @resultsets;

    if(defined($callout)) {

        my @callout_local = @{ $callout };
        while(my($callout_key, $callout_val) = splice(@callout_local, 0, 2)) {

            $logger->tracef("Calling out the %s search pattern", $callout_key);

            my $search_parameters_more = $self->_search_related_deep_pattern_translate($callout_key);
            (__PACKAGE__ . '::Exception::PatternAbsent')->throwf(
                "Can't call out the %s search pattern",
                "$callout_key"
            )
                unless(defined($search_parameters_more));

            push(@resultsets, scalar($self->search_related_deep(
                %{ $search_parmeters_base },
                %{ $search_parameters_more },
                %{ $callout_val }
            )));

        }

    } elsif(defined($join)) {

        foreach my $join_element (@{ $join }) {
            my $resultset = scalar($self->search_related_deep(
                %{ $search_parmeters_base },
                %{ $join_element },
                union => 1
            ));
            push(@resultsets, $resultset);
        }

    } elsif(defined($pipe)) {

        my $resultset = $self;
        foreach my $pipe_element (@{ $pipe }) {
            $resultset = scalar($resultset->search_related_deep(
                %{ $search_parmeters_base },
                %{ $pipe_element },
                union => 1
            ));
        }
        push(@resultsets, $resultset);

    } elsif(defined($prepare)) {

        my $given = ref($self) =~ s/^.*::(?!::)(.+)$/$1/r;
        (__PACKAGE__ . '::Exception::InvalidClass')->throwf(
            "%s is given instead of %s expected",
            $given,
            $prepare->[0]
        )
            if($given ne $prepare->[0]);

        push(@resultsets, $self);

    } elsif(defined($search)) {

        my @search_local = @{ $search };
        while(my($search_key, $search_val) = splice(@search_local, 0, 2)) {
        
            my $resultset = $self->search_related_rs($search_key);

            my $search_permissions = $search_val->{'permissions'};
            my $search_validations = $search_val->{'validations'};

            $resultset = $resultset->filter_validated(
                mask => $search_validations >= 0
                      ? $search_validations
                      : ($search_val->{'fetch'} ? $fetch_validations_default : $search_validations_default)
            )
                if(defined($search_validations));

            $resultset = $resultset->filter_permitted(
                mask => $search_permissions >= 0
                      ? $search_permissions
                      : ($search_val->{'fetch'} ? $fetch_permissions_default : $search_permissions_default)
            )
                if(defined($search_permissions));

            push(@resultsets, scalar($resultset))
                if($search_val->{'fetch'});

            if(
                defined($search_val->{'pipe'})      ||
                defined($search_val->{'join'})      ||
                defined($search_val->{'search'})    ||
                defined($search_val->{'callout'})   ||
                defined($search_val->{'prepare'})
            ) {
                foreach my $resultset ($resultset->search_related_deep(
                    %{ $search_parmeters_base },
                    %{ $search_val }
                )) {
                    push(@resultsets, scalar($resultset));
                }
            }

        }

    }



    unless(@resultsets) {
        push(@resultsets, scalar($self->get_schema->resultset($resultset_class)->search({ 0 => 1 })));
        # $logger->tracef("No findings :-( %s %s", $resultset_class, $resultsets[0]);
    }

    if($union) {
        # $logger->tracef("Uniting %s", join(', ', map({ ref($_) . '(' . join (', ', map({ $_->id } $_->all)) . ')' } @resultsets)));
        my $resultset = shift(@resultsets);
        return(
            scalar(@resultsets) > 0
                  ? $resultset->union([ @resultsets ])
                  : $resultset
        )
    } else {
        return(@resultsets);
    }

}



has _search_related_deep_grammar_parser => (
    is          => 'ro',
    isa         => 'Parse::RecDescent',
    reader      =>   '_get_search_related_deep_grammar_parser',
    writer      =>   '_set_search_related_deep_grammar_parser',
    predicate   =>   '_has_search_related_deep_grammar_parser',
    builder     => '_build_search_related_deep_grammar_parser',
    lazy        => 1
);

method _build_search_related_deep_grammar_parser {
    return($HyperMouse::Schema::DeepRelationshipsGrammarParser);
}



method _search_related_deep_pattern_translate(Str $exp!) {

    my $logger = $self->get_logger;

    $logger->tracef("Translating the %s search pattern", $exp);

    my $parse_result = $self->_get_search_related_deep_grammar_parser->parse($exp, 1);
    unless(defined($parse_result)) {
        # TODO: raise an exception
    }
    
    $logger->tracef("The translation result is: %s", $parse_result);

    return($parse_result);

}



=pod

    $resultset->update_smart(
        record => {
            field1 => 1,
            field2 => 2,
            field3 => 3
        },
        update_include => {
            search_conditions => [ qw(field1 field2) ],
            search_conditions => [ { field9 => 9 } ]
        },
        update_exclude => {
            conditions_match => [ { field0 => 0 } ]
        }
    );

At first it finds all the records where C<field1> contains C<1>, C<field2>
contains C<2> and C<field9> contains C<9>. The records where C<field0>
contains C<0> are skipped. These rules are set by C<update_include> and
C<update_exclude>.

All the found records are being analyzed. The records whose fields match the
C<record> parameter won't be updated if C<force> is false. Any records
mismatch (their C<field3> contain anything else but C<3>), the record will
be marked as outdated (by updating its C<valid_till> field) and a new record
will be created with C<valid_since> field equal to the current time. Other
fields of the new record will be filled according to the C<record> parameter.

You might need also set C<mask> and C<now>, these parameters' names are
pretty self-descriptive. :-)

=cut

method update_smart(
    HashRef     :$record!,
    HashRef     :$update_include?   = { },
    HashRef     :$update_exclude?   = { },
    Bool        :$forced?           = 0,
    Int         :$mask?             = 0b000111,
    DateTime    :$now?              = DateTime->now
) {

    my $search_pattern  = { };
    my $resultset       = $self;
    my $fields_match;
    my $conditions_match;
    if(
        defined($fields_match = $update_include->{'fields_match'})
        && (ref($fields_match) eq 'ARRAY')
    ) {
        foreach my $field_match (@{ $fields_match }) {
            $search_pattern->{ $field_match } = $record->{ $field_match };
        }
        $resultset = $resultset->search($search_pattern);
    }
    if(
        defined($conditions_match = $update_include->{'conditions_match'})
        && (ref($conditions_match) eq 'ARRAY')
    ) {
        foreach my $condition_match ((@{ $conditions_match })) {
            $resultset = $resultset->search($condition_match);
        }
    }
    $resultset = $resultset->filter_validated(mask => $mask, now => $now);
    if(
        defined($conditions_match = $update_exclude->{'conditions_match'})
        && (ref($conditions_match) eq 'ARRAY')
    ) {
        foreach my $condition_match ((@{ $conditions_match })) {
            $resultset = $resultset->search({ -not => $condition_match });
        }
    }
    $resultset = $resultset->filter_validated(mask => $mask, now => $now);

    my $ids_ok = $forced
        ? []
        : [ map({ $_->id } $resultset->search($record)->all) ];

    $resultset
        ->search({ id           => { -not_in => $ids_ok } })
        ->update({ valid_till   => $now });

    return(
        scalar(@{ $ids_ok }) == 0
            ?
                $self->create({
                    valid_since => $now,
                    valid_till  => undef,
                    removed     => undef,
                    %{ $record }
                })
            :
                $self->search({
                    id          => { -in => $ids_ok }
                })
                ->all
    );

}



__PACKAGE__->meta->make_immutable;

1;
