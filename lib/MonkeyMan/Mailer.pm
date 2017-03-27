package MonkeyMan::Mailer;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use MonkeyMan::Exception qw(InsecureTemplateId AbsentTemplateDirectory AbsentTemplateFile TemplateFillingInFailure TransportFailure);

use TryCatch;
use Method::Signatures;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::Persistent;
use Email::MIME;
use Text::Template;
use Sys::Hostname;
use File::Spec;
use File::Basename;
use Cwd qw(realpath);



has 'configuration' => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>   '_has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration {
    return({});
}

has 'logger' => (
    is          => 'ro',
    isa         => 'MonkeyMan::Logger',
    reader      =>   '_get_logger',
    writer      =>   '_set_logger',
    predicate   =>   '_has_logger',
    builder     => '_build_logger',
    lazy        => 1
);

method _build_logger {
    return(MonkeyMan::Logger->instance);
}

has smtp_transport => (
    is          => 'ro',
    isa         => 'Email::Sender::Transport',
    reader      =>   '_get_smtp_transport',
    writer      =>   '_set_smtp_transport',
    predicate   =>   '_has_smtp_transport',
    builder     => '_build_smtp_transport',
    lazy        => 1
);

method _build_smtp_transport {
    my $configuration = $self->get_configuration->{'smtp_transport'};
    my $transport;
    try {
        $transport = Email::Sender::Transport::SMTP::Persistent->new(
                       defined($configuration->{'host'})          ?
           (host            => $configuration->{'host'})          : (),
                       defined($configuration->{'port'})          ?
           (port            => $configuration->{'port'})          : (),
                       defined($configuration->{'ssl'})           ?
           (ssl             => $configuration->{'ssl'})           : (),
                       defined($configuration->{'sasl_username'}) ?
           (sasl_username   => $configuration->{'sasl_username'}) : (),
                       defined($configuration->{'sasl_password'}) ?
           (sasl_password   => $configuration->{'sasl_password'}) : (),
                       defined($configuration->{'helo'})          ?
           (helo            => $configuration->{'helo'})          :
           (helo            => hostname)
        );
    } catch($e) {
        (__PACKAGE__ . '::Exception::TransportFailure')->throwf(
            "Can't initialize the SMTP transport object: %s", $e
        );
    }
    return($transport);
}

has templates_directory => (
    is          => 'ro',
    isa         => 'Str',
    reader      =>   '_get_templates_directory',
    writer      =>   '_set_templates_directory',
    predicate   =>   '_has_templates_directory',
    builder     => '_build_templates_directory',
    lazy        => 1
);

method _build_templates_directory {
    if(!defined(my $path = $self->get_configuration->{'templates'}->{'directory'})) {
        MonkeyMan::Exception->throw(); #FIXME
    } elsif(!defined(my $realpath = realpath($path))) {
        MonkeyMan::Exception->throw(); #FIXME
    } else {
        return($realpath);
    }
}

has templates_directory_split => (
    is          => 'ro',
    isa         => 'ArrayRef',
    reader      =>   '_get_templates_directory_split',
    writer      =>   '_set_templates_directory_split',
    predicate   =>   '_has_templates_directory_split',
    builder     => '_build_templates_directory_split',
    lazy        => 1
);

method _build_templates_directory_split {
    # If there's no trailing slash, add it
    return (_split_directory($self->_get_templates_directory));
}

# This function turns the "/foo/bar/baz/" into [ undef, 'foo', 'bar', 'baz' ]
func _split_directory(
    Str     $path!,
) {
    $path =~ s|([^/])$|$1/|;
    my @fileparse = fileparse($path);
    my @splitpath = File::Spec->splitpath($fileparse[1]);
    my @directory = File::Spec->splitdir($splitpath[1]);
    return([ $splitpath[0], @directory ]);
}

# This function makes sure that "/foo/bar/baz/../qux" is still in "/foo/bar"
func _is_in_directory(
    Str|ArrayRef    $path_to_check!,    # can be either "/foo/bar/baz" or [ undef, 'foo', 'bar', 'baz' ]
                    @directories        # can be a list of directories
) {
    if (my $cur_directory = shift(@directories)) {
        my @path_to_check_split = ref($path_to_check) eq 'ARRAY' ? @{ $path_to_check } : @{ _split_directory($path_to_check) };
        my @cur_directory_split = ref($cur_directory) eq 'ARRAY' ? @{ $cur_directory } : @{ _split_directory($cur_directory) };
        for(my $i = 0; $i < @cur_directory_split - 1; $i++) {
            unless($cur_directory_split[$i] eq $path_to_check_split[$i]) {
                return(0);
            }
        }
        return(_is_in_directory(\@path_to_check_split, @directories));
    } else {
        return(1);
    }
}

