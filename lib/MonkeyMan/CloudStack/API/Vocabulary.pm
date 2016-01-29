package MonkeyMan::CloudStack::API::Vocabulary;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Singleton;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Essentials';

use MonkeyMan::Exception qw(
    VocabularyIsMissing
    VocabularyIsIncomplete
);

use Method::Signatures;



has 'vocabulary' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_vocabulary',
    writer      =>   '_set_vocabulary',
    predicate   =>   '_has_vocabulary',
    builder     => '_build_vocabulary',
    lazy        => 1
);

has 'type' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Types::ElementType',
    reader      =>  'get_type',
    writer      => '_set_type',
    required    => 1
);

method _build_vocabulary {

    my $type        = $self->get_type;
    my $class_name  = $self->get_api->load_element_package($type);

    no strict 'refs';
    my $vocabulary_data = \%{'::' . $class_name . '::vocabulary_data'};

    unless(defined($vocabulary_data)) {
        (__PACKAGE__ . '::Exception::VocabularyIsMissing')->throwf(
            "The %s class' vocabulary data is missing. " .
            "Sorry, but I can not use this class.",
            $class_name
        );
    }

    $self->check_vocabulary($vocabulary_data, 1);

    return($vocabulary_data);

}

method check_vocabulary(
    HashRef $vocabulary_data?   = $self->get_vocabulary,
    Bool    $fatal?             = 1
) {

    foreach my $word (qw(
        name
        actions
        actions:list
        actions:list:request
        actions:list:response
    )) {
        unless(defined($self->lookup($word, ':', $vocabulary_data))) {
            if($fatal) {
                (__PACKAGE__ . '::Exception::VocabularyIsIncomplete')->throwf(
                    "The %s class' vocabulary data is missing the %s word. " .
                    $self->get_type, $word
                );
            } else {
                return(0)
            }
        }
    }

    return(1);

}



method lookup(
    Str     $word!,
    Str     $delimiter  = ':',
    HashRef $ref        = $self->get_vocabulary
) {

    if((my @words = split($delimiter, $word)) > 1) {
        my $word0 = shift(@words);
        return($self->lookup(join($delimiter, @words), $delimiter, $ref->{$word0}));
    } else {
        return($ref->{$word});
    }
}



__PACKAGE__->meta->make_immutable;

1;
