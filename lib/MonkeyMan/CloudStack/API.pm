package MonkeyMan::CloudStack::API;

# Use pragmas
use strict;
use warnings;

# Use my own modules (supposing we know where to find them)
use MonkeyMan::Constants qw(:ALL);
use MonkeyMan::Utils;
use MonkeyMan::Exception;

# Use 3rd party libraries
use TryCatch;
use URI::Encode qw(uri_encode uri_decode);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;
use LWP::UserAgent;
use XML::LibXML;
use POSIX qw(strftime);

# Use Moose :)
use Moose;
use MooseX::UndefTolerant;
use namespace::autoclean;



has 'cs' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack',
    predicate   => 'has_cs',
    writer      => '_set_cs',
    required    => 'yes'
);
has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    writer      => '_set_configuration',
    predicate   => 'has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);



sub _build_configuration {

    my $self = shift;

    $self->cs->configuration->{'api'};

}



sub craft_url {

    my($self, %parameters) = @_;
    my($configuration);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'configuration' => { variable => \$configuration },
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    my $parameters_string;
    my $output;
    $parameters{'apiKey'} = $configuration->{'api_key'};
    foreach my $parameter (sort(keys(%parameters))) {
        $parameters_string  .= (defined($parameters_string) ? '&' : '') . $parameter . '=' .            $parameters{$parameter};
        $output             .= (defined($output)            ? '&' : '') . $parameter . '=' . uri_encode($parameters{$parameter}, 1);
    }
    my $base64_encoded  = encode_base64(hmac_sha1(lc($output), $configuration->{'secret_key'})); chomp($base64_encoded);
    my $url             = $configuration->{'api_address'} . '?' . $parameters_string . "&signature=" . uri_encode($base64_encoded, 1);

    return($url);

}



sub run_command {

    my($self, %input) = @_;
    my($log, $configuration);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'               => { variable => \$log },
                'configuration'     => { variable => \$configuration },
                '$parameters'       => {
                    value               => $input{'parameters'},
                    isaref              => 'HASH'
                }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    } 

    # Crafting the URL

    my $url = defined($input{'url'}) ? $input{'url'} : $self->craft_url(%{ $input{'parameters'} });
    MonkeyMan::Exception->throw("The requested URL is invalid")
        unless(index($url, $configuration->{'api_address'}) == 0);

    # Running the command

    $log->trace(mm_sprintf(             "Querying CloudStack for %s", defined($input{'url'}) ? $url : $input{'parameters'}));
    $log->trace(mm_sprintf("[CLOUDSTACK] Querying CloudStack for %s", defined($input{'url'}) ? $url : $input{'parameters'}));

    my $ua = LWP::UserAgent->new(
        agent       => "MonkeyMan-" . MM_VERSION . " (libwww-perl/#.###)",
        ssl_opts    => { verify_hostname => 0 } #FIXME#
    );

    my $response = $ua->get($url);
    $log->trace(mm_sprintf("[CLOUDSTACK] Got an HTTP-response: %s", $response->status_line));
    MonkeyMan::Exception->throw_f("Can't %s->get(): %s", $ua, $response->status_line)
        unless($response->is_success);

    # Parsing the response
 
    my $parser  = XML::LibXML->new();
    my $dom;
    try {
        $dom = $parser->load_xml(
            string => ($response->content)
        );
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't %s->load_xml(): %s", $parser, $e);
    }

    $log->trace(mm_sprintf("CloudStack returned %s", $dom));
    $log->trace(mm_sprintf("[CLOUDSTACK] [XML] %s contains:\n%s", $dom, $dom->toString(1)));

    # Should we wait for an async job?

    my $jobid;
    try {
        $dom->findvalue('/*/jobid');
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't %s->findValue(): %s", $dom, $e)
    }

    if(defined($input{'options'}->{'wait'}) && ($jobid)) {
 
        my $alarm = time + $input{'options'}->{'wait'};

        $log->debug(mm_sprintf(
            "Waiting till %s for a responce concerning the job %s",
                strftime(MM_DATE_TIME_FORMAT, localtime($alarm)),
                $jobid
        ));

        my $time_to_sleep = defined($self->cs->mm->configuration->{'time'}->{'sleep_while_waiting'}) ?
            $self->cs->mm->configuration->{'time'}->{'sleep_while_waiting'} :
            MM_SLEEP_WHILE_WAITING_FOR_ASYNC_JOB_RESULT;

        while($time_to_sleep) {

            $dom = $self->run_command(
                parameters => {
                    command => 'queryAsyncJobResult',
                    jobid   => $jobid
                }
            );

            if($input{'options'}->{'wait'} && (time >= $alarm)) {
                $log->warn(mm_sprintf(
                    "A timeout of %d seconds has occured while waiting for %s to be completed",
                        $input{'options'}->{'wait'},
                        $jobid
                ));
                return($dom);
            }

            return($dom)
                if($dom->findvalue('/*/jobstatus'));

        }

    }

    return($dom);

}



sub query_xpath {

    my($self, $dom, $xpath, $results_to) = @_;
    my($log);

    try {
        mm_check_method_invocation(
            'object' => $self,
            'checks' => {
                'log'           => { variable   => \$log },
                '$dom'          => { value      =>  $dom,           error       => "The DOM hasn't been defined" }
#               '$xpath'        => { value      =>  $xpath,         careless    => 1 },
#               '$results_to'   => { value      =>  $results_to,    careless    => 1 }
            }
        );
    } catch(MonkeyMan::Exception $e) {
        $e->throw;
    } catch($e) {
        MonkeyMan::Exception->throw_f("Can't mm_check_method_invocation(): %s", $e);
    }

    # First of all, let's find out what they've passed to us - a list or a string

    my $queries = [];
    my $results = defined($results_to) ? $results_to : [];

    if(ref($xpath) eq 'ARRAY') {
        $queries = $xpath;
    } else {
        push(@{ $queries }, $xpath);
    }

    foreach my $query (@{ $queries }) {

        $log->trace(mm_sprintf("Querying %s for %s", $dom, $query));
        $log->trace(mm_sprintf("[XML] %s (queried for %s) contains:\n%s", $dom, $query, $dom->toString(1)));

        my @nodes;
        try {
            @nodes = $dom->findnodes($query);
        } catch($e) {
            MonkeyMan::Exception->throw_f("Can't %s->findnodes(): %s", $dom, $e);
        }

        foreach my $node (@nodes) {
            $log->trace(mm_sprintf("[XML] %s (the %d'st result) contains:\n%s", $node, scalar(@{ $results }), $node->toString(1)));
            push(@{$results}, $node);
        }

        $log->trace(mm_sprintf("Have found %d elements in %s", scalar(@nodes), $dom));

    }

    return($results);

}



__PACKAGE__->meta->make_immutable;

1;

