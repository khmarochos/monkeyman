package MonkeyMan::CloudStack::API::Roles::Element;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Essentials';

use MonkeyMan::Utils;
use MonkeyMan::Exception;

use Method::Signatures;



mm_register_exceptions qw(
    UndeterminableElementType
    MagicWordsArentDefined
    InvalidParametersValue
);



has 'type' => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_type',
    writer      =>   '_set_type',
    builder     => '_build_type',
    lazy        => 1
);

method _build_type {

    my($type) = blessed($self) =~ /::((?!.*::.*).+)$/;

    if(defined($type)) {
        return($type);
    } else {
        (__PACKAGE__ . '::Exception::UndeterminableElementType')->throwf(
            "Can't determine the %s element's type.", $self
        );
    }

}

has 'id' => (
    is          => 'rw',
    isa         => 'Str',
    reader      =>    'get_id',
    writer      =>   '_set_id',
    predicate   =>    'has_id',
    builder     => '_build_id',
    lazy        => 1
);

has 'dom' => (
    is          => 'rw',
    isa         => 'XML::LibXML::Document',
    reader      =>    'get_dom',
    writer      =>   '_set_dom',
    predicate   =>    'has_dom',
    builder     => '_build_dom',
    lazy        => 1
);



method find_by_criterions(
    HashRef :$criterions!,
    Bool    :$load      = 1,
    Str     :$return_as = 'DOM'
) {

    my $logger = $self->get_api->get_cloudstack->get_monkeyman->get_logger;
    my %magic_words = $self->_get_magic_words;

    $logger->tracef("Looking for a %s matching the %s set of criterias",
        $self->get_type,
        $criterions
    );

    my %parameters = ($self->_criterions_to_parameters(%{ $criterions }));
       $parameters{'command'} = $magic_words{'find_command'};

    my $result = $self->get_api->run_command(
        parameters => \%parameters
    );

    if($load) {
        $self->load_dom($result);
    }

    if($return_as eq 'ID') {
        my $id = $result->findvalue(
            '/' . $magic_words{'list_tag_global'} .
            '/' . $magic_words{'list_tag_entity'} .
            '/id'
        );
        return($id);
    } elsif($return_as eq 'DOM') {
        return($result);
    } else {
        (__PACKAGE__ . '::Exception::InvalidParametersValue')->throwf(
            "The return_as parameter's value is invalid (%s).",
            $return_as
        );
    }

}

method _get_magic_words {

    no strict 'refs';
    my $class_name = blessed($self);
    my %magic_words = %{'::' . $class_name . '::_magic_words'};
    unless(
        defined($magic_words{'find_command'}) &&
        defined($magic_words{'list_tag_global'}) &&
        defined($magic_words{'list_tag_entity'})
    ) {
        (__PACKAGE__ . '::Exception::MagicWordsArentDefined')->throwf(
            "The %s class doesn't have all magic words defined. " .
            "Sorry, but I can not use it.",
            $class_name
        );
    }
    return(%magic_words);

}

method _criterions_to_parameters(
    Str :$id,
    Str :$domainid
) {

    my %parameters;

    $parameters{'id'} = $id
        if(defined($id));
    $parameters{'domainid'} = $domainid
        if(defined($domainid));

    return(%parameters);

}



method find_related_to_me {
}



method filter_by_xpath {
}



method load_dom(XML::LibXML::Document $dom!) {

    if($self->has_dom) {
        $self->get_api->get_cloudstack->get_monkeyman->get_logger->warnf(
            "The %s element already have the %s DOM loaded, " .
            "overloading it with %s",
               $self,
               $self->get_dom,
               $dom
        );
    }

    $self->_set_dom($dom);

}



1;
