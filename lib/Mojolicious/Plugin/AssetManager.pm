package Mojolicious::Plugin::AssetManager;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Mojo::Util 'xml_escape';
use Text::Glob 'match_glob';
use Method::Signatures;



has 'assets_library' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_assets_library',
    writer      =>   '_set_assets_library',
    predicate   =>   '_has_assets_library',
    builder     => '_build_assets_library',
    lazy        => 1,
);

method _build_assets_library {
    {}
}



has 'mojo_app' => (
    is          => 'ro',
    isa         => 'Object',
    reader      => '_get_mojo_app',
    writer      => '_set_mojo_app',
    predicate   => '_has_mojo_app',
    lazy        => 0
);



method register(
    Object          $app!,
    HashRef         $configuration!
) {
    $self->_set_mojo_app($app);
    if(defined(my $assets_library = $configuration->{'assets_library'})) {
        foreach my $asset_type (keys(%{ $assets_library })) {
            foreach my $asset_alias (keys(%{ $assets_library->{ $asset_type } })) {
                $self->asset_register(
                    undef,
                    $asset_type,
                    $asset_alias,
                    $assets_library->{ $asset_type }->{ $asset_alias }
                );
            }
        }
    }
    $app->helper(asset_required => sub { $self->asset_required(@_); });
    $app->helper(asset_compiled => sub { $self->asset_compiled(@_); });
}



method asset_register(
    Maybe[Object]   $controller!,
    Str             $asset_type!,
    Str             $asset_alias!,
    ArrayRef        $asset_items!
) {
    $self->_get_assets_library->{ $asset_type }->{ $asset_alias } = $asset_items;
}

method asset_required(
    Object          $controller!,
    Str             $asset_type!,
    Str             $asset_alias?,
    Maybe[Bool]     $required?
) {
    my @assets_required;
    my $assets_of_this_type_required    = $self->_dig(1, $controller->stash, 'assets_required', $asset_type);
    my $assets_of_this_type_registered  = $self->_dig(0, $self->_get_assets_library, $asset_type);
    foreach my $asset_found (
        grep { $_ if(match_glob($asset_alias, $_)) }
            defined($required) ?
                (keys(%{ $assets_of_this_type_registered })) :
                (keys(%{ $assets_of_this_type_required }))
    ) {
        $assets_of_this_type_required->{ $asset_found } = $required
            if(defined($required));
        push(@assets_required, $asset_found)
            if($assets_of_this_type_required->{ $asset_found });
    }
    @assets_required;
}

method asset_compiled(
    Object          $controller!,
    Str             $asset_type!,
    Str             $asset_alias!
) {
    if(defined(my $asset_items = $self->_get_assets_library->{ $asset_type }->{ $asset_alias })) {
        return(@{ $asset_items });
    }
}

# FIXME: Move it to a separate package
method _dig (Bool $create!, HashRef $hashref!, @keys?) {
    if(my $key = shift(@keys)) {
        return(defined($hashref->{ $key }) ?
            (@keys   ? $self->_dig($create, $hashref->{ $key }     , @keys) : $hashref->{ $key }) :
            ($create ? $self->_dig($create, $hashref->{ $key } = {}, @keys) : undef)
        );
    } else {
        return($hashref);
    }
}




__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
