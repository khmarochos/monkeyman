package MonkeyMan::CloudStack::API;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::CloudStack::Essentials';
with 'MonkeyMan::Roles::WithTimer';

use MonkeyMan::Constants qw(:cloudstack);
use MonkeyMan::Utils;
use MonkeyMan::Exception;
use MonkeyMan::CloudStack::API::Configuration;
use MonkeyMan::CloudStack::API::Command;

use TryCatch;
use Method::Signatures;
use Module::Loaded;
use Lingua::EN::Inflect qw(A PL);
use URI::Encode qw(uri_encode uri_decode);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;
use XML::LibXML;



mm_register_exceptions qw(
    CantLoadPackage
    InvalidParametersValue
    NoParameters
    Timeout
);



#
# Attributes and methods responsible for the configuration set
#

has 'configuration_tree' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_configuration_tree',
    predicate   =>    'has_configuration_tree',
    writer      =>   '_set_configuration_tree',
    builder     => '_build_configuration_tree'
);

method _build_configuration_tree {
    return($self->get_cloudstack->get_configuration->get_tree);
}

has 'configuration' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API::Configuration',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>    'has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {

    MonkeyMan::CloudStack::API::Configuration::->new(
        api     => $self,
        tree    => $self->get_configuration_tree
    );

}



#
# Attributes and methods responsible for the useragent
#

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
        $self->get_configuration->get_tree->{'useragent_signature'};

    unless(defined($useragent_signature)) {
        my $monkeyman = $self->get_cloudstack->get_monkeyman;
        $useragent_signature = sprintf(
            "%s-%s (powered by MonkeyMan-%s) (libwww-perl/#.###)",
                $monkeyman->get_app_name,
                $monkeyman->get_app_version,
                $monkeyman->get_mm_version
        );
    }

    return($useragent_signature)
}

has useragent => (
    is          => 'ro',
    isa         => 'Object',
    reader      =>    'get_useragent',
    writer      =>   '_set_useragent',
    predicate   =>    'has_useragent',
    builder     => '_build_useragent',
);

method _build_useragent {

    return(LWP::UserAgent->new(
        agent       => $self->get_useragent_signature,
        ssl_opts    => { verify_hostname => 0 } #FIXME 20151219
    ));

}



#
# Attributes and methods responsible for caching
#

has cache => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::API::Cache',
    reader      =>    'get_cache',
    writer      =>   '_set_cache',
    predicate   =>    'has_cache',
    builder     => '_build_cache',
    lazy        => 1
);

method _build_cache {
    return(MonkeyMan::CloudStack::API::Cache->new(
        api         => $self
    ));
}



method test {

    $self->run_command(
        parameters  => {
            command     => 'listApis'
        },
        wait        => 0,
        fatal_empty => 1,
        fatal_fail  => 1,
        fatal_431   => 1
    );

}



