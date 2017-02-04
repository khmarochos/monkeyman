package Mojolicious::Plugin::AssetManager;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Plugin';

use Mojo::Util 'xml_escape';
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
    $app->helper(asset_needed => sub { $self->asset_needed(@_); });
    $app->helper(asset_render => sub { $self->asset_render(@_); });
}



method asset_register(
    Maybe[Object]   $controller!,
    Str             $asset_type!,
    Str             $asset_alias!,
    ArrayRef        $asset_items!
) {
    $self->_get_assets_library->{ $asset_type }->{ $asset_alias } = $asset_items;
}

method asset_needed(
    Object          $controller!,
    Str             $asset_type!,
    Maybe[Str]      $asset_alias?,
    Maybe[Bool]     $needed?
) {
    my $assets_of_this_type = $self->_dig(1, $controller->stash, 'assets_needed', $asset_type);
    if(defined($asset_alias)) {
        if(defined($needed)) {
            return($assets_of_this_type->{ $asset_alias } = $needed);
        } elsif(defined($assets_of_this_type->{ $asset_alias })) {
            return($assets_of_this_type->{ $asset_alias });
        } else {
            return(0);
        }
    } else {
        my @assets_needed;
        if(
            defined($assets_of_this_type) &&
                ref($assets_of_this_type) eq 'HASH'
        ) {
            foreach my $asset_alias (keys(%{ $assets_of_this_type })) {
                push(@assets_needed, $asset_alias)
                    if($self->asset_needed($controller, $asset_type, $asset_alias));
            }
        }
        return(@assets_needed);
    }
}

method asset_items(
    Str             $asset_type!,
    Str             $asset_alias!
) {
    if(defined(my $asset_items = $self->_get_assets_library->{ $asset_type }->{ $asset_alias })) {
        return(@{ $asset_items });
    }
}

method asset_render(
    Object          $controller!,
    Str             $asset_type!
) {
    my @result;
    foreach my $asset_needed ($self->asset_needed($controller, $asset_type)) {
        foreach my $asset ($self->asset_items($asset_type, $asset_needed)) {
            push(@result, '<link href="' . xml_escape($asset) . '" rel="stylesheet">');
        }
    }
    return(join("\n", @result));
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
