#! /usr/bin/env perl

use strict;
use warnings;

use utf8;
use open ':std', ':encoding(UTF-8)';
use HyperMouse::Schema;



my $schema = HyperMouse::Schema->connect('dbi:mysql:hypermouse', 'hypermouse', 'WTXFa2G1uN3cpwMP', { mysql_enable_utf8 => 1 });

foreach my $provider ($schema->resultset('Contractor')->search({ provider => 1 })) {
    printf("Provider: %s %s\n", $provider->search_related('contractor_type')->first->search_related('contractor_type_names', { language_id => 2 })->first->name_short, $provider->name);
    foreach my $service_agreement ($schema->resultset('ServiceAgreement')->search({ provider_contractor_id => $provider->id })) {
        my $client = $schema->resultset('Contractor')->search({ id => $service_agreement->client_contractor_id })->first;
        printf(" ` Contract: %s - %s %s\n", $service_agreement->name, $client->search_related('contractor_type')->first->search_related('contractor_type_names', { language_id => 2 })->first->name_short, $client->name);
        foreach my $service_obligation ($schema->resultset('ServiceObligation')->search({ service_agreement_id => $service_agreement->id })) {
            my $service = $service_obligation->search_related('service')->first;
            printf(" ` ` Service: %s - %s\n", $service->id, $service->search_related('service_names', { language_id => 2 })->first->value);
        }
    }
}
