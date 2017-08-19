package MaitreD::Extra::API::V1::TemplateSettings;
use utf8;

our $settings = {
    'person' => {
        'table' => {
            'name'    => 'person',
            'columns' => {
                'ID' => {
                    'order'    => 1,
                    'db_name'  => 'id',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->id);
                    },
                },
                'Name' => {
                    'order'    => 2,
                    'db_name'  => 'first_name',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->first_name);
                    },
                },
                'Last Name' => {
                    'order'    => 3,
                    'db_name'  => 'last_name',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->last_name);
                    },
                },
                'Valid From' => {
                    'order'    => 4,
                    'db_name'  => 'valid_from',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_from, 2);
                    },
                },
                'Valid Till' => {
                    'order'    => 5,
                    'db_name'  => 'valid_till',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_till, 2) || '∞';
                    },
                },
                'Action' => {
                    'order' => 6,
                },
            },
            'related'   => {
                'Provisioning Agreements' => {
                    'order' => 1,
                    'icon'  => 'fa fa-file-text-o',
                    'value' => "/provisioning_agreement/list/related_to/person/%s",
                },
                'Partnership Agreements' => {
                    'order' => 2,
                    'icon'  => 'fa fa-file-text',
                    'value' => "/partnership_agreement/list/related_to/person/%s",
                },
                'Contractors' => {
                    'order' => 3,
                    'icon'  => 'fa fa-briefcase',
                    'value' => "/contractor/list/related_to/person/%s",
                },
                'Corporations' => {
                    'order' => 4,
                    'icon'  => 'fa fa-building-o',
                    'value' => "/corporation/list/related_to/person/%s",
                }
            },
                
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "first_name" },
                    { "data" => "last_name" },
                    { "data" => "valid_from" },
                    { "data" => "valid_till" },
                ],
                'ajax' =>  '/person/list/all.json',
            },            
        },
    },
    #
    # Contractor
    #
    'contractor' => {
        'table' => {
            'name'    => 'contractor',
            'columns' => {
                'ID' => {
                    'order'    => 1,
                    'db_name'  => 'id',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->id);
                    },
                },
                'Name' => {
                    'order'    => 2,
                    'db_name'  => 'name',
                    'db_value' => sub {
                        shift;
                        sprintf( "%s", shift->name );
                    },
                },
                'Valid From' => {
                    'order'    => 3,
                    'db_name'  => 'valid_from',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_from, 2);
                    },
                },
                'Valid Till' => {
                    'order'    => 4,
                    'db_name'  => 'valid_till',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_till, 2) || '∞';
                    },
                },
                'Action' => {
                    'order' => 5,
                },
            },
            'related'   => {
                'Provisioning Agreements' => {
                    'order' => 1,
                    'icon'  => 'fa fa-file-text-o',
                    'value' => "/provisioning_agreement/list/related_to/contractor/%s",
                },
                'Partnership Agreements' => {
                    'order' => 2,
                    'icon'  => 'fa fa-file-text',
                    'value' => "/partnership_agreement/list/related_to/contractor/%s",
                },
                'Persons' => {
                    'order' => 3,
                    'icon'  => 'fa fa-user-o',
                    'value' => "/person/list/related_to/contractor/%s",
                },
                'Corporations' => {
                    'order' => 4,
                    'icon'  => 'fa fa-building-o',
                    'value' => "/corporation/list/related_to/person/%s",
                }
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "name" },
                    { "data" => "valid_from" },
                    { "data" => "valid_till" },
                ],
                'ajax' =>  '/contractor/list/all.json',
            },            
        },
    },
    #
    # Corporation
    #
    'corporation' => {
        'table' => {
            'name'    => 'corporation',
            'columns' => {
                'ID' => {
                    'order'    => 1,
                    'db_name'  => 'id',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->id);
                    },
                },
                'Name' => {
                    'order'    => 2,
                    'db_name'  => 'name',
                    'db_value' => sub {
                        shift;
                        sprintf( "%s", shift->name );
                    },
                },
                'Valid From' => {
                    'order'    => 3,
                    'db_name'  => 'valid_from',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_from, 2);
                    },
                },
                'Valid Till' => {
                    'order'    => 4,
                    'db_name'  => 'valid_till',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_till, 2) || '∞';
                    },
                },
                'Action' => {
                    'order' => 5,
                },
            },
            'related'   => {
                'Provisioning Agreements' => {
                    'order' => 1,
                    'icon'  => 'fa fa-file-text-o',
                    'value' => "/provisioning_agreement/list/related_to/corporation/%s",
                },
                'Partnership Agreements' => {
                    'order' => 2,
                    'icon'  => 'fa fa-file-text',
                    'value' => "/partnership_agreement/list/related_to/corporation/%s",
                },
                'Persons' => {
                    'order' => 3,
                    'icon'  => 'fa fa-user-o',
                    'value' => "/person/list/related_to/corporation/%s",
                },
                'Contractors' => {
                    'order' => 4,
                    'icon'  => 'fa fa-briefcase',
                    'value' => "/contractor/list/related_to/corporation/%s",
                },
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "name" },
                    { "data" => "valid_from" },
                    { "data" => "valid_till" },
                ],
                'ajax' =>  '/corporation/list/all.json',
            },            
        },
    },
    #
    # provisioning_agreement
    #
    'provisioning_agreement' => {
        'table' => {
            'name'    => 'corporation',
            'columns' => {
                'ID' => {
                    'order'    => 1,
                    'db_name'  => 'id',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->id);
                    },
                },
                'Number' => {
                    'order'    => 2,
                    'db_name'  => 'number',
                    'db_value' => sub {
                        shift;
                        shift->client_contractor->name;
                    }
                },
                'Valid From' => {
                    'order'    => 3,
                    'db_name'  => 'valid_from',
                    'db_value' => sub { shift->datetime_display(shift->valid_from, 2); }
                },
                'Valid Till' => {
                    'order'    => 4,
                    'db_name'  => 'valid_till',
                    'db_value' => sub { shift->datetime_display(shift->valid_till, 2) || '∞'; }
                },
                'Client' => {
                    'order'    => 5,
                    'db_name'  => 'client',
                    'db_value' => sub {
                        my $controller = shift;
                        my $row = shift;
                        sprintf(
                            "%s",
                            $row->client_contractor->name
                        );
                    }
                },
                'Provider' => {
                    'order'    => 6,
                    'db_name'  => 'provider',
                    'db_value' => sub {
                        my $controller = shift;
                        my $row = shift;
                        sprintf(
                            "%s",
                            $row->provider_contractor->name,
                        );
                    }
                },
                'Action' => {
                    'order' => 7,
                },
            },
            'related'   => {
                'Persons'                   => {
                    'order' => 1,
                    'icon'  => 'fa fa-user-o',
                    'value' => "/person/list/related_to/provisioning_agreement/%s",
                },
                'Provisioning Obligations'  => {
                    'order' => 2,
                    'icon'  => 'fa fa-shopping-cart',
                    'value' => "/provisioning_obligation/list/related_to/provisioning_agreement/%s",
                },
                'Resources'  => {
                    'order' => 3,
                    'icon'  => 'fa fa-server',
                    'value' => "/resource_piece/list/related_to/provisioning_agreement/%s",
                }
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "number" },
                    { "data" => "valid_from" },
                    { "data" => "valid_till" },
                    { "data" => "client" },
                    { "data" => "provider" },
                ],
                'ajax' =>  '/provisioning_agreement/list/all.json',
            },            
            
        },
    },
    #
    # provisioning_obligation
    #
    'provisioning_obligation' => {
        'table' => {
            'name'    => 'corporation',
            'columns' => {
                'ID' => {
                    'order'    => 1,
                    'db_name'  => 'id',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->id);
                    },
                },
                'Valid From' => {
                    'order'    => 2,
                    'db_name'  => 'valid_from',
                    'db_value' => sub { shift->datetime_display(shift->valid_from, 2); }
                },
                'Valid Till' => {
                    'order'    => 3,
                    'db_name'  => 'valid_till',
                    'db_value' => sub { shift->datetime_display(shift->valid_till, 2) || '∞'; }
                },
                'Provisioning Agreement' => {
                    'order'    => 4,
                    'db_name'  => 'provisioning_agreement',
                    'db_value' => sub {
                        shift;
                        shift->provisioning_agreement->name
                    }
                },
                'Service' => {
                    'order' => 5,
                    'db_name'  => 'service',
                    'db_value' => sub {
                        shift;
                        shift->name;
                    }
                },
                'Quantity' => {
                    'order'    => 6,
                    'db_name'  => 'quantity',
                    'db_value' => sub {
                        shift;
                        shift->quantity;
                    }
                },
                'Action' => {
                    'order' => 7,
                },
            },

            'related'   => {
                'Provisioning Agreements'  => {
                    'order' => 1,
                    'icon'  => 'fa fa-file-text-o',
                    'value' => "/provisioning_agreement/list/related_to/provisioning_obligation/%s",
                },
                'Resources'  => {
                    'order' => 2,
                    'icon'  => 'fa fa-server',
                    'value' => "/resource_piece/list/related_to/provisioning_obligation/%s",
                }
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "valid_from" },
                    { "data" => "valid_till" },
                    { "data" => "provisioning_agreement" },
                    { "data" => "service" },
                    { "data" => "quantity" },
                ],
                'ajax' =>  '/provisioning_obligation/list/all.json',
            },            
            
        },
    },
    #
    # resource_piece
    #
    'resource_piece' => {
        'table' => {
            'name'    => 'resource_piece',
            'columns' => {
                'ID' => {
                    'order'    => 1,
                    'db_name'  => 'id',
                    'db_value' => sub {
                        shift;
                        sprintf("%s", shift->id);
                    },
                },
                'Valid From' => {
                    'order'    => 2,
                    'db_name'  => 'valid_from',
                    'db_value' => sub { shift->datetime_display(shift->valid_from, 2); }
                },
                'Valid Till' => {
                    'order'    => 3,
                    'db_name'  => 'valid_till',
                    'db_value' => sub { shift->datetime_display(shift->valid_till, 2) || '∞'; }
                },
                'Resource Type' => {
                    'order'    => 4,
                    'db_name'  => 'resource_type',
                    'db_value' => sub {
                        shift;
                        shift->resource_type->name
                    }
                },
                'Resource Handle' => {
                    'order' => 5,
                    'db_name'  => 'resource_handle',
                    'db_value' => sub {
                        shift;
                        shift->resource_handle;
                    }
                },
                'Resource Host' => {
                    'order'    => 6,
                    'db_name'  => 'resource_host',
                    'db_value' => sub {
                        shift;
                        shift->resource_host->id;
                    }
                },
                'Action' => {
                    'order' => 7,
                },
            },

            'related'   => {
                'Provisioning Agreements'  => {
                    'order' => 1,
                    'icon'  => 'fa fa-file-text-o',
                    'value' => "/provisioning_agreement/list/related_to/resource_piece/%s",
                },
                'Provisioning Obligations'  => {
                    'order' => 2,
                    'icon'  => 'fa fa-shopping-cart',
                    'value' => "/resource_piece/list/related_to/resource_piece/%s",
                }
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "valid_from" },
                    { "data" => "valid_till" },
                    { "data" => "resource_type" },
                    { "data" => "resource_handle" },
                    { "data" => "resource_host" },
                ],
                'ajax' =>  '/resource_piece/list/all.json',
            },            
            
        },        
    },
};

1;
