package MonkeyMan::CloudStack::API::Traits::Element;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Essentials';

use Method::Signatures;



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



method find_by_criterions {

#    my($self, %input) = validated_hash(
#        \@_,
#        criterions  => { optional => 0, isa => 'HashRef' },
#        options     => { optional => 1, isa => 'HashRef', default => { return_as => 'DOM' } },
#        MX_PARAMS_VALIDATE_CACHE_KEY => _generate_MX_PARAMS_VALIDATE_CACHE_KEY(1)
#    );
#    my %criterions = validated_hash(
#        [ %{ $input{'criterions'} } ],
#        id          => { optional => 1, isa => 'Str' },
#        domainid    => { optional => 1, isa => 'Str' },
#        MX_PARAMS_VALIDATE_CACHE_KEY => _generate_MX_PARAMS_VALIDATE_CACHE_KEY(2)
#    );
#    my %options = validated_hash(
#        [ %{ $input{'options'} } ],
#        return_as   => { optional => 0, isa => 'Str', default => 'DOM' },
#        MX_PARAMS_VALIDATE_CACHE_KEY => _generate_MX_PARAMS_VALIDATE_CACHE_KEY(3)
#    );

}



method find_related_to_me {
}



method filter_by_xpath {
}



method load_dom(XML::LibXML::Document $dom!) {

    if($self->_has_dom) {
        $self->get_api->get_cloudstack->get_monkeyman->get_logger->warnf(
            "The %s element already have the %s DOM loaded, " .
            "overloading it with %s",
               $self,
               $self->_get_dom,
               $dom
        );
    }

    $self->_set_dom($dom);

}



1;
