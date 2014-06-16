package MonkeyMan::CloudStack::API;

=pod

=head1 NAME

MonkeyMan::CloudStack::API - a module for accessing CloudStack's API

=head1 SYNOPSIS

use MonkeyMan::CloudStack::API;

$api = MonkeyMan::CloudStack::API->new(
    mm => $mm
);

$url = $api->craft_url(
    command     => 'destroyEverythingYouCanReach',
    sure        => 1
);

$dom = $api->run_command(
    url         => 'https://localhost:13666/?fuck=off',
    parameters  => {
        command     => 'makeEverythingGood',
        world       => $this_world,
        people      => @these_people
    },
    options     => {
        wait        => 13
    }
);

=cut

use strict;
use warnings;

use MonkeyMan::Constants;

use URI::Encode qw(uri_encode uri_decode);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;
use WWW::Mechanize;
use XML::LibXML;
use POSIX qw(strftime);

use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;

with 'MonkeyMan::ErrorHandling';



has 'mm' => (
    is          => 'ro',
    isa         => 'MonkeyMan',
    predicate   => 'has_mm',
    writer      => '_set_mm',
    required    => 'yes'
);



sub BUILD {

    my $self = shift;

    $self->mm->logger->trace("CloudStack's API connector has been initialized");

}



sub craft_url {

    my($self, %parameters) = @_;

    my $mm  = $self->mm;
    my $log = $mm->logger;

    my $parameters_string;
    my $output;
    $parameters{'apiKey'} = $mm->configuration('cloudstack::api_key');
    foreach my $parameter (sort(keys(%parameters))) {
        $parameters_string  .= (defined($parameters_string) ? '&' : '') . $parameter . '=' .            $parameters{$parameter};
        $output             .= (defined($output)            ? '&' : '') . $parameter . '=' . uri_encode($parameters{$parameter}, 1);
    }
    my $base64_encoded  = encode_base64(hmac_sha1(lc($output), $mm->configuration('cloudstack::secret_key'))); chomp($base64_encoded);
    my $url             = $mm->configuration('cloudstack::api_address') . '?' . $parameters_string . "&signature=" . uri_encode($base64_encoded, 1);

    return($url);

}



sub run_command {

    my($self, %input) = @_;

    my $mm  = $self->mm;
    my $log = $mm->logger;

    return($self->error("Required parametrs haven't been defined")) unless(ref($input{'parameters'}));

    # Crafting the URL

    my $url = defined($input{'url'}) ?
        defined($input{'url'}) :
        $self->craft_url(%{ $input{'parameters'} });
    return($self->error($self->error_message))
        unless(defined($url));
    return($self->error("The requested URL is invalid"))
        unless(index($url, $mm->configuration('cloudstack::api_address')) == 0);

    # Running the command

    $log->trace(">MM>CS> - querying CloudStack by $url");

    # FIXME - what about to use LWP::UserAgent here?
    my $mech = WWW::Mechanize->new(
        onerror => undef
    );
    my $response = $mech->get($url);
    return($self->error('Can\'t WWW::Mechanize->get(): ' . $response->status_line)) unless($response->is_success);

    $log->trace('Got an HTTP-response: "' . $response->status_line . '"');

    # Parsing the response
 
    my $parser  = XML::LibXML->new();
    my $dom     = eval {
        $parser->load_xml(
            string => ($response->content)
        );
    };
    return($self->error("Can't XML::LibXML->load_xml(): $@")) unless(defined($dom));

    $log->trace("<MM<CS< - have got data from CloudStack as $dom:\n" . $dom->toString(1));

    # Should we wait for an async job?

    if(defined($input{'options'}->{'wait'}) && ($dom->findvalue('/*/jobid'))) {
 
        my $alarm = time + $input{'options'}->{'wait'};

        $log->debug(
            "Waiting till " . strftime(MMDateTimeFormat, localtime($alarm)) . " " .
            "for a responce concerning the job " . $dom->findvalue('/*/jobid')
        );

        while(sleep(
            $mm->configuration('time::sleep_while_waiting') ?
                $mm->configuration('time::sleep_while_waiting') :
                MMSleepWhileWaitingForAsyncJobResult
        )) {

            $dom = $self->run_command(
                parameters => {
                    command => 'queryAsyncJobResult',
                    jobid   => $dom->findvalue('/*/jobid')
                }
            );
            return($self->error($self->error_message))
                unless(defined($dom));

            if($input{'options'}->{'wait'} && (time >= $alarm)) {
                $log->info("A timeout of $input{'options'}->{'wait'} seconds has occured");
                return($dom);
            }

            return($dom)
                if($dom->findvalue('/*/jobstatus'));

        }

    }

    return($dom);

}



sub query_xpath {

    my ($self, $dom, $xpath) = @_;

    my $mm  = $self->mm;
    my $log = $mm->logger;

    return($self->error("DOM isn't defined")) unless(defined($dom));

    # First of all, let's find out what they've passed to us - a list or a string

    my $queries = [];
    my @results;

    if(ref($xpath) eq 'ARRAY') {
        $queries = $xpath;
    } else {
        push(@{ $queries }, $xpath);
    }

    foreach my $query (@{ $queries }) {

        $log->trace("Querying $dom for $query");

        my @nodes = eval { $dom->findnodes($query); };
        return($self->error("Can't XML::LibXML::Node::findnodes(): $@")) if($@);

        foreach my $node (@nodes) {
            $log->trace("Have got $node");
            push(@results, $node);
        }

    }

    return(@results);

}



sub DEMOLISH {

    my $self = shift;

    $self->mm->logger->trace("CloudStack's API connector is being demolished");

}



__PACKAGE__->meta->make_immutable;

1;

