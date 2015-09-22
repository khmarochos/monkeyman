package MonkeyMan::Configuration;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Aliases;
use namespace::autoclean;

# Inherit some essentials
with 'MonkeyMan::Essentials';

use MonkeyMan::Constants qw(:filenames);

# Use 3rd-party libraries
use TryCatch;
use Config::General qw(ParseConfig);



has 'configuration' => (
    is          => 'ro',
    isa         => 'HashRef',
    init_arg    => undef,
    builder     => '_build_configuration',
    reader      => '_get_configuration',
    predicate   => '_has_configuration',
    alias       => 'tree',
    lazy        => 1
);

sub _build_configuration {

    return({});

}



sub BUILD {

    my $self    = shift;
    my $mm      = $self->mm;

    my $config = Config::General->new(
        -ConfigFile         => (
            defined($mm->parameters->mm_configuration) ?
                    $mm->parameters->mm_configuration :
                    MM_CONFIG_MAIN
        ),
        -UseApacheInclude   => 1,
        -ExtendedAccess     => 1
    );

    %{$self->_get_configuration} = $config->getall;

}



1;
