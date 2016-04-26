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

# # warn(Dumper(\@_));
    shift;
    my %args = @_;

# # warn(Dumper(Class::MOP::get_metaclass_by_name($args{for_class})));
# # warn(Dumper(Moose::Meta::Role->meta));

    Moose->init_meta(%args);
# # warn(Dumper(\%args));

    Moose::Util::MetaRole::apply_metaroles(
        for             => $args{for_class},
        class_metaroles => {
            attribute   => ['MooseX::Handies::Role::Meta::Attribute'],
        },
    );

    return $args{for_class}->meta();

}


1;
