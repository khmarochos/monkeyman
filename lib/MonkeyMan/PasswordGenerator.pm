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

method _build_generator(...) {
    return(App::Genpass->new);
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
    Int :$samples?  = 1,
    Int :$length?   = MM_DEFAULT_PASSWORD_LENGTH
) {
    return($self->_get_generator->generate($samples));
}



#__PACKAGE__->meta->make_immutable;

1;
