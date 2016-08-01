package MonkeyMan::Zendesk::API;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Zendesk::Essentials';
with 'MonkeyMan::Roles::WithTimer';

use MonkeyMan::Utils;
use MonkeyMan::Exception qw(BadResponse);

use Method::Signatures;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request;
use JSON;



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>   '_has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {

    return($self->get_zendesk->get_configuration->{'api'});

}



has useragent => (
    is          => 'ro',
    isa         => 'Object',
    reader      =>    'get_useragent',
    writer      =>   '_set_useragent',
    predicate   =>    'has_useragent',
    builder     => '_build_useragent',
    lazy        => 1
);

method _build_useragent {

    return(LWP::UserAgent->new(
        agent       => $self->get_useragent_signature,
        ssl_opts    => { verify_hostname => 0 } #FIXME 20151219
    ));

}



has useragent_signature => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_useragent_signature',
    writer      =>    'set_useragent_signature',
    predicate   =>    'has_useragent_signature',
    builder     => '_build_useragent_signature',
    lazy        => 1
);

method _build_useragent_signature {

    my $useragent_signature =
        $self->get_configuration->{'useragent_signature'};

    unless(defined($useragent_signature)) {
        my $monkeyman = $self->get_zendesk->get_monkeyman;
        $useragent_signature = sprintf(
            "%s-%s (powered by MonkeyMan-%s) (libwww-perl/#.###)",
                $monkeyman->get_app_name,
                $monkeyman->get_app_version,
                $monkeyman->get_mm_version
        );
    }

    return($useragent_signature);

}



has url_prefix => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_url_prefix',
    writer      =>   '_set_url_prefix',
    predicate   =>   '_has_url_prefix',
    builder     => '_build_url_prefix',
    lazy        => 1
);

method _build_url_prefix {

    return($self->get_configuration->{'url_prefix'});

}



has auth_email => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_auth_email',
    writer      =>   '_set_auth_email',
    predicate   =>   '_has_auth_email',
    builder     => '_build_auth_email',
    lazy        => 1
);

method _build_auth_email {

    return($self->get_configuration->{'auth_email'});

}



has auth_password => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_auth_password',
    writer      =>   '_set_auth_password',
    predicate   =>   '_has_auth_password',
    builder     => '_build_auth_password',
    lazy        => 1
);

method _build_auth_password {

    return($self->get_configuration->{'auth_password'});

}



method run_command(
    Str             :$command!,
    Str             :$method!,
    Maybe[HashRef]  :$parameters    = {},
    Maybe[Bool]     :$fatal         = 1,
    Maybe[Str]      :$url_prefix    = $self->get_url_prefix,
    Maybe[Str]      :$auth_email    = $self->get_auth_email,
    Maybe[Str]      :$auth_password = $self->get_auth_password
) {

    my $logger = $self->get_zendesk->get_monkeyman->get_logger;

    my $auth_credentials = encode_base64($auth_email . ':' . $auth_password);
    my $request_url =
            $url_prefix .
          (($url_prefix !~ qr(/$) && $command !~ qr(^/)) ? '/' : '') .
            $command;
    my $request_content = encode_json($parameters);
    my $request_header  = HTTP::Headers->new(
        'Authorization'     => 'Basic ' . $auth_credentials,
        'Content-Type'      => 'application/json'
    );
    my $request         = HTTP::Request->new($method, $request_url, $request_header, $request_content);

    $logger->tracef("Calling Zendesk, the HTTP request is at %s", $request);

    my $response = $self->get_useragent->request($request);

    $logger->tracef(
        "Have got a response: the HTTP-code is %s, the content is at %s",
        $response->status_line,
       \$response->content
    );

    my $result;

    if($response->is_success) {
        $result = decode_json($response->content);
    } else {
        $result = {};
        my $message = mm_sprintf("The command has failed to run: %s", $response->status_line);
        if($fatal) {
            (__PACKAGE__ . '::Exception::BadResponse')->throw($message);
        } else {
            $logger->warn($message);
        }
    }

    return($result);

}




1;
