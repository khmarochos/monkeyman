package MaitreDNuage::Controller::ServiceAgreement;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use MonkeyMan::Exception qw(PersonNotFound);

use Switch;
use Method::Signatures;
use TryCatch;



method list {
    my @service_agreements;
    my $person  = $self->stash->{'authorized_person_result'};
    my $valid   = 7;
    switch($self->stash->{'filter'}) {
        case('all')         { $valid = 5 }
        case('active')      { $valid = 7 }
        case('archived')    { $valid = 12 }
    }

    foreach my $contractor (
        $person
            ->contractors
                ->filter_valid(source_alias => 'me')
                    ->filter_permitted(source_alias => 'me')
                        ->filter_valid(source_alias => 'contractor', mask => 6)
    ) {
        if($contractor->provider) {
            push(@service_agreements, $contractor->service_agreement_provider_contractors->filter_valid(mask => $valid));
        } else {
            push(@service_agreements, $contractor->service_agreement_client_contractors->filter_valid(mask => $valid));
        }
    }

    foreach my $service_agreement (
        $person
            ->service_agreements
                ->filter_valid(source_alias => 'me')
                    ->filter_permitted(source_alias => 'me')
                        ->filter_valid(source_alias => 'service_agreement', mask => $valid)
        ) {
            push(@service_agreements, $service_agreement);
    }

    $self->stash('service_agreements' => \@service_agreements);
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
