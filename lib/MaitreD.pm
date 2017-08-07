package MaitreD;

use strict;
use warnings;

use Mojo::Base qw(Mojolicious);
use Mojolicious::Plugin::DateTimeDisplay;
use Mojolicious::Plugin::AssetManager;
use Mojolicious::Plugin::DataTableParams;
use Method::Signatures;
use MonkeyMan;
use MonkeyMan::Exception qw(InvalidParameterSet);
use MaitreD::Schema;





method startup {

    $self->attr('_monkeyman'     => sub {
        MonkeyMan->initialize(
            app_name        => "MaitreD",
            app_description => "Maitre d'Tucha Application",
            app_version     => "та.похуй.блять"
        );
    });
    $self->attr('_hypermouse'    => sub {
        $self->_monkeyman->get_hypermouse
    });

    $self->plugin('DateTimeDisplay');
    $self->plugin('DataTableParams');
    
    $self->plugin('AssetManager', {
        assets_library => {
            js_pre      => {
                jQuery          => [ qw! /js/jquery-3.1.1.min.js                                ! ],
                bootstrap       => [ qw! /js/bootstrap.min.js                                   ! ],
                i18next         => [ qw! /js/plugins/i18next/i18next.min.js                     ! ],
                metisMenu       => [ qw! /js/plugins/metisMenu/jquery.metisMenu.js              ! ],
                slimScroll      => [ qw! /js/plugins/slimscroll/jquery.slimscroll.min.js        ! ]
            },
            js          => {
                multiField      => [ qw! /js/plugins/multiField/multiField.js                   ! ],
                steps           => [ qw! /js/plugins/steps/jquery.steps.min.js                  ! ],
                formValidation  => [ qw! /js/plugins/formValidation/formValidation.min.js
                                         /js/plugins/formValidation/framework/bootstrap.min.js  ! ],
                select2         => [ qw! /js/plugins/select2/select2.min.js                     ! ],
                dataTables      => [ qw! /js/plugins/dataTables/datatables.min.js               ! ],
                toastr          => [ qw! /js/plugins/toastr/toastr.min.js                       ! ],
                googleMaps      => [ qw! https://maps.google.com/maps/api/js?key=AIzaSyC8eacjB7FIw6OH4OMCloaWeoRxiDdfJak&libraries=places ! ],
                locationPicker  => [ qw! /js/plugins/locationPicker/locationpicker.jquery.js    ! ],
                iCheck          => [ qw! /js/plugins/iCheck/icheck.min.js                       ! ]
            },
            js_post     => {
                inspinia        => [ qw! /js/inspinia.js                                        ! ],
                pace            => [ qw! /js/plugins/pace/pace.min.js                           ! ]
            },
            css_pre     => {
                bootstrap       => [ qw! /css/bootstrap.min.css                                 ! ],
                fontawesome     => [ qw! /font-awesome/css/font-awesome.css                     ! ]
            },
            css         => {
                toastr          => [ qw! /css/plugins/toastr/toastr.min.css                     ! ],
                steps           => [ qw! /css/plugins/steps/jquery.steps.css                    ! ],
                select2         => [ qw! /css/plugins/select2/select2.min.css                   ! ],
                dataTables      => [ qw! /css/plugins/dataTables/datatables.min.css             ! ],
                datePicker      => [ qw! /css/plugins/datapicker/datepicker3.css                ! ],
                iCheck          => [ qw! /css/plugins/iCheck/custom.css                         ! ],
                summernote      => [ qw! /css/plugins/summernote/summernote.css
                                         /css/plugins/summernote/summernote-bs3.css             ! ]
            },
            css_post    => {
                animate         => [ qw! /css/animate.css                                       ! ],
                style           => [ qw! /css/style.css                                         ! ],
                maitre_d        => [ qw! /css/maitre-d.css                                      ! ]
            }
        }
    });
    my $md_schema = MaitreD::Schema->connect(
        'dbi:mysql:maitre_d',
        'hypermouse',
        'WTXFa2G1uN3cpwMP',
        { mysql_enable_utf8 => 1 }
    );
    # TODO: Move this crap to the configuration file
    # TODO: Create a separate database account

    $self->plugin('WebMessages', { schema => $md_schema });

    $self->helper(hypermouse    => sub { shift->app->_hypermouse });
    $self->helper(hm_schema     => sub { shift->app->_hypermouse->get_schema });
    $self->helper(md_schema     => sub { $md_schema });

    my  $routes = $self->routes;

        $routes = $routes
            ->under
            ->to('client#sesh');

        $routes
            ->post('/ajax/i18n')
            ->to   ('ajax#i18n');

        $routes
            ->get('/ajax/timezone/:area/:city')
            ->to(
                controller  => 'ajax',
                action      => 'list_timezones',
                area        => '*',
                city        => '*'
            );

        $routes
            ->any('/person/login' => [ format => ['json'] ] )
            ->name('person.login_json')
            ->to  ('person#login_json');
    
        $routes
            ->any('/person/login')
            ->name('person.login')
            ->to  ('person#login');
            
        $routes
            ->any('/person/signup')
            ->to(
                controller      => 'person',
                action          => 'signup'
            );
        $routes
            ->any('/person/confirm/:token')
            ->name('person.confirm')
            ->to(
                controller      => 'person',
                action          => 'confirm',
                token           => undef
            );

    # api
    my  $routes_api = $routes->any('/api/v1');
    my  $routes_api_web_messages = $routes_api->any('/web-messages');
        $routes_api_web_messages
            ->get('/:message_id')
            ->to(
                controller  => 'Controller::API::V1::WebMessage',
                action      => 'list',
                message_id  => undef
            );
        $routes_api_web_messages
            ->get('/:message_id/peek')
            ->to(
                controller  => 'Controller::API::V1::WebMessage',
                action      => 'list',
                message_id  => undef,
                peek        => 1
            );
            
    # // api
    
    my  $routes_authenticated = $routes->under->to('person#is_authenticated')
                                       ->under->to('person#load_settings')
                                       ->under->to('navigation#build_menu');
        $routes_authenticated
            ->any('/person/logout' => [ format => ['json'] ] )
            ->to(
                controller  => 'person',
                action      => 'logout_json'
            );

        $routes_authenticated
            ->get('/person/logout')
            ->to(
                controller  => 'person',
                action      => 'logout'
            );

        $routes_authenticated
            ->get('/')
            ->to('dashboard#welcome');

    my  $routes_authenticated_snippent_component = $routes_authenticated->under('/snippet-component');
    
    $routes_authenticated_snippent_component
        ->get("/person/:id/:action" => [ format => ["json"] ] )
        ->to(
            controller  => 'Controller::API::V1::SnippetComponent::Base',
            action      => 'email',
            id          => 0,
        );
    
    my  $routes_authenticated_person = $routes_authenticated->under('/person');
        $routes_authenticated_person
            ->get('/list/:filter/:related_element/:related_id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Person',
                action          => 'list',
                filter          => 'active',
                related_element => '',
                related_id      => ''
            );

        $routes_authenticated_person
            ->get('/list/:filter/:related_element/:related_id' )
            ->to(
                controller      => 'person',
                action          => 'list',
                filter          => 'active',
                related_element => '',
                related_id      => ''
            );
        
        $routes_authenticated_person
            ->get('/form/load/:id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Person',
                action          => 'form_load',
            );

            
        $routes_authenticated_person
            ->post('/form/add' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Person',
                action          => 'form_add'
            );

        $routes_authenticated_person
            ->post('/form/update' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Person',
                action          => 'form_update'
            );

        $routes_authenticated_person
            ->post('/form/remove/:id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'form_remove',
            );
            
            
    my  $routes_authenticated_contractor = $routes_authenticated->under('/contractor');

        $routes_authenticated_contractor
            ->get('/list/:filter/:related_element/:related_id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Contractor',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

        $routes_authenticated_contractor
            ->get('/form/load/:id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Contractor',
                action          => 'form_load',
            );
            
        $routes_authenticated_contractor
            ->post('/form/add' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Contractor',
                action          => 'form_add',
            );            

        $routes_authenticated_contractor
            ->post('/form/update' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Contractor',
                action          => 'form_update',
            );            
            
        $routes_authenticated_contractor
            ->post('/form/remove/:id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'form_remove',
            );

        $routes_authenticated_contractor
            ->get('/list/:filter/:related_element/:related_id')
            ->to(
                controller      => 'contractor',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

    my  $routes_authenticated_corporation = $routes_authenticated->under('/corporation');
        
        $routes_authenticated_corporation
            ->get('/list/:filter/:related_element/:related_id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

        $routes_authenticated_corporation
            ->get('/list/:filter/:related_element/:related_id')
            ->to(
                controller      => 'corporation',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

        $routes_authenticated_corporation
            ->get('/form/load/:id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'form_load',
            );
            
        $routes_authenticated_corporation
            ->post('/form/update' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'form_update',
            );            
            
        $routes_authenticated_corporation
            ->post('/form/add' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'form_add',
            ); 

        $routes_authenticated_corporation
            ->post('/form/remove/:id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::Corporation',
                action          => 'form_remove',
            );
            
    my  $routes_authenticated_provisioning_agreement = $routes_authenticated->under('/provisioning_agreement');

        $routes_authenticated_provisioning_agreement
            ->get('/list/:filter/:related_element/:related_id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::ProvisioningAgreement',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );
            
        $routes_authenticated_provisioning_agreement
            ->get('/list/:filter/:related_element/:related_id')
            ->to(
                controller      => 'provisioning_agreement',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

    my  $routes_authenticated_provisioning_obligation = $routes_authenticated->under('/provisioning_obligation');

        $routes_authenticated_provisioning_obligation
            ->get('/list/:filter/:related_element/:related_id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::ProvisioningObligation',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

        $routes_authenticated_provisioning_obligation
            ->get('/list/:filter/:related_element/:related_id')
            ->to(
                controller      => 'provisioning_obligation',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

    my  $routes_authenticated_resource_piece = $routes_authenticated->under('/resource_piece');

        $routes_authenticated_resource_piece
            ->get('/list/:filter/:related_element/:related_id' => [ format => ['json'] ] )
            ->to(
                controller      => 'Controller::API::V1::ResourcePiece',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

        $routes_authenticated_resource_piece
            ->get('/list/:filter/:related_element/:related_id')
            ->to(
                controller      => 'resource_piece',
                action          => 'list',
                filter          => 'active',
                related_element => 'person',
                related_id      => '@'
            );

}



1;