# It's needed to turn the "Foo::Bar::Baz" template ID into "/opt/monkeyman/templates/foo/bar/baz",
# checks that even "Foo::Bar::Baz::..::.." can't escape the /opt/monkeyman/templates directory
method _find_template_directory(Str $template_id!) {
    my @template_id_split  = split(/::/, $template_id);
    my $template_directory = File::Spec->catdir(@{ $self->_get_templates_directory_split }, @template_id_split);
    (__PACKAGE__ . '::Exception::InsecureTemplateId')->throwf(
        "The %s template ID is insecure", $template_id
    )
        if(! _is_in_directory($template_directory, $self->_get_templates_directory_split));
    (__PACKAGE__ . '::Exception::AbsentTemplateDirectory')->throwf(
        "The %s template directory (%s) doesn't exist", $template_id, $template_directory
    )
        if(! -d $template_directory);
    return($template_directory);
}

# Pretty simple and self-descriptive :)
method _fill_in_template(
    Str             :$template_id!,
    Str             :$template_part!,
    HashRef         :$template_values? = {},
    Bool            :$strict?
) {
    my $result;
    my $template_directory  = $self->_find_template_directory($template_id);
    my $template_file       = File::Spec->catfile(@{ _split_directory($template_directory) }, $template_part);
    unless(-f $template_file) {
        my @message = ("The %s file as a part of %s doesn't exist", $template_file, $template_id);
        if($strict) {
            (__PACKAGE__ . '::Exception::AbsentTemplateFile')->throwf(@message);
        } else {
            $self->_get_logger->warnf(@message);
        }
    }
    try {
        my $template = Text::Template->new(
            TYPE        => 'FILE',
            SOURCE      => $template_file,
            DELIMITERS  => [ '<%', '%>' ]
        );
        $result = $template->fill_in(
            HASH        => $template_values
        );
    } catch($e) {
        my @message = ("Can't fill in the %s template as a part of %s: %s", $template_file, $template_id, $e);
        if($strict) {
            (__PACKAGE__ . '::Exception::TemplateFillingInFailure')->throwf(@message);
        } else {
            $self->_get_logger->warnf(@message);
        }
    }
    return($result);
}

method create_message_from_template(
    Str|ArrayRef    :$recipients!,
    Str             :$sender?,
    Str             :$subject!,
    Str             :$template_id!,
    HashRef         :$template_values? = {}
) {

    my @message_parts;

    if(defined(my $part_txt = $self->_fill_in_template(
        template_id     => $template_id,
        template_part   => '_message.txt.ep',
        template_values => $template_values,
        strict          => 0
    ))) {
        push(@message_parts,
            Email::MIME->create(
                attributes => {
                    content_type    => 'text/plain',
                    charset         => 'UTF-8',
                    encoding        => 'quoted-printable'
                },
                body_str => $part_txt
            )
        );
    }
    if(defined(my $part_html = $self->_fill_in_template(
        template_id     => $template_id,
        template_part   => '_message.html.ep',
        template_values => $template_values,
        strict          => 0
    ))) {
        push(@message_parts,
            Email::MIME->create(
                attributes => {
                    content_type    => 'text/html',
                    charset         => 'UTF-8',
                    encoding        => 'quoted-printable'
                },
                body_str => $part_html
            )
        );
    }

    my $message = Email::MIME->create(
        parts       => [ @message_parts ],
        attributes  => {
            content_type    => 'multipart/alternative'
        },
        header_str  => [
            From            => 'v.melnik@uplink.ua',
            To              => $recipients,
            Subject         => $subject
        ]
    );

    return($message);

}

method send_message_from_template(
    Str|ArrayRef    :$recipients!,
    Str             :$sender?,
    Str             :$subject!,
    Str             :$template_id!,
    HashRef         :$template_values? = {}
) {
    my $message = $self->create_message_from_template(
        recipients      => $recipients,
        subject         => $subject,
        template_id     => $template_id,
        template_values => $template_values
    );
    sendmail($message, {
        transport   => $self->_get_smtp_transport
    });
}



__PACKAGE__->meta->make_immutable;

1;
