package MonkeyMan::PasswordGenerator;

=head1 NAME

MonkeyMan::PasswordGenerator - the name is pretty self-descriptive :)

=cut

use strict;
use warnings;

use MonkeyMan::Constants qw(:passwords);
use MonkeyMan::Exception;

# Use Moose and be happy :)
use Moose;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

# Use 3rd-party libraries
use Method::Signatures;
use App::Genpass;



has generator => (
    is      => 'ro',
    isa     => 'App::Genpass',
    reader  =>   '_get_generator',
    writer  =>   '_set_generator',
    builder => '_build_generator',
    lazy    => 1
);

method _build_generator(Maybe[HashRef] :$configuration) {

    unless(defined($configuration)) {
        $configuration = ($self->_has_configuration && defined($self->get_configuration)) ?
                          $self->get_configuration :
                          {}
    }

    my %generator_configuration;

    my $parameter = defined($configuration->{'length'}) ? 
                            $configuration->{'length'} :
                            MM_DEFAULT_PASSWORD_LENGTH;
    if($parameter =~ /^(\d+)-(\d+)$/) {
        $generator_configuration{'minlength'} = $1;
        $generator_configuration{'maxlength'} = $2;
    } else {
        $generator_configuration{'length'} = $parameter;
    }

    $parameter = defined($configuration->{'all_characters'}) ?
                         $configuration->{'all_characters'} :
                         MM_DEFAULT_PASSWORD_ALL_CHARACTERS;
    $generator_configuration{'verify'} = $parameter;

    $parameter = defined($configuration->{'readable_only'}) ?
                         $configuration->{'readable_only'} :
                         MM_DEFAULT_PASSWORD_READABLE_ONLY;
    $generator_configuration{'readable'} = $parameter;

    return(App::Genpass->new(%generator_configuration));
}



has configuration => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_configuration',
    writer      =>   '_set_configuration',
    predicate   =>   '_has_configuration',
    builder     => '_build_configuration',
    lazy        => 1
);

method _build_configuration(...) {
    return({});
}



method generate(
    Int :$samples? = 1,
) {
    return($self->_get_generator->generate($samples));
}



#__PACKAGE__->meta->make_immutable;

1;
