package MonkeyMan::CloudStack::API::Roles::Element;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Essentials';
with 'MonkeyMan::Roles::WithTimer';

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

around 'get_type' => sub {

    my $orig = shift;
    my $self = shift;

    if(@_) {
        return($self->get_api->translate_type(type => $self->$orig, @_));
    } else {
        return($self->$orig);
    }
};



has 'magic_words' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_magic_words',
    writer      =>   '_set_magic_words',
    builder     => '_build_magic_words',
    lazy        => 1
);

method _build_magic_words {

    my %magic_words = $self->get_api->get_magic_words($self->get_type);

    return(\%magic_words);

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



has 'dom_updated' => (
    is          => 'rw',
    isa         => 'Int',
    reader      =>    'get_dom_updated',
    writer      =>   '_set_dom_updated',
    predicate   =>    'has_dom_updated',
    clearer     => '_clear_dom_updated',
    builder     => '_build_dom_updated',
    lazy        => 1
);

has 'dom' => (
    is          => 'rw',
    isa         => 'XML::LibXML::Document',
    reader      =>    'get_dom',
    writer      =>   '_set_dom',
    predicate   =>    'has_dom',
    clearer     => '_clear_dom',
    builder     => '_build_dom',
    lazy        => 1
);

method _build_dom {
    XML::LibXML::Document->new;
}

around '_clear_dom' => sub {
    my $orig = shift;
    my $self = shift;

    $self->_clear_dom_updated;
    $self->$orig;
};

around '_set_dom' => sub {
    my $orig = shift;
    my $self = shift;
    my $dom = shift;

    my $message = $self->has_dom ?
        mm_sprintf(
            "The %s element already have the %s DOM loaded, " .
            "overloading it with the %s DOM",
            $self, $self->get_dom, $dom
        ) :
        mm_sprintf(
            "The %s element's will be loaded with the %s DOM",
            $self, $dom
        );

    $self->_set_dom_updated(${$self->get_time_current}[0]);
    $self->$orig($dom);

};

before 'get_dom' => sub {
    my $orig = shift;
    my $self = shift;
};

method refresh_dom {

    my $id = $self->get_id;

    $self->get_api->get_cloudstack->get_monkeyman->get_logger->tracef(
        "Refreshing the %s %s's (has ID = %s) DOM",
        $self,
        $self->get_type(noun => '1'),
        $id
    );

    $self->_clear_dom;

    foreach my $dom ($self->get_api->get_doms(
        type        => $self->get_type,
        criterions  => { id => $id }
    )) {
        $self->_set_dom($dom);
    }

    return($self->get_dom);

}



method get_related(
    Str         :$type!,
    Maybe[Str]  :$best_before
) {

    my $logger = $self->get_api->get_cloudstack->get_monkeyman->get_logger;

    no strict 'refs';
    my $class = blessed($self);
    my %related = %{'::' . $class . '::_related'};

    my $related_class_name  = $related{$type}->{'class_name'};
    my $related_local_key   = $related{$type}->{'local_key'};
    my $related_foreign_key = $related{$type}->{'foreign_key'};

    $logger->tracef(
        "Looking for %s relative to %s, " .
        "their %s value shall be equal to our %s value",
        $self->get_api->translate_type(
            type => $type,
            noun => 1,
            plural => 1
        ),
        $self,
        $related_local_key,
        $related_foreign_key
    );

    return($self->get_api->get_elements(
        type        => $type,
        criterions  => {
            $related_foreign_key => $self->qxp(
                query       => '/' . $related_local_key,
                return_as   => 'value'
            )
        }
    ));

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

    return(($self->qxp(
        query       => '/id',
        return_as   => 'value'
    ))[0]);
};



method qxp(
    Str                     :$query!,
    XML::LibXML::Document   :$dom = $self->get_dom,
    Maybe[Str]              :$return_as,
    Maybe[Str]              :$best_before
) {

    if(0 || defined($best_before)) {
        # 
        # Here be cache tricks
        #
        $self->refresh_dom;
    }

    if($return_as =~ /^(id|element)$/) {
        $return_as .= '[' . $self->get_type . ']'; # Looks rude, FIXME, please
    }

    my @results = $self->get_api->qxp(
        query       => '/' . $self->get_magic_words->{'list_tag_entity'} . $query,
        dom         => $dom,
        return_as   => $return_as
    );
    return(@results);

}



1;
