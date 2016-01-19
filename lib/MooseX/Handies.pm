package MooseX::Handies;

use namespace::autoclean;
use Moose 2.1604;
use Moose::Exporter;
use Moose::Util::MetaRole;
use MooseX::Handies::Role::Meta::Attribute;
use Data::Dumper;

our $VERSION = '1.0';



Moose::Exporter->setup_import_methods( also => 'Moose' );

sub init_meta {

    shift;
    my %args = @_;

    Moose->init_meta(%args);

    Moose::Util::MetaRole::apply_metaroles(
        for             => $args{for_class},
        class_metaroles => {
            attribute   => ['MooseX::Handies::Role::Meta::Attribute'],
        },
    );

    return $args{for_class}->meta();

}


1;
