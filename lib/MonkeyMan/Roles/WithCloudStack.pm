package MonkeyMan::Roles::WithCloudStack;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose::Role;
use namespace::autoclean;

use MonkeyMan::Constants qw(:cloudstack);
use MonkeyMan::CloudStack;

# Use 3rd-party libraries
# # use MooseX::Handies;
use Method::Signatures;



has 'cloudstack_default_handy' => (
    is          => 'ro',
    isa         => 'Str',
    lazy        => 1,
    reader      =>    'get_cloudstack_default_handy',
    writer      =>   '_set_cloudstack_default_handy',
    predicate   =>   '_has_cloudstack_default_handy',
    builder     => '_build_cloudstack_default_handy'
);

method _build_cloudstack_default_handy {
    return(
        defined($self->get_parameters->get_mm_default_cloudstack) ?
                $self->get_parameters->get_mm_default_cloudstack :
                &MM_CLOUDSTACK_DEFAULT_HANDY
    );
}

method _build_cloudstacks {
    return({});
}

method _initialize_cloudstack_handy(Str $handy!) {
    return(
        MonkeyMan::CloudStack->new(
            monkeyman       => $self,
            configuration   => $self
                                ->get_configuration
                                    ->{'cloudstack'}
                                        ->{$handy}
        )
    );
}

method _initialize_cloudstacks {
    $self->meta->add_attribute(
        'cloudstacks' => (
            is          => 'ro',
            isa         => 'HashRef[MonkeyMan::CloudStack]',
            reader      =>   '_get_cloudstacks',
            writer      =>   '_set_cloudstacks',
            builder     => '_build_cloudstacks',
            lazy        => 1,
            handies     => [{
                name        => 'get_cloudstack',
                default     => 'get_cloudstack_default_handy',
                initializer => '_initialize_cloudstack_handy',
                strict      => 1
            }]
        )
    );
}



1;
