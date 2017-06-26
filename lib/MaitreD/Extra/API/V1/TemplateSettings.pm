package MaitreD::Extra::API::V1::TemplateSettings;
use utf8;

our $settings = {
    'person->list' => {
        'snippets->table_json' => {
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
                'Valid Since' => {
                    'order'    => 4,
                    'db_name'  => 'valid_since',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_since, 2);
                    },
                },
                'Valid Till' => {
                    'order'    => 5,
                    'db_name'  => 'valid_till',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_till, 2);
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
            
            'language'  => sub {
                shift;
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "first_name" },
                    { "data" => "last_name" },
                    { "data" => "valid_since" },
                    { "data" => "valid_till" },
                ],
                'ajax' =>  '/person/list/all.json',
            },            
        }
    },
    #
    # Contractor
    #
    'contractor->list' => {
        'snippets->table_json' => {
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
                'Valid Since' => {
                    'order'    => 4,
                    'db_name'  => 'valid_since',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_since, 2);
                    },
                },
                'Valid Till' => {
                    'order'    => 5,
                    'db_name'  => 'valid_till',
                    'db_value' => sub {
                        shift->datetime_display( shift->valid_till, 2);
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
                    'value' => "/provisioning_agreement/list/related_to/contractor/%s",
                },
                'Partnership Agreements' => {
                    'order' => 2,
                    'icon'  => 'fa fa-file-text',
                    'value' => "/partnership_agreement/list/related_to/contractor/%s",
                },
                'Contractors' => {
                    'order' => 3,
                    'icon'  => 'fa fa-briefcase',
                    'value' => "/contractor/list/related_to/contractor/%s",
                },
                'Corporations' => {
                    'order' => 4,
                    'icon'  => 'fa fa-building-o',
                    'value' => "/corporation/list/related_to/contractor/%s",
                }
            },
            
            'datatable' => {
                'columns' =>  [
                    { "data" => "id" },
                    { "data" => "first_name" },
                    { "data" => "last_name" },
                    { "data" => "valid_since" },
                    { "data" => "valid_till" },
                ],
                'ajax' =>  '/contractor/list/all.json',
            },            
        }
    }    
};

1;