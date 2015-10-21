package MonkeyMan::CloudStack::API;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::Essentials';

use URI::Encode qw(uri_encode uri_decode);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;


sub craft_url {

    my $self            = shift;
    my %parameters      = @_;
    my $logger          = $self->cs->mm->logger;
    my $configuration   = $self->cs->configuration->tree->{'api'};

    my $parameters_string;
    my $output;

    $logger->tracef("Crafting an URL based on the following set of parameters: %s",
        \%parameters
    );

    $parameters{'apiKey'} = $configuration->{'api_key'};

    my @pairs_encoded;
    my @parameters = sort(keys(%parameters));
    while(my $parameter = shift(@parameters)) {
        $logger->tracef('... encoding the "%s" parameter ("%s")',
            $parameter,
            $parameters{$parameter}
        );
        push(@pairs_encoded,
            uri_encode($parameter) . '=' . uri_encode($parameters{$parameter}, 1)
        );
        if(($parameter ne 'signature') && (0 == @parameters)) {
            $logger->tracef("... have got all the parameters: %s", \@pairs_encoded);
            $logger->tracef("... adding the signature");
            $parameters{'signature'} =
                encode_base64(
                    hmac_sha1(lc(join('&', @pairs_encoded)),
                    $configuration->{'secret_key'})
                );
            chomp($parameters{'signature'});
            unshift(@parameters, 'signature');
        }
    }
    my $url = $configuration->{'api_address'} . '?' . join('&', @pairs_encoded);

    $logger->tracef("Crafted: %s", $url);

    return($url);

}



sub run_command {

}


__PACKAGE__->meta->make_immutable;

1;
