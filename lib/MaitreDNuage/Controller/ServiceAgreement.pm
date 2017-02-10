package MaitreDNuage::Controller::ServiceAgreement;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use MonkeyMan::Exception qw(PersonNotFound);

use Method::Signatures;
use TryCatch;



method list {
    my $person = $self->stash->{'authorized_person_result'};

    my @service_agreements;

    foreach my $contractor (
        $person
            ->contractors
                ->filter_valid(source_alias => 'me')
                    ->filter_valid(source_alias => 'contractor')
    ) {
        if($contractor->provider) {
            push(@service_agreements, $contractor->service_agreement_provider_contractors->filter_valid);
        } else {
            push(@service_agreements, $contractor->service_agreement_client_contractors->filter_valid);
        }
    }

    foreach my $service_agreement (
        $person
            ->service_agreements
                ->filter_valid(source_alias => 'me')
                    ->search(
                        -or => [
                            -not => { 'me.admin'    => 0 },
                            -not => { 'me.billing'  => 0 },
                            -not => { 'me.tech' => 0 }
                        ]
                    )
                        ->filter_valid(source_alias => 'service_agreement')
        ) {
            push(@service_agreements, $service_agreement);
    }

    $self->stash('service_agreements' => \@service_agreements);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
