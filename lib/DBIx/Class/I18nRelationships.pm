package DBIx::Class::I18nRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use Method::Signatures;
use Lingua::EN::Inflect::Phrase qw(to_S to_PL);



method register_relationship(...) {
    my $result = $self->next::method(@_);

    my $current_class_name = $self->result_class;
    my $related_class_name = $_[1]->{'class'};
    if($related_class_name eq $current_class_name . 'I18n') {
        my $method_name_real =      $_[0];
        my $method_name_i18n = to_S($_[0]);
        $self->meta->add_method($method_name_i18n => sub { my($self, $language) = @_; $self->translate($language, $method_name_real); });
    }

    return($result);
}

method translate (
    Str|Int $language,
    Str     $accessor
) {
    if($language !~ /^\d+$/) {
        $language = $self
            ->result_source
                ->schema
                    ->resultset("Language")
                        ->search({ code => $language })
                            ->filter_valid
                                ->single
                                    ->id;
    }
    return($self->$accessor->search({ language_id => $language })->filter_valid->single);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
