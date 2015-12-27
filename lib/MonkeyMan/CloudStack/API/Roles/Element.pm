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
use Lingua::EN::Inflect qw(A);



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

around 'get_type' => sub {
    my $orig = shift;
    my $self = shift;

    return($self->$orig)
        unless(@_);

    return(_translate_type($self->$orig, @_));

};

func _translate_type(Str $type!, Bool :$a, Bool :$noun = 1) {
    if($noun) {
        $type =~ s/(?:\b|(?<=([a-z])))([A-Z][a-z]+)/(defined($1) ? ' ' : '') . lc($2)/eg;
        $type = A($type)
            if($a);
    }
    return($type);
}



has 'magic_words' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_magic_words',
    writer      =>   '_set_magic_words',
    builder     => '_build_magic_words',
    lazy        => 1
);

method _build_magic_words {

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
    return(\%magic_words);

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

method _build_id {
    $self->get_id;
}

around 'get_id' => sub {
    my $orig = shift;
    my $self = shift;

    return($self->get_parameter('/id'))
        if($self->has_dom);

    return(undef);
};

method get_parameter(Str $xquery_postfix) {

    return(undef)
        unless($self->has_dom);

    my $value = $self->get_dom->findvalue(
        '/' . $self->get_magic_words->{'list_tag_entity'} .
        $xquery_postfix
    );

    # btw, what happen if there is no such a parameter?

    return($value);

}

has 'criterions' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_criterions',
    writer      =>   '_set_criterions',
    predicate   =>    'has_criterions',
    builder     => '_build_criterions',
    lazy        => 1
);

has 'dom' => (
    is          => 'rw',
    isa         => 'XML::LibXML::Document',
    reader      =>    'get_dom',
    writer      =>   '_set_dom',
    predicate   =>    'has_dom',
    builder     => '_build_dom',
    clearer     => '_clear_dom',
    lazy        => 1
);

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

    return($self->_set_dom($dom));

}

method load_by_criterions(
    HashRef :$criterions!,
    Str     :$return_as = 'DOM'
) {

    $self->_set_criterions($criterions);
    $self->_clear_dom;
    foreach my $dom ($self->find_doms_by_criterions(
        criterions  => $criterions
    )) {
        $self->load_dom($dom);
    }

    $self->get_api->get_cloudstack->get_monkeyman->get_logger->tracef(
        "The %s %s has been loaded with the %s DOM " .
        "as it matched the %s set of criterions",
        $self, $self->get_type(noun => 1), $self->get_dom, $criterions
    );

    return($self->_return_as($self->get_dom, $return_as));

}

method find_doms_by_criterions(
    HashRef :$criterions!,
    Str     :$return_as = 'DOM'
) {

    my $logger = $self->get_api->get_cloudstack->get_monkeyman->get_logger;

    $logger->tracef("Looking for %s matching the %s set of criterias",
        $self->get_type(a => 1, noun => 1),
        $criterions
    );

    my %parameters = ($self->_criterions_to_parameters(%{ $criterions }));
       $parameters{'command'} = $self->get_magic_words->{'find_command'};

    my $doms = $self->get_api->run_command(
        parameters => \%parameters,
    );

    my @result;

    foreach my $node ($doms->findnodes(
        '/' . $self->get_magic_words->{'list_tag_global'} .
        '/' . $self->get_magic_words->{'list_tag_entity'}
    )->get_nodelist) {
        my $new_node = $node->cloneNode(1);
        my $new_dom = XML::LibXML::Document->new();
        $new_dom->addChild($new_node);
        $logger->tracef(" ... The %s DOM has been initialized", $new_dom);

        push(@result, $self->_return_as($new_dom, $return_as));
    }

    return(@result);

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

method _return_as(
    XML::LibXML::Document   $dom,
    Str                     $return_as = 'DOM'
) {

    my %magic_words = %{ $self->get_magic_words };

    if($return_as eq 'ID') {
        my $id = $dom->findvalue(
            '/' . $magic_words{'list_tag_entity'} .
            '/id'
        );
        return($id);
    } elsif($return_as eq 'DOM') {
        return($dom);
    } else {
        (__PACKAGE__ . '::Exception::InvalidParametersValue')->throwf(
            "The return_as parameter's value is invalid (%s).",
            $return_as
        );
    }

}



method find_related_to_me {
}



method filter_by_xpath {
}



sub BUILD {
    my $self = shift;
    my $criterions = $self->get_criterions;
    $self->load_by_criterions(criterions => $criterions)
        if(defined($criterions));
}



1;
