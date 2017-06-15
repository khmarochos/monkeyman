package HyperMouse::Schema::DefaultResult::DeepRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use HyperMouse::Exception qw(PatternAbsent);

use Method::Signatures;
use Lingua::EN::Inflect::Phrase qw(to_S to_PL);
use Text::Balanced qw(extract_bracketed);



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



    if(defined($prepare)) {

        push(@resultsets, scalar($self->result_source->schema->resultset($resultset_class)->search({ id => $self->id })));

    }



    if(defined($search)) {

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
                defined($search_val->{'search'})    ||
                defined($search_val->{'callout'})   ||
                defined($search_val->{'prepare'})
            ) {
                foreach my $result ($resultset->all) {
                    my $resultset = $result->search_related_deep(
                        %{ $search_parmeters_base },
                        %{ $search_val }
                    );
                    push(@resultsets, scalar($resultset)) if($resultset->all > 0);
                }
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

method _search_related_deep_pattern_translate_DEPRECATED(
    Str         $exp!,
    Maybe[Str]  $input_class?       = $self->result_source->source_name when undef,
    Maybe[Bool] $update_vocabulary? = 0                                 when undef
) {

    my $logger = $self->get_logger;

    $logger->tracef("Translating the %s search pattern", $exp);

    my $result = $self->_get_search_related_deep_shortcut->{ $exp };
    if(defined($result)) {
        $logger->tracef("We've found the search pattern in the vocabulary: %s", $result);
        return($result);
    }

    my $keep_extracting = 1;
    while ($keep_extracting) {
        my($extracted, $suffix, $prefix) = extract_bracketed($exp, '()', qr/[^()]*/);
        $logger->tracef("%s consists of %s, %s, %s", $exp, $extracted, $suffix, $prefix);
        # TODO: if $@ defined, raise an exception
        
        if(defined($extracted)) {
            $extracted =~ s/^[(\s]|[\s)]$//g;
            $extracted =~ s/^\@/$input_class/;
            $result = $self->_search_related_deep_pattern_translate_DEPRECATED($extracted, $input_class, $update_vocabulary);
            $exp = $suffix;
        } else {
            $keep_extracting = 0;
            $result = {};
        }
    }

    return($result);

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
