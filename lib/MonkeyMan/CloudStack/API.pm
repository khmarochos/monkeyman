package MonkeyMan::CloudStack::API;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Params::Validate;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::Essentials';
with 'MonkeyMan::Roles::Timerable';

use MonkeyMan::Constants qw(:cloudstack);
use MonkeyMan::Utils;
use MonkeyMan::CloudStack::API::Command;

use URI::Encode qw(uri_encode uri_decode);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;
use XML::LibXML;



mm_register_exceptions qw(
    NoParameters
    Timeout
    Timeout
);



has useragent_signature => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>    'get_useragent_signature',
    writer      =>   '_set_useragent_signature',
    predicate   =>    'has_useragent_signature',
    builder     => '_build_useragent_signature',
    lazy        => 1
);

sub _build_useragent_signature {

    my $self = shift;
    my $monkeyman = $self->get_cloudstack->get_monkeyman;

    return(sprintf(
        "%s-%s (powered by MonkeyMan-%s) (libwww-perl/#.###)",
            $monkeyman->get_app_name,
            $monkeyman->get_app_version,
            $monkeyman->get_mm_version
    ));
}



has useragent => (
    is          => 'ro',
    isa         => 'LWP::UserAgent',
    reader      =>    'get_useragent',
    writer      =>   '_set_useragent',
    predicate   =>    'has_useragent',
    builder     => '_build_useragent',
);

sub _build_useragent {

    my $self = shift;

    return(LWP::UserAgent->new(
        agent       => $self->get_useragent_signature,
        ssl_opts    => { verify_hostname => 0 } #FIXME 20151219
    ));

}




sub test {

    my $self = shift;

    $self->run_command(
        parameters  => {
            command     => 'listApis'
        },
        options     => {
            wait        => 0,
            fatal_empty => 1,
            fatal_fail  => 1,
        }
    );

}



sub run_command {

    my($self, %input) = validated_hash(
        \@_,
        command     => { optional => 1, isa => 'MonkeyMan::CloudStack::API::Command' },
        parameters  => { optional => 1, isa => 'HashRef' },
        url         => { optional => 1, isa => 'String' },
        options     => { optional => 1, isa => 'HashRef' }
    );
    my $cloudstack      = $self->get_cloudstack;
    my $logger          = $cloudstack->get_monkeyman->get_logger;
    my $configuration   = $cloudstack->get_configuration->get_tree->{'api'};

    my $command;

    if(defined($input{'command'})) {
        $logger->tracef("The %s API-command is given to be run",
            $input{'command'}
        );
        $command = $input{'command'};
    }

    if(defined($input{'url'})) {
        $logger->tracef("The %s URL is given to be run as a command",
            $input{'url'}
        );
        unless(defined($command)) {
            $command = MonkeyMan::CloudStack::API::Command->new(
                api         => $self,
                url         => $input{'url'}
            );
        } else {
            $logger->warnf(
                "The %s API-command is already present, " .
                "the %s URL will be ignored",
                    $command, \{$input{'url'}}
            );
        }
    }

    if(defined($input{'parameters'})) {
        $logger->tracef("The %s set of parameters is given to be run as a command",
            $input{'parameters'}
        );
        unless(defined($command)) {
            $command = MonkeyMan::CloudStack::API::Command->new(
                api         => $self,
                parameters  => $input{'parameters'}
            );
        } else {
            $logger->warnf(
                "The %s API-command is already present, " .
                "the %s set of parameters will be ignored",
                    $command, \{$input{'url'}}
            );
        }
    }

    unless(defined($command)) {
        MonkeyMan::CloudStack::API::Exception::NoParameters->throw(
            "Neither parameters, command nor URL are given"
        );
    }

    my $job_run = ${$self->get_time_current}[0];
    my $result  = $command->run(%{$input{'options'}});
    my $dom     = $self->get_dom($result);

    if(my $jobid = $dom->findvalue('/*/jobid')) {

        $logger->tracef("We've got an asynchronous job, the job ID is: %s", $jobid);

        if(my $wait = $input{'options'}->{'wait'}) {

            $wait = ($wait > 0) ?
                $wait :
                defined($configuration->{'wait'}) ?
                        $configuration->{'wait'} :
                        MM_CLOUDSTACK_API_WAIT_FOR_FINISH;

            $logger->tracef(
                "We'll wait %d seconds for the result of the %s job",
                    $wait,
                    $jobid
            );

            while() {

                my $job_result = $self->check_job($jobid);

                if($job_result->findvalue('/*/jobstatus') ne '0') {
                    $logger->tracef("The job %s is finished", $jobid);
                    $dom = $job_result;
                    last;
                }

                if(
                    ($wait > 0) &&
                    ($wait + $job_run <= ${$self->get_time_current}[0])
                ) {
                    MonkeyMan::CloudStack::API::Exception::Timeout->throwf(
                        "We can't wait for the %s job to finish anymore: " .
                        "%d seconds have passed, which is more than %d",
                            $jobid,
                            ${$self->get_time_current}[0] - $job_run,
                            $wait
                    );
                }

                sleep(
                    defined($configuration->{'sleep'}) ?
                            $configuration->{'sleep'} :
                            MM_CLOUDSTACK_API_SLEEP
                );

            }

        } else {

            $logger->tracef("We won't wait for the result of the %s job", $jobid);

        }
    }

    return($dom);

}



sub get_dom {

    my $self    = shift;
    my $xml     = shift;

    my $dom = XML::LibXML->new->load_xml(string => $xml);

    $self->get_cloudstack->get_monkeyman->get_logger->tracef(
        "The DOM has been loaded: %s", $dom
    );

    return($dom);

}



sub check_job {

    my $self    = shift;
    my $jobid   = shift;

    $self->run_command(
        parameters  => {
            command     => 'queryAsyncJobResult',
            jobid       => $jobid
        },
        options => {
            wait        => 0,
            fatal_fail  => 1,
            fatai_empty => 1
        }
    );

}



__PACKAGE__->meta->make_immutable;

1;



=head1 NAME

MonkeyMan::CloudStack::API - Apache CloudStack API class

=head1 SYNOPSIS

    my $api = MonkeyMan::CloudStack::API->new(
        monkeyman   => $monkeyman
    );

    my $result = $api->run_command(
        parameters  => {
            command     => 'login',
            username    => 'admin',
            password    => '1z@Lo0pA3',
            domain      => 'ZALOOPA'
        },
        options     => {
            wait        => 0,
            fatal_empty => 1,
            fatal_fail  => 1,
        }
    );

=head1 DESCRIPTION

The C<MonkeyMan::CloudStack::API> class encapsulates the interface to the
Apache CloudStack.

=cut

