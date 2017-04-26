package HyperMouse::Schema::DefaultResult::I18nRelationships;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class';

use Method::Signatures;
use Lingua::EN::Inflect::Phrase qw(to_S to_PL);



has default_language_id => (
    is          => 'ro',
    isa         => 'Int',
    reader      =>   '_get_default_language_id',
    writer      =>   '_set_default_language_id',
    predicate   =>   '_has_default_language_id',
    builder     => '_build_default_language_id',
    lazy        => 1
);

method _build_default_language_id {
    $self->_get_language_id($self->_get_default_language_code);
}

has default_language_code => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>   '_get_default_language_code',
    writer      =>   '_set_default_language_code',
    predicate   =>   '_has_default_language_code',
    builder     => '_build_default_language_code',
    lazy        => 1
);

method _build_default_language_code {
    'en_US'
}



method _get_language_id (Str $language_code!) {
    $self
        ->result_source
        ->schema
        ->resultset('Language')
        ->search({ code => $language_code })
        ->filter_validated
        ->single
        ->id;
}



# We perform all the magic after the original register_relationship method
method register_relationship(...) {
    my $result = $self->next::method(@_);

    my $current_class_name = $self->result_class;
    my $related_class_name = $_[1]->{'class'};
    if($related_class_name eq $current_class_name . 'I18n') {
        my $method_name_real =      $_[0];
        my $method_name_i18n = to_S($_[0]);
        $self->meta->add_method($method_name_i18n => method(Maybe[Str] $language?) { $self->i18n_translate($method_name_real, $language); });
    }

    return($result);
}

method i18n_translate (
    Str         $accessor,
    Maybe[Str]  $language
) {
    if(!defined($language)) {
        $language = $self->_get_default_language_id;
    } elsif($language !~ /^\d+$/) {
        $language = $self->_get_language_id($language);
    }
    return($self->$accessor->search({ language_id => $language })->filter_validated->single);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