method run_command(
    MonkeyMan::CloudStack::API::Command :$command,
    HashRef :$parameters,
    Str     :$url,
    Bool    :$wait          = 0,
    Bool    :$fatal_empty   = 0,
    Bool    :$fatal_fail    = 1,
    Bool    :$fatal_431
) {

    my $cloudstack      = $self->get_cloudstack;
    my $logger          = $cloudstack->get_monkeyman->get_logger;
    my $configuration   = $cloudstack->get_configuration->get_tree->{'api'};

    my $command_to_run;

    if(defined($command)) {
        $logger->tracef("The %s API-command is given to be run", $command);
        $command_to_run = $command;
    }

    if(defined($url)) {
        $logger->tracef("The %s URL is given to be run as a command", $url);
        unless(defined($command_to_run)) {
            $command_to_run = MonkeyMan::CloudStack::API::Command->new(
                api => $self,
                url => $url
            );
        } else {
            $logger->warnf(
                "The %s API-command is already present, " .
                "the %s URL will be ignored",
                    $command_to_run, \$url
            );
        }
    }

    if(defined($parameters)) {
        $logger->tracef("The %s set of parameters is given to be run as a command",
            $parameters
        );
        unless(defined($command_to_run)) {
            $command_to_run = MonkeyMan::CloudStack::API::Command->new(
                api         => $self,
                parameters  => $parameters
            );
        } else {
            $logger->warnf(
                "The %s API-command is already present, " .
                "the %s set of parameters will be ignored",
                    $command_to_run, $parameters
            );
        }
    }

    unless(defined($command_to_run)) {
        (__PACKAGE__ . '::Exception::NoParameters')->throw(
            "Neither parameters, command nor URL are given"
        );
    }

    my $job_run = ${$self->get_time_current}[0];
    my $result  = $command_to_run->run(
        fatal_fail  => $fatal_fail,
        fatal_empty => $fatal_empty,
        fatal_431   => $fatal_431
    );
    my $dom     = $self->get_dom($result);

    if(my $jobid = $dom->findvalue('/*/jobid')) {

        $logger->tracef("We've got an asynchronous job, the job ID is: %s", $jobid);

        if($wait) {

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

                my $job_result = $self->get_job_result($jobid);

                if($job_result->findvalue('/*/jobstatus') ne '0') {
                    $logger->tracef("The job %s is finished", $jobid);
                    $dom = $job_result;
                    last;
                }

                if(
                    ($wait > 0) &&
                    ($wait + $job_run <= ${$self->get_time_current}[0])
                ) {
                    (__PACKAGE__ . '::Exception::Timeout')->throwf(
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

method get_dom(Str $xml!) {

    my $dom = XML::LibXML->new->load_xml(string => $xml);

    $self->get_cloudstack->get_monkeyman->get_logger->tracef(
        "The %s XML document has been fetched as a DOM: %s", \$xml, $dom
    );

    return($dom);

}

method get_doms(
    Str     :$type!,
    HashRef :$criterions = { }
) {

    my $logger = $self->get_cloudstack->get_monkeyman->get_logger;

    my %magic_words = $self->get_magic_words($type);

    $logger->tracef("Looking for %s matching the %s set of criterias",
        $self->translate_type(type => $type, noun => 1, plural => 1),
        $criterions
    );

    my %parameters = ($self->_criterions_to_parameters(%{ $criterions }));
       $parameters{'command'} = $magic_words{'find_command'};

    my $dom = $self->run_command(
        parameters => \%parameters,
    );

    my @results = $self->qxp(
        query       =>
            '/' . $magic_words{'list_tag_global'} .
            '/' . $magic_words{'list_tag_entity'},
        dom         => $dom,
        return_as   => 'dom'
    );

    return(@results);

}



method get_job_result(Str $jobid!) {

    $self->run_command(
        parameters  => {
            command     => 'queryAsyncJobResult',
            jobid       => $jobid
        },
        fatal_fail  => 1,
        fatal_empty => 1
    );

}



method load_element_package(Str $type) {

    my $class_name = __PACKAGE__ . '::Element::' . $type;
    my $to_require = $class_name;
       $to_require =~ s#::#/#g;
       $to_require .= '.pm';
    if(! is_loaded($class_name)) {
        try {
            require($to_require)
        } catch($e) {
            (__PACKAGE__ . '::Exception::CantLoadPackage')->throwf(
                "Can't load the package for %s. %s",
                $self->translate_type(type => $type, plural => 1),
                $e
            );
        }
    }
    return($class_name);

}

method get_magic_words(Str $type!) {

    my $class_name = $self->load_element_package($type);

    no strict 'refs';
    my %magic_words = %{'::' . $class_name . '::_magic_words'};

    foreach my $magic_word (qw(
        find_command
        list_tag_global
        list_tag_entity
    )) {
        (__PACKAGE__ . '::Exception::MagicWordsArentDefined')->throwf(
            "The %s class doesn't have the %s magic word defined. " .
            "Sorry, but I can not use it.",
            $class_name, $magic_word
        )
            unless(defined($magic_words{$magic_word}));
    }
    return(%magic_words);

}

method get_elements(
    Str                                     :$type!,
    Maybe[Str]                              :$return_as = 'element',
    Maybe[HashRef]                          :$criterions,
    Maybe[ArrayRef[XML::LibXML::Document]]  :$doms,
) {

    if(defined($criterions)) {
        foreach my $result ($self->get_doms(
            type        => $type,
            criterions  => $criterions
        )) {
            push(@{ $doms }, $result);
        }
    }

    my @results;
    my $class_name = $self->load_element_package($type);
    foreach my $dom (@{ $doms }) {
        no strict 'refs';
        my $element = $class_name->new(
            api => $self,
            dom => $dom
        );
        push(@results, $self->_return_element_as($element, $return_as));
    }

    return(@results);

}



method qxp(
    Str                     :$query!,
    XML::LibXML::Document   :$dom!,
    Maybe[Str]              :$return_as,
) {

    my $logger = $self->get_cloudstack->get_monkeyman->get_logger;

    $logger->tracef(
        'Querying the %s DOM with the "%s" XPath-query',
        $dom,
        $query
    );

    my @results;

    foreach my $result ($dom->findnodes($query)->get_nodelist) {

        my $new_node = $result->cloneNode(1);
        my $new_dom = XML::LibXML::Document->new();
           $new_dom->addChild($new_node);

        if($return_as =~ /^value$/i) {

            push(@results, $new_dom->textContent);
            $logger->tracef(
                "Added the value of the %s DOM to the list of results",
                $new_dom
            );

        } elsif($return_as =~ /^dom$/i) {

            push(@results, $new_dom);
            $logger->tracef(
                "Added the %s DOM to the list of results",
                $new_dom
            );

        } elsif($return_as =~ /^hashref$/i) {

            tie(my %new_hash, 'XML::LibXML::AttributeHash', $new_dom);
            push(@results, \%new_hash);
            $logger->tracef(
                "Added the %s hash tied to the %s DOM to the list of results",
               \%new_hash,
                $new_dom
            );

        } elsif($return_as =~ /^(id|element)\[(\w+)\]$/i) {

            my $return_as   = $1;
            my $type        = $2;
            foreach my $element ($self->get_elements(
                type        => $type,
                doms        => [ $new_dom ],
            )) {
                push(@results, $self->_return_element_as($return_as, $result));
                $logger->tracef(
                    "Added the %s based on the %s DOM to the list of results",
                    $element->get_type(noun => 1),
                    $new_dom
                );
            }

        }

    }

    return(@results);


}



#
# Some helpers
#

method translate_type(
    Str    :$type!,
    Bool   :$a      = 0,
    Bool   :$noun   = 1,
    Bool   :$plural = 0
) {
    if($noun) {
        $type =~ s/(?:\b|(?<=([a-z])))([A-Z][a-z]+)/(defined($1) ? ' ' : '') . lc($2)/eg;
        $type = PL($type)
            if($plural);
        $type = A($type)
            if($a && !$plural);
    }
    return($type);
}

method _return_element_as(
    MonkeyMan::CloudStack::API::Roles::Element  $element!,
    Maybe[Str]                                  $return_as = 'element'
) {

    if     ($return_as  =~ /^element$/i) {
        return($element);
    } elsif($return_as  =~ /^dom$/i) {
        return($element->get_dom);
    } elsif($return_as  =~ /^id$/i) {
        return($element->get_id);
    } else {
        (__PACKAGE__ . '::Exception::InvalidParametersValue')->throwf(
            "The return_as parameter's value is invalid (%s).",
            $return_as
        );
    }

}

method _criterions_to_parameters(
    Str :$id,
    Str :$domainid
) {

    my %parameters;

    $parameters{'id'} = $id
        if(defined($id));
    $parameters{'domainid'} = $domainid
        if(defined($domainid));

    return(%parameters);

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
        wait        => 0,
        fatal_empty => 1,
        fatal_fail  => 1
    );

=head1 DESCRIPTION

The C<MonkeyMan::CloudStack::API> class encapsulates the interface to the
Apache CloudStack.

=head1 METHODS

=over

=item new()

This method initializes the framework and runs the application.

There are a few parameters that can (and need to) be defined:

=over

=item cloudstack => MonkeyMan::CloudStack

MANDATORY. The reference to the MonkeyMan::CloudStack object.

The value is readable by C<get_cloudstack()>.

=item configuration_tree => HashRef

Optional. The configuration tree. If it's not defined, the builder will fetch
it from the MonkeyMan::CloudStack's configuration tree.

The value is readable by C<get_configuration_tree()>.

=item useragent => Object

Optional. By default it will create a new LWP::UserAgent object and use it for
making calls to Apache CloudStack API. I don't recommend you to redefine it,
but who I am to teach you, huh? :)

The value is readable by C<get_configuration_tree()>.

=item useragent_signature => Str

Optional. The signature that will be used as the User-Agent header in all
outgoing HTTP requests. By default it will looke like that:

The value is readable by C<get_useragent_signature()>, writeable as
C<set_useragent_signature()>.

=over

APP-6.6.6 (powered by MonkeyMan-6.6.6) (libwww-perl/6.6.6)

=back

Please, note: if you don't use the default useragent, your one should be aware
of this parameter.

=back

=item run_command()

=item get_doms()

=item get_elements()

=item qxp()

=back

=cut

