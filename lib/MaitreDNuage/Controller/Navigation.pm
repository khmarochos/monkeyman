package MaitreDNuage::Controller::Navigation;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Mojolicious::Controller';

use Method::Signatures;
use TryCatch;



has 'menu_full' => (
    is          => 'rw',
    isa         => 'HashRef',
    reader      =>   '_get_menu_full',
    writer      =>   '_set_menu_full',
    builder     => '_build_menu_full',
    lazy        => 1
);

method _build_menu_full {
    {
        'Dashboard'                 => { order => 1, icon => 'fa fa-tachometer', destination => '/' },
        'Clients'                   => { order => 2, icon => 'fa fa-group',  destination => {
            'Persons'                   => { order => 1, icon =>, 'fa fa-user-o', destination => {
                'Add'                       => { order => 1, destination => '/person/new' },
                'Search'                    => { order => 2, destination => '/person/search' },
                'List Active'               => { order => 3, destination => '/person/list/active' },
                'List Archived'             => { order => 4, destination => '/person/list/archived' },
                'List All'                  => { order => 5, destination => '/person/list/all' }
            } },
            'Contractors'               => { order => 2, icon => 'fa fa-briefcase', destination => {
                'Add'                       => { order => 1, destination => '/contractor/new' },
                'Search'                    => { order => 2, destination => '/contractor/search' },
                'List Active'               => { order => 3, destination => '/contractor/list/active' },
                'List Archived'             => { order => 4, destination => '/contractor/list/archived' },
                'List All'                  => { order => 5, destination => '/contractor/list/all' }
            } },
            'Corporations'              => { order => 3, icon => 'fa fa-building-o', destination => {
                'Add'                       => { order => 1, destination => '/corporation/new' },
                'Search'                    => { order => 2, destination => '/corporation/search' },
                'List Active'               => { order => 3, destination => '/corporation/list/active' },
                'List Archived'             => { order => 4, destination => '/corporation/list/archived' },
                'List All'                  => { order => 5, destination => '/corporation/list/all' }
            } }
        } },
        'Service Provisioning'      => { order => 3, icon => 'fa fa-coffee', destination => {
            'Agreements'                => { order => 1, icon => 'fa fa-file-text-o', destination => {
                'Add'                       => { order => 1, destination => '/provisioning_agreement/new' },
                'Search'                    => { order => 2, destination => '/provisioning_agreement/search' },
                'List Active'               => { order => 3, destination => '/provisioning_agreement/list/active' },
                'List Archived'             => { order => 4, destination => '/provisioning_agreement/list/archived' },
                'List All'                  => { order => 5, destination => '/provisioning_agreement/list/all' }
            } },
            'Obligations'               => { order => 2, icon => 'fa fa-shopping-cart', destination => {
                'Add'                       => { order => 1, destination => '/provisioning_obligation/new' },
                'Search'                    => { order => 2, destination => '/provisioning_obligation/search' },
                'List Active'               => { order => 3, destination => '/provisioning_obligation/list/active' },
                'List Archived'             => { order => 4, destination => '/provisioning_obligation/list/archived' },
                'List All'                  => { order => 5, destination => '/provisioning_obligation/list/all' }
            } },
            'Resources'                 => { order => 3, icon => 'fa fa-server', destination => {
                'Add'                       => { order => 1, destination => '/resource_piece/new' },
                'Search'                    => { order => 2, destination => '/resource_piece/search' },
                'List Active'               => { order => 3, destination => '/resource_piece/list/active' },
                'List Archived'             => { order => 4, destination => '/resource_piece/list/archived' },
                'List All'                  => { order => 5, destination => '/resource_piece/list/all' }
            } },
        } },
        'Partnership'               => { order => 4, icon => 'fa fa-handshake-o', destination => {
            'Agreements'                => { order => 1, icon => 'fa fa-file-text-o', destination => {
                'Add'                       => { order => 1, destination => '/partnership_agreement/new' },
                'Search'                    => { order => 2, destination => '/partnership_agreement/search' },
                'List Active'               => { order => 3, destination => '/partnership_agreement/list/active' },
                'List Archived'             => { order => 4, destination => '/partnership_agreement/list/archived' },
                'List All'                  => { order => 5, destination => '/partnership_agreement/list/all' }
            } },
        } },
        'Billing'                   => { order => 5, icon => 'fa fa-money', destination => {
            'Invoices'                  => { order => 1, icon => 'fa fa-check-square-o', destination => {
                'Add'                       => { order => 1, destination => '/invoice/new' },
                'Search'                    => { order => 2, destination => '/invoice/search' },
                'List Active'               => { order => 3, destination => '/invoice/list/active' },
                'List Archived'             => { order => 4, destination => '/invoice/list/archived' },
                'List All'                  => { order => 5, destination => '/invoice/list/all' }
            } },
            'Top-ups & Write-offs'     => { order => 2, icon => 'fa fa-bank', destination => '/billing/list/consolidated' }
        } },
    }
}



method build_menu {
    $self->stash(navigation_menu => $self->_get_menu_full);
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
