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

has 'snippets_library' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>   '_get_snippets_library',
    writer      =>   '_set_snippets_library',
    predicate   =>   '_has_snippets_library',
    builder     => '_build_snippets_library',
    lazy        => 1,
);

method _build_snippets_library {
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
    $app->helper(asset_register   => sub { $self->asset_register(@_);   });
    $app->helper(asset_required   => sub { $self->asset_required(@_);   });
    $app->helper(asset_compiled   => sub { $self->asset_compiled(@_);   });
    $app->helper(snippet_register => sub { $self->snippet_register(@_); });
    $app->helper(snippet_required => sub { $self->snippet_required(@_); });
    $app->helper(snippet_compiled => sub { $self->snippet_compiled(@_); });
}



method asset_register(
    Maybe[Object]   $controller!,
    Str             $asset_type!,
    Str             $asset_alias!,
    ArrayRef        $asset_items!,
    Maybe[Int]      $order?
) {
    $self->_get_assets_library->{ $asset_type }->{ $asset_alias } = $asset_items;
    $self->asset_required($controller, $asset_type, $asset_alias, $order)
        if(defined($order));
}



method asset_required(
    Object          $controller!,
    Str             $asset_type!,
    Str             $asset_alias?,
    Maybe[Int]      $order?
) {
    $self->_required(
        library         => $self->_get_assets_library,
        stashed         => $self->_dig(1, $controller->stash, 'assets_required'),
        element_type    => $asset_type,
        element_alias   => $asset_alias,
        order           => $order
    );
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



method snippet_register(
    Maybe[Object]   $controller!,
    Str             $snippet_type!,
    Str             $snippet_alias!,
    CodeRef         $snippet_text!,
    Maybe[Int]      $order? = 1
) {
    $self->_get_snippets_library->{ $snippet_type }->{ $snippet_alias } = $snippet_text;
    $self->snippet_required($controller, $snippet_type, $snippet_alias, $order)
        if(defined($order));
}



method snippet_required(
    Object          $controller!,
    Str             $snippet_type!,
    Str             $snippet_alias?,
    Maybe[Int]      $order?
) {
    $self->_required(
        library         => $self->_get_snippets_library,
        stashed         => $self->_dig(1, $controller->stash, 'snippets_required'),
        element_type    => $snippet_type,
        element_alias   => $snippet_alias,
        order           => $order
    );
}



method snippet_compiled(
    Object          $controller!,
    Str             $snippet_type!,
    Str             $snippet_alias!
) {
    $self->_get_snippets_library->{ $snippet_type }->{ $snippet_alias };
}



method _required(
    HashRef         :$stashed,
    HashRef         :$library,
    Str             :$element_type!,
    Str             :$element_alias?,
    Maybe[Int]      :$order?
) {
    my @elements_required;
    my $elements_of_this_type_order       = $self->_dig(1, $stashed, $element_type);
    my $elements_of_this_type_registered  = $self->_dig(0, $library, $element_type);
    foreach my $element_found (
        grep { $_ if(match_glob($element_alias, $_)) }
            defined($order) ?
                (
                    keys(%{ $elements_of_this_type_registered })
                ) : (
                    sort(
                        {
                            $elements_of_this_type_order->{ $a } <=>
                            $elements_of_this_type_order->{ $b }
                        }
                            keys(%{ $elements_of_this_type_order })
                    )
                )
    ) {
        $elements_of_this_type_order->{ $element_found } = $order
            if(defined($order));
        push(@elements_required, $element_found)
            if($elements_of_this_type_order->{ $element_found });
    }
    @elements_required;
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
