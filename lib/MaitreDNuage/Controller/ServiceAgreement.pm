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

    foreach my $contractor ($person->contractors->filter_valid(source_alias => 'me')->filter_valid(source_alias => 'contractor')) {
        if($contractor->provider) {
            push(@service_agreements, $contractor->service_agreement_provider_contractors->filter_valid);
        } else {
            push(@service_agreements, $contractor->service_agreement_client_contractors->filter_valid);
        }
    }

    $self->stash('service_agreements' => \@service_agreements);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
