package WebMug::Controller::Dashboard;

use MonkeyMan::Utils;

use Mojo::Base qw(Mojolicious::Controller);
use Lingua::EN::Inflect::Phrase;

sub welcome {

    my $c = shift;

    my $user_email  = $c -> session('user_email');

    my $related_elements_index      = {};
    my $related_elements_tree       = {};
    my $relations_tree_structure    = {
        user => {
            agreement => {
                payment => {},
                charge => {},
                provision  => {
                    service => {},
                    pricelist => {},
                    charge => {}
                },
                customer => {
                    agreement => {
                        user => {}
                    }
                },
            }
        }
    };

    $c -> build_relations_tree(
        related_elements_index      => $related_elements_index,
        related_elements_tree       => $related_elements_tree,
        related_elements_to_add     => [ $c -> hm_db -> resultset('User') -> find({ email => $user_email }) ],
        relations_tree_structure    => $relations_tree_structure->{'user'}
    );

    mm_dump_object(
        data        => $related_elements_index,
        object_name => 'related_elements_index'
    );
    mm_dump_object(
        data        => $related_elements_tree,
        object_name => 'related_elements_tree'
    );
        
    $c -> render(
        related_elements_index  => $related_elements_index,
        related_elements_tree   => $related_elements_tree
    );

}

sub build_relations_tree {

    my($c, %parameters) = @_;
    my $related_elements_index;
    my $related_elements_tree;
    my $related_elements_to_add;
    my $relations_tree_structure;

    mm_check_method_invocation(
        'object'    => $c,
        'checks'    => {
            '$related_elements_index'   => { variable => \$related_elements_index,      value => $parameters{'related_elements_index'} },
            '$related_elements_tree'    => { variable => \$related_elements_tree,       value => $parameters{'related_elements_tree'} },
            '$related_elements_to_add'  => { variable => \$related_elements_to_add,     value => $parameters{'related_elements_to_add'} },
            '$relations_tree_structure' => { variable => \$relations_tree_structure,    value => $parameters{'relations_tree_structure'} }
        }
    );

    foreach my $element (@{ $related_elements_to_add }) {

        $c->logger->trace(mm_sprintf("Have found the %s element", $element));

        my $elements_type = $element->result_source->name;

        $related_elements_index -> {$elements_type} -> {$element -> id} = $element;
        $related_elements_tree  -> {$elements_type} -> {$element -> id} = {};

        foreach my $relation (keys(%{ $relations_tree_structure })) {
            my $relation_PL = Lingua::EN::Inflect::Phrase::to_PL($relation);
            my $relation_S  = Lingua::EN::Inflect::Phrase::to_S ($relation);
            my @elements_ref;
            if($element->can($relation_PL)) { push(@elements_ref, ($element->$relation_PL)); }
            if($element->can($relation_S )) { push(@elements_ref, ($element->$relation_S)); }
            $c->build_relations_tree(
                related_elements_index      => $related_elements_index,
                related_elements_tree       => $related_elements_tree->{$elements_type}->{$element->id},
                related_elements_to_add     => \@elements_ref,
                relations_tree_structure    => $relations_tree_structure->{$relation}
            );
        }

    }

}

1;
