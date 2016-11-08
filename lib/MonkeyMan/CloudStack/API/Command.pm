package MonkeyMan::CloudStack::API::Command;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::API::Essentials';
with 'MonkeyMan::Roles::WithTimer';

use MonkeyMan::Exception qw(BadResponse);

use Method::Signatures;
use URI::Encode qw(uri_encode uri_decode);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;
use HTTP::Request;
use LWP::UserAgent;



has parameters => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_parameters',
    writer      =>   '_set_parameters',
    predicate   =>    'has_parameters',
    builder     => '_build_parameters',
    lazy        => 1
);

method _build_parameters(...) {

    return({});

}



has url => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_url',
    writer      =>   '_set_url',
    predicate   =>    'has_url',
    builder     => '_build_url',
    lazy        => 1
);

method _build_url {
    
    unless($self->has_parameters) {
        MonkeyMan::Exception->throw("The command isn't defined");
    }

    $self->_set_url($self->craft_url(%{$self->get_parameters}));

}

method craft_url(...) {

    my %parameters      = @_;
    my $logger          = $self->get_api->get_cloudstack->_get_logger;
    my $configuration   = $self->get_api->get_configuration;

    my $parameters_string;
    my $output;

    $logger->tracef("Crafting the URL based on the following set of parameters: %s",
        \%parameters
    );

    $parameters{'apiKey'} = $configuration->{'api_key'};

    my @pairs_encoded;
    my @parameters = sort(keys(%parameters));
    while(my $parameter = shift(@parameters)) {
        $logger->tracef(' ... encoding the "%s" parameter (%s)',
            $parameter,
            \$parameters{$parameter}
        );
        push(@pairs_encoded,
            uri_encode($parameter) . '=' . uri_encode($parameters{$parameter}, 1)
        );
        if(($parameter ne 'signature') && (0 == @parameters)) {
            $logger->tracef(" ... have got all the parameters: %s", \@pairs_encoded);
            $logger->tracef(" ... adding the signature");
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

    $logger->tracef("Crafted: %s", \$url);

    return($url);

}



has http_request => (
    is          => 'rw',
    isa         => 'HTTP::Request',
    reader      =>    'get_http_request',
    writer      =>   '_set_http_request',
    predicate   =>    'has_http_request',
    builder     => '_build_http_request',
    lazy        => 1
);

has http_response => (
    is          => 'rw',
    isa         => 'HTTP::Response',
    reader      =>    'get_http_response',
    writer      =>   '_set_http_response',
    predicate   =>    'has_http_response',
    lazy        => 0
);

method run(
    Bool        :$return_as_dom = 0, # FIXME: Make it work
    Maybe[Bool] :$fatal_fail    = 1,
    Maybe[Bool] :$fatal_empty   = 0,
    Maybe[Bool] :$fatal_431     =
        ! $self->get_api->get_configuration->{'ignore_431_code'}
) {

    my $logger = $self->get_api->get_cloudstack->_get_logger;

    $logger->tracef("Running the %s command", $self);

    unless(defined($self->get_url)) {
        MonkeyMan::Exception->throw(
            "Can't run the command: " .
            "neither the URL nor the parameters set are defined"
        );
    }

    # Prepating the HTTP-request
    $self->_set_http_request(HTTP::Request->new(GET => $self->get_url));
    $logger->tracef(" --> The following request will be sent: %s",
        $self->get_http_request
    );

    # Sending the HTTP-request and putting the result to
    # the http_response attribute
    $self->_set_http_response(
        $self->get_api->get_useragent->request(
            $self->get_http_request
        )
    );
    $logger->tracef(" <-- The server's response is: %s (contents %s)",
        $self->get_http_response->status_line,
       \$self->get_http_response->as_string,
    );

    # Is everything fine?
    if(! $self->get_http_response->is_success) {
        if($fatal_fail) {
            if($self->get_http_response->code eq 431 && ! $fatal_431) {
                $logger->warnf(
                    "Have got the 431 reply from the API server " . 
                    "in reply to the %s command",
                    $self
                );
            } else {
                (__PACKAGE__ . '::Exception::BadResponse')->throwf(
                    "The command has failed to run: %s",
                        $self->get_http_response->status_line
                );
            }
        } else {
            $logger->warnf("The command has failed to run: %s",
                $self->get_http_response->status_line
            );
        }
    }

    $logger->tracef(" <-- The response content has been got: %s",
        \$self->get_http_response->content
    );

    return($self->get_http_response->content);

}



__PACKAGE__->meta->make_immutable;

1;
