package HyperMouse::ServicePackagePool;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use HyperMouse::ResourceCounter;

use Method::Signatures;



has 'cache' => (
    required    => 1,
    is          => 'ro',
    isa         => 'Cache::Memcached',
    reader      => 'get_cache'
);

has 'hypermouse_schema' => (
    required    => 1,
    is          => 'ro',
    isa         => 'HyperMouse::Schema',
    reader      => 'get_hypermouse_schema'
);

has 'cloudstack_api' => (
    required    => 1,
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API',
    reader      => 'get_cloudstack_api'
);

has 'resources' => (
    required    => 0,
    init_arg    => undef,
    is          => 'ro',
    isa         => 'HashRef',
    reader      => 'get_resources',
    default     => sub { { } }
);



method detect_service_package (
    Str     :$cloudstack_element_type!,
    Str     :$cloudstack_element_id!,
    HashRef :$resources!,
    Bool    :$exceed?,
    Int     :$from!,
    Int     :$till!
) {
    my $cloudstack_element_key = $self->compose_element_key($cloudstack_element_type, $cloudstack_element_id);
    my $cloudstack_element_dom = $self->renew_if_needed    ($cloudstack_element_type, $cloudstack_element_id)
        if($cloudstack_element_type eq 'VirtualMachine');
    my $from_datetime = DateTime->from_epoch(epoch => $from);
    my $till_datetime = DateTime->from_epoch(epoch => $till);
    my $service_package_id;

    if(
      ! defined($self->get_resources->{ $cloudstack_element_key })  &&
        defined($cloudstack_element_dom)                            &&
                $cloudstack_element_dom->findvalue('/virtualmachine/tags[key="billing-legacy"]/value')
    ) {

        $self->get_resources->{ $cloudstack_element_key } = {
            cloudstack_element_type
                => $cloudstack_element_type,
            cloudstack_element_id
                => $cloudstack_element_id,
            service_package_id
                => undef,
            service_package_hint
                => $cloudstack_element_dom->findvalue('/virtualmachine/tags[key="billing-plan"]/value'),
            resource_counter
                => HyperMouse::ResourceCounter->new
        };

        my $service_package_set_criterions = [ {
           'service_package.short_name'
                => { like => $self->get_resources->{ $cloudstack_element_key }->{'service_package_hint'} . '%' }
        } ];
        while(my($resource_type_id, $quantity) = each(%{ $resources })) {
            push(@{ $service_package_set_criterions }, {
                service_package_id => {
                    -in =>
                        $self->get_hypermouse_schema
                            ->resultset('ServicePackageSet')
                            ->search({
                                resource_type_id    => $resource_type_id,
                                quantity            => $quantity
                            })
                            ->get_column('service_package_id')
                            ->as_query
                }
            });
        }
        my $service_package_set = $self->get_hypermouse_schema
            ->resultset('ServicePackageSet')
            ->search(
                { -and          => $service_package_set_criterions },
                {
                    join        => 'service_package',
                    group_by    => 'service_package_id'
                }
            )
            ->single
            // return(undef);

        my $service_package = $service_package_set->service_package
            // return(undef);

        # OK, the package is detected!

        $self->get_resources->{ $cloudstack_element_key }->{'service_package_id'} = $service_package->id;

        foreach ($service_package->service_package_sets->all) {
            $self->get_resources->{ $cloudstack_element_key }->{'resource_counter'}->add_resources(
                { $_->resource_type_id => $_->quantity },
                $from_datetime,
                $till_datetime
            );
        }

    }

    my @candidates = values(%{ $self->get_resources });
    CANDIDATE:
    for(my $i = 0; $i < scalar(@candidates); $i++) {
        while(my($resource_type_id, $quantity) = each(%{ $resources })) {
            $service_package_id = undef;
            foreach my $period ($candidates[$i]->{'resource_counter'}->find_periods($from_datetime, $till_datetime, 0)) {
                $service_package_id = undef;
                # What is available in this time period?
                my $available = $candidates[$i]->{'resource_counter'}->get_resources($period->[0], $period->[1], 1);
                # Are there any service packages available in this time period?
                if(
                    (defined($available))                                                           &&
                    (defined($available->{ $resource_type_id }))                                    &&
                          ((($resources->{ $resource_type_id } -= $available->{ $resource_type_id }) <= 0) || $exceed)
                ) {
                    $service_package_id = $candidates[$i]->{'service_package_id'}
                }
            }
            next(CANDIDATE) unless($service_package_id);
            $candidates[$i]->{'resource_counter'}->sub_resources(
                { $resource_type_id => $quantity },
                $from_datetime,
                $till_datetime
            );
        }
    }

    return($service_package_id);

}

method compose_element_key (
    Str $cloudstack_element_type!,
    Str $cloudstack_element_id!
) {
    return(sprintf('%s:%s', $cloudstack_element_type, $cloudstack_element_id));
}

method renew_if_needed (
    Str $cloudstack_element_type!,
    Str $cloudstack_element_id!,
) {
    my $cache                   = $self->get_cache;
    my $cloudstack_api          = $self->get_cloudstack_api;
    my $cloudstack_element_key  = $self->compose_element_key($cloudstack_element_type, $cloudstack_element_id);
    my $cloudstack_element_dom  = $cache->get($cloudstack_element_key);
    unless(defined($cloudstack_element_dom)) {
        $cloudstack_element_dom = ($cloudstack_api->perform_action(
            action          => 'list',
            type            => $cloudstack_element_type,
            parameters      => { filter_by_id => $cloudstack_element_id, all => 1 },
            requested       => { element => 'dom' }
        ))[$[];
        $cache->set($cloudstack_element_key, $cloudstack_element_dom, 86400);
    }
    return($cloudstack_element_dom);
}



__PACKAGE__->meta->make_immutable;

1;

