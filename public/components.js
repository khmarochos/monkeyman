/*
    Constructor new
    var components = new Components();
*/
function Components (){
    this.args = [].slice.call(arguments);
    
    this.login = function () {
        webix.ui({
            id  : "body",
            rows:[
                { template:"Welcome!", type:"header" },
                {},
                {
                    cols:[
                        {},
                        {
                            view    : "form",
                            id      : "login_form",
                            elements:[
                                {
                                    view : "text",
                                    name : 'person_email',
                                    label: "Email"
                                },
                                {
                                    view : "text",
                                    name : 'person_password',
                                    type : "password",
                                    label : "Password"
                                },
                                {
                                    cols:[
                                        {
                                            view : "button",
                                            value: "Login",
                                            id   : "login_btn",
                                            type : "form",
                                            click:function(){
                                                var form = $$('login_form');            
                                                if( form.validate() ){
                                                    webix.ajax().post(
                                                        "/person/login.json",
                                                        form.getValues(),
                                                        function(text,data,http) {
                                                            var res = data.json();
                                                            if( res.success == 1 ){
                                                                webix.send( res.redirect , null, "GET");
                                                            }
                                                            else{
                                                                webix.message( res.message );
                                                            }
                                                        }
                                                    );
                                                } // validate()
                                            }
                                        }
                                    ]
                                }
                            ],
                            rules:{
                                "person_email"   :webix.rules.isEmail,
                                "person_password":webix.rules.isNotEmpty
                            },                            
                        },
                        {}
                    ]
                },
                {}
            ]
        }); //  webix.ui       
    };
    
    this.init = function () {
        var me = this;
        
        webix.ui({
            id   :'root',
            type :"wide",
            rows :[
                me.header.view,
                {
                    id   :'body',
                    body : {
                        view :"layout",
                        cols :[
                            me.tree.view,
                            { view: "resizer" },
                            {
                                view   :"scrollview",
                                body   : {
                                    id     : 'main',
                                    rows   : []                                    
                                }
                            }
                        ]
                    }
                },
                me.footer.view
            ]
        });
        
        controller.datatable.create( global_setting.datatable.id );
        controller.tree.select( global_setting.datatable.id );
        /*
            Tree
        */
        var tree_ls = local_storage.get( me.tree.localStorage.key );
            if( tree_ls && $$(me.tree.view.id) ){
                $$( me.tree.view.id ).setState( tree_ls );
            }

        controller.tree.onSelectChange( $$( me.tree.view.id ), function( id ){
            global_setting.datatable.id = id;
            if( me.datatable[id] ){
                route.navigate( me.datatable[id].view.urlBase , { trigger: true });
            }
            else{
                webix.message("datatable " + id + " not exists");
            }
        });
        /*
            end Tree
        */
        // locale
        $$('changeLocale').setValue( global_setting.i18n.locale );
        controller.onChange( $$('changeLocale'), function( locale ){
            global_setting.i18n.locale = locale;
            route.navigate( "ajax/i18n",  { trigger: true });
        } );        
        // save Local Sorage
        webix.attachEvent('unload', function(){
            local_storage.set( me.tree.localStorage.key, $$( me.tree.view.id ).getState() );
            local_storage.set( global_setting.localStorage.key, global_setting );
        });
        
    };
    
    this.header = {
        view: {
            view:"toolbar",
            id  :"header",
            cols:[
                {
                    view      : "menu",
                    id        : "top.menu",
                    autoheight: true, 
                    data      : [
                        {
                            id     : "header.user",
                            value  : "",
                            submenu:[
                                {
                                    id    : 'profile',
                                    value : 'Profile'
                                }
                            ]
                        }
                    ]
                },
                {
                    view      : "combo", 
                    id        : "changeLocale",
                    label     : 'Change locale:',
                    labelWidth: 130,
                    width     : 230,
                    align     : "right",
                    value     : "en-US",
                    options: [
                        "ru-RU",
                        "en-US"
                    ]
                },					
                {
                    view : "button",
                    id   : "logout_btn",
                    type : "icon",
                    icon : "sign-out",
                    label: "Logout",
                    width: 100,
                    align: "right",
                    click:function(){
                        webix.ajax().post(
                            "/person/logout.json",
                            {},
                            function(text,data,http) {
                                var res = data.json();
                                if( res.success == 1 ){
                                    webix.send( res.redirect , null, "GET");                                    
                                }
                                else{
                                    webix.message( res.message );
                                }
                            }
                        );
                    } // click
                    
                }
            ]            
        }
    };
    
    this.footer = {
        view: {
            view:"toolbar",
            id  :"header",
            cols:[
                {
                    autoheight:true, 
                    template  :'&copy 2017'
                }
            ]
        }
    };    
    
    this.tree = {
        view: {
    		view    : "tree",
    		select  : true,
    		id      : "tree",
            gravity : 0.2,
            data    : [  
                { id:"1", value: webix.i18n.dashboard },
                { id:"2", value: webix.i18n.clients,
                    data: [
                        { id: "person",       value: webix.i18n.person       },
                        { id: "contractor",  value: webix.i18n.contractors  },
                        { id: "corporation", value: webix.i18n.corporations },
                    ]
                },
                { id:"3", value: "Service Provisioning",
                    data:[
                        { id: "provisioning_agreement" , value: "Agreements" },
                        { id: "provisioning_obligation", value: "Obligations"},
                        { id: "resource_piece",          value: "Resourses"  },
                    ]
                },
                { id:"4", value: "Partnership",
                    data:[
                        { id: "partnership_agreement",   value: "Agreements"  },
                    ]
                },
                { id:"5", value: "Billing",
                    data:[
                        { id:"invoces",        value: "Invoces" },
                        { id:"invoces",        value: "Top-ups & Write-offs" },
                    ]
                }
            ]
        },
        localStorage: {
            key: 'tree'
        }
    };
    /*
        Datatable
    */
    this.datatable = {
        datatable_pager : {
            view: {
                view    : "pager",
                template: "{common.prev()} {common.pages()} {common.next()}",
                id      : "datatable_pager",
                size    : global_setting.datatable.rows,
                group   : 10,
            }
        },
        contextmenu    : {
            view: {
                view :"contextmenu",
                id   :"contextmenu",
                data:[
                    {
                        value : webix.i18n.edit,
                        action: "load"
                    },
                    {
                        value : webix.i18n.delete,
                        action: "remove"
                    }
                ]
            }            
        },
        /*
            person
        */
        person: {
            view: {
                view        : "datatable",
                id          : "datatable",
                select      : "row",
                autoConfig  : true, 
                footer      : true,
                resizeColumn: true,
                urlBase     : "/person/list/all",
                url         : "myproxy->/person/list/all.json",
                //save        : "myproxy->/person/list/all.json",           
                columns     :[
                    {
                        id       : "id",
                        footer   : webix.i18n.datatable.id,
                        header   : webix.i18n.datatable.id,
                        sort     : "server"
                    },
                    {
                        id       : "first_name",
                        footer   : webix.i18n.datatable.first_name,
                        header   : webix.i18n.datatable.first_name,
                        sort     : "server",
                        fillspace: true
                    },
                    {
                        id       : "last_name",
                        footer   : webix.i18n.datatable.last_name,
                        header   : webix.i18n.datatable.last_name,
                        sort     : "server",
                        fillspace: true
                    },
                    {
                        id       : "valid_since",
                        header   : webix.i18n.datatable.valid_since,
                        footer   : webix.i18n.datatable.valid_since,
                        sort     : "server",
                        format   : webix.i18n.dateFormatStr,
                        fillspace: true,
                        template : function(obj, common){
                            //console.log( "no more than "+ webix.i18n.datatable.id, obj, common );
                            //return webix.i18n.dateFormat;
                            return obj.valid_since;
                        }                        
                    },
                    {
                        id       : "valid_till",
                        header   : webix.i18n.datatable.valid_till,
                        footer   : webix.i18n.datatable.valid_till,
                        sort     : "server",
                        startdate: new Date(),
                        fillspace: true
                    },
                    /*{
                        //id       : "actions",
                        fillspace: true,
                        footer   : "actions",
                        editor   : "combo",
                        //value    : 1,
                        options  : [
                            {  value:'...' },
                            {  value:'Provisioning Agreements' },
                            {  value:'Partnership Agreements' },
                            {  value:'Contractors' },
                            {  value:'Corporations' },
                        ]
                    }*/
                ],
                pager:"datatable_pager"
            },
            // toolbar person
            toolbar: {
                view: {
                    id  : "datatable_toolbar",
                    view: "toolbar",
                    cols: [
                        {
                            view : "button",
                            id   : "datatable_add",
                            type : "icon",
                            icon : "plus",
                            label: webix.i18n.add,
                            width: 100,
                            align: "left"
                        },
                        {
                            view      : "menu",
                            id        : "datatable_actions",
                            autowidth : true, 
                            autoheight: true,
                            type      : {
                                subsign:true
                            },                            
                            data       :[
                                {
                                    id      : "сommunication",
                                    value   : webix.i18n.communication,
                                    submenu:[
                                        {
                                            id   : 'provisioning_agreement',
                                            value: webix.i18n.provisioning_agreements,
                                            url  : '/provisioning_agreement/list/related_to/person/{{id}}'
                                        },
                                        {
                                            id   : 'partnership_agreement',
                                            value: webix.i18n.partnership_agreements,
                                            url  : '/partnership_agreement/list/related_to/person/{{id}}',
                                        },
                                        {
                                            id   : 'contractor',
                                            value: webix.i18n.contractors,
                                            url  : '/contractor/list/related_to/person/{{id}}',
                                        },
                                        {
                                            id   : 'corporation',
                                            value: webix.i18n.corporations,
                                            url  : '/corporation/list/related_to/person/{{id}}',
                                        },
                                    ]
                                }
                            ]
                        },             
                        { gravity: 2},
                        { view: "button", value: "PNG"  , id: "datatable_export_png"  , width:100, align:"left" },
                        { view: "button", value: "PDF"  , id: "datatable_export_pdf"  , width:100, align:"left" },
                        { view: "button", value: "Excel", id: "datatable_export_excel", width:100, align:"left" },
                        { gravity: 2},
                        {
                            view: "button", value: webix.i18n.active  , id: "datatable_load_active"  , width:100, align:"left",
                            click: function(){
                                route.navigate( "/person/list/active", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.archived, id: "datatable_load_archived", width:100, align:"center",
                            click: function(){
                                route.navigate( "/person/list/archived", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.all     , id: "datatable_load_all"     , width:100, align:"right",
                            click: function(){
                                route.navigate( "/person/list/all", { trigger: true });
                            }
                        }
                    ]
                }
            }          
        },
        /*
            contractors
        */
        contractor : {
            view: {
                view        : "datatable",
                id          : "datatable",
                select      : "row",
                editable    : false,
                autoConfig  : true,
                footer      : true,
                resizeColumn: true,
                urlBase     : "/contractor/list/all",
                url         : "/contractor/list/all.json",
                //save        : "myproxy->/contractor/list/all.json",
                columns     : [
                    {
                        id       : "id",
                        header   : webix.i18n.datatable.id,
                        footer   : webix.i18n.datatable.id,
                        sort     :"server"
                    },
                    {
                        id       : "name",
                        header   : webix.i18n.datatable.name,
                        fotter   : webix.i18n.datatable.name,
                        sort     : "server",
                        fillspace: true,
                        editor   : "text"
                    },
                    {
                        id       : "valid_since",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_since,
                        footer   : webix.i18n.datatable.valid_since
                    },
                    {
                        id       : "valid_till",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_till,
                        footer   : webix.i18n.datatable.valid_till
                    },
                ],
                pager: "datatable_pager"
            },
            // toolbar contractors
            toolbar: {
                view: {
                    id  : "datatable_toolbar",
                    view: "toolbar",
                    cols:[
                        {
                            view : "button",
                            id   : "datatable_add",
                            type : "icon",
                            icon : "plus",
                            label: webix.i18n.add,
                            width: 100,
                            align: "left"
                        },                        
                        {
                            view      : "menu",
                            id        : "datatable_actions",
                            autowidth : true, 
                            autoheight: true,
                            type      : {
                                subsign:true
                            },                            
                            data       :[
                                {
                                    id      : "сommunication",
                                    value   : webix.i18n.communication,
                                    submenu:[
                                        {
                                            id   : 'provisioning_agreement',
                                            value: webix.i18n.provisioning_agreements,
                                            url  : '/provisioning_agreement/list/related_to/contractor/{{id}}'
                                        },
                                        {
                                            id   : 'partnership_agreement',
                                            value: webix.i18n.partnership_agreements,
                                            url  : '/partnership_agreement/list/related_to/contractor/{{id}}',
                                        },
                                        {
                                            id   : 'person',
                                            value: webix.i18n.person,
                                            url  : '/person/list/related_to/contractor/{{id}}',
                                        },
                                        {
                                            id   : 'corporation',
                                            value: webix.i18n.corporations,
                                            url  : '/corporation/list/related_to/person/{{id}}',
                                        },
                                    ]
                                }
                            ]
                        },             
                        { gravity: 2},                        
                        { view: "button", value: "PNG"  , id: "datatable_export_png"  , width:100, align:"left" },
                        { view: "button", value: "PDF"  , id: "datatable_export_pdf"  , width:100, align:"left" },
                        { view: "button", value: "Excel", id: "datatable_export_excel", width:100, align:"left" },
                        { gravity: 2},
                        {
                            view: "button", value: webix.i18n.active  , id: "datatable_load_active"  , width:100, align:"left",
                            click: function(){
                                route.navigate( "/contractor/list/active", { trigger: true });                                
                            }
                        },
                        {
                            view: "button", value: webix.i18n.archived, id: "datatable_load_archived", width:100, align:"center",
                            click: function(){
                                route.navigate( "/contractor/list/archived", { trigger: true });                                
                            }
                        },
                        {
                            view: "button", value: webix.i18n.all     , id: "datatable_load_all"     , width:100, align:"right",
                            click: function(){
                                route.navigate( "/contractor/list/all", { trigger: true });                                
                            }
                        }
                    ]
                }
            }          
            
        },
        /*
            corporations
        */
        corporation: {
            view: {            
                view        : "datatable",
                id          : "datatable",
                editable    : false,
                autoConfig  : true,
                footer      : true,  
                resizeColumn: true,
                urlBase     : "/corporation/list/all",
                url         : "/corporation/list/all.json",
                //save        : "myproxy->/corporation/list/all.json",
                columns     : [
                    {
                        id       : "id",
                        header   : webix.i18n.datatable.id,
                        footer   : webix.i18n.datatable.id,
                        sort     :"server"
                    },
                    {
                        id       : "name",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.name,
                        footer   : webix.i18n.datatable.name,
                        
                    },
                    {
                        id       : "valid_since",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_since,
                        footer   : webix.i18n.datatable.valid_since,
                    },
                    {
                        id       : "valid_till",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_till,
                        footer   : webix.i18n.datatable.valid_till,
                    }
                ],
                pager: "datatable_pager"
            },
            // toolbar corporations
            toolbar: {
                view: {
                    id  : "datatable_toolbar",
                    view: "toolbar",
                    cols: [
                        {
                            view : "button",
                            id   : "datatable_add",
                            type : "icon",
                            icon : "plus",
                            label: webix.i18n.add,
                            width: 100,
                            align: "left"
                        },                        
                        {
                            view      : "menu",
                            id        : "datatable_actions",
                            autowidth : true, 
                            autoheight: true,
                            type      : {
                                subsign:true
                            },                            
                            data       :[
                                {
                                    id      : "сommunication",
                                    value   : webix.i18n.communication,
                                    submenu:[
                                        {
                                            id   : 'provisioning_agreement',
                                            value: webix.i18n.provisioning_agreements,
                                            url  : '/provisioning_agreement/list/related_to/corporation/{{id}}'
                                        },
                                        {
                                            id   : 'partnership_agreement',
                                            value: webix.i18n.partnership_agreements,
                                            url  : '/partnership_agreement/list/related_to/corporation/{{id}}',
                                        },
                                        {
                                            id   : 'person',
                                            value: webix.i18n.person,
                                            url  : '/person/list/related_to/corporation/{{id}}',
                                        },
                                        {
                                            id   : 'corporation',
                                            value: webix.i18n.corporations,
                                            url  : '/contractor/list/related_to/corporation/{{id}}',
                                        },
                                    ]
                                }
                            ]
                        },
                        { gravity: 2},
                        { view: "button", value: "PNG"  , id: "datatable_export_png"  , width:100, align:"left" },
                        { view: "button", value: "PDF"  , id: "datatable_export_pdf"  , width:100, align:"left" },
                        { view: "button", value: "Excel", id: "datatable_export_excel", width:100, align:"left" },
                        { gravity: 2},
                        {
                            view: "button", value: webix.i18n.active  , id: "datatable_load_active"  , width:100, align:"left",
                            click: function(){
                                route.navigate( "/corporation/list/active", { trigger: true });                                
                            }
                        },
                        {
                            view: "button", value: webix.i18n.archived, id: "datatable_load_archived", width:100, align:"center",
                            click: function(){
                                route.navigate( "/corporation/list/archived", { trigger: true });                                
                            }
                        },
                        {
                            view: "button", value: webix.i18n.all     , id: "datatable_load_all"     , width:100, align:"right",
                            click: function(){
                                route.navigate( "/corporation/list/all", { trigger: true });                                
                            }
                        }
                    ]
                }
            }          
            
        },
        /*
            provisioning_agreement
        */
        provisioning_agreement: {
            view : {
                view        : "datatable",
                id          : "datatable",
                editable    : false,
                autoConfig  : true,
                footer      : true,  
                resizeColumn: true,
                urlBase     : "/provisioning_agreement/list/all",
                url         : "/provisioning_agreement/list/all.json",
                //save        : "myproxy->/provisioning_agreement/list/all.json",
                columns     : [
                    {
                        id       : "id",
                        header   : webix.i18n.datatable.id,
                        footer   : webix.i18n.datatable.id,
                        sort     :"server"
                    },
                    {
                        id       : "number",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.number,
                        footer   : webix.i18n.datatable.number,
                        
                    },
                    {
                        id       : "valid_since",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_since,
                        footer   : webix.i18n.datatable.valid_since,
                    },
                    {
                        id       : "valid_till",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_till,
                        footer   : webix.i18n.datatable.valid_till,
                    },
                    {
                        id       : "client",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.client,
                        footer   : webix.i18n.datatable.client,
                    },
                    {
                        id       : "provider",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.provider,
                        footer   : webix.i18n.datatable.provider,
                    }                                        
                ],
                pager: "datatable_pager"                
            },
            // toolbar provisioning_agreement
            toolbar: {
                view: {
                    id  : "datatable_toolbar",
                    view: "toolbar",
                    cols: [
                        {
                            view : "button",
                            id   : "datatable_add",
                            type : "icon",
                            icon : "plus",
                            label: webix.i18n.add,
                            width: 100,
                            align: "left"
                        },                        
                        {
                            view      : "menu",
                            id        : "datatable_actions",
                            autowidth : true, 
                            autoheight: true,
                            type      : {
                                subsign:true
                            },                            
                            data       :[
                                {
                                    id      : "сommunication",
                                    value   : webix.i18n.communication,
                                    submenu:[
                                        {
                                            id   : 'person',
                                            value: webix.i18n.person,
                                            url  : '/person/list/related_to/provisioning_agreement/{{id}}',
                                        },
                                        {
                                            id   : 'provisioning_obligation',
                                            value: webix.i18n.provisioning_obligation,
                                            url  : '/provisioning_obligation/list/related_to/provisioning_agreement/{{id}}',
                                        },
                                        {
                                            id   : 'resource_piece',
                                            value: webix.i18n.resource_piece,
                                            url  : '/resource_piece/list/related_to/provisioning_agreement/{{id}}',
                                        }
                                    ]
                                }
                            ]
                        },
                        { gravity: 2},
                        { view: "button", value: "PNG"  , id: "datatable_export_png"  , width:100, align:"left" },
                        { view: "button", value: "PDF"  , id: "datatable_export_pdf"  , width:100, align:"left" },
                        { view: "button", value: "Excel", id: "datatable_export_excel", width:100, align:"left" },
                        { gravity: 2},
                        {
                            view: "button", value: webix.i18n.active  , id: "datatable_load_active"  , width:100, align:"left",
                            click: function(){
                                route.navigate( "/provisioning_agreement/list/active", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.archived, id: "datatable_load_archived", width:100, align:"center",
                            click: function(){
                                route.navigate( "/provisioning_agreement/list/archived", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.all     , id: "datatable_load_all"     , width:100, align:"right",
                            click: function(){
                                route.navigate( "/provisioning_agreement/list/all", { trigger: true });
                            }
                        }
                    ]
                }
            } // toolbar
        },
        /*
            provisioning_obligation
        */
        provisioning_obligation: {
            view: {
                view        : "datatable",
                id          : "datatable",
                editable    : false,
                autoConfig  : true,
                footer      : true,  
                resizeColumn: true,
                urlBase     : "/provisioning_obligation/list/all",
                url         : "/provisioning_obligation/list/all.json",
                //save        : "myproxy->/provisioning_obligation/list/all.json",
                columns     : [
                    {
                        id       : "id",
                        header   : webix.i18n.datatable.id,
                        footer   : webix.i18n.datatable.id,
                        sort     :"server"
                    },
                    {
                        id       : "valid_since",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_since,
                        footer   : webix.i18n.datatable.valid_since,
                    },
                    {
                        id       : "valid_till",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_till,
                        footer   : webix.i18n.datatable.valid_till,
                    },                    
                    {
                        id       : "provisioning_agreements",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.provisioning_agreements,
                        footer   : webix.i18n.provisioning_agreements,
                    },
                    {
                        id       : "service",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.service,
                        footer   : webix.i18n.datatable.service,
                    },
                    {
                        id       : "quantity",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.quantity,
                        footer   : webix.i18n.datatable.quantity
                    }
                ]
                
            },
            // toolbar provisioning_obligation
            toolbar: {
                view: {
                    id  : "datatable_toolbar",
                    view: "toolbar",
                    cols: [
                        {
                            view : "button",
                            id   : "datatable_add",
                            type : "icon",
                            icon : "plus",
                            label: webix.i18n.add,
                            width: 100,
                            align: "left"
                        },                        
                        {
                            view      : "menu",
                            id        : "datatable_actions",
                            autowidth : true, 
                            autoheight: true,
                            type      : {
                                subsign:true
                            },                            
                            data       :[
                                {
                                    id      : "сommunication",
                                    value   : webix.i18n.communication,
                                    submenu:[
                                        {
                                            id   : 'provisioning_agreement',
                                            value: webix.i18n.provisioning_agreements,
                                            url  : '/provisioning_agreement/list/related_to/provisioning_obligation/{{id}}',
                                        },
                                        {
                                            id   : 'resource_piece',
                                            value: webix.i18n.resource_piece,
                                            url  : '/resource_piece/list/related_to/provisioning_obligation/{{id}}',
                                        }
                                    ]
                                }
                            ]
                        },
                        { gravity: 2},
                        { view: "button", value: "PNG"  , id: "datatable_export_png"  , width:100, align:"left" },
                        { view: "button", value: "PDF"  , id: "datatable_export_pdf"  , width:100, align:"left" },
                        { view: "button", value: "Excel", id: "datatable_export_excel", width:100, align:"left" },
                        { gravity: 2},
                        {
                            view: "button", value: webix.i18n.active  , id: "datatable_load_active"  , width:100, align:"left",
                            click: function(){
                                route.navigate( "/provisioning_obligation/list/active", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.archived, id: "datatable_load_archived", width:100, align:"center",
                            click: function(){
                                route.navigate( "/provisioning_obligation/list/archived", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.all     , id: "datatable_load_all"     , width:100, align:"right",
                            click: function(){
                                route.navigate( "/provisioning_obligation/list/all", { trigger: true });
                            }
                        }
                    ]
                }
            } // toolbar           
        },
        /*
            resource_piece
        */
        resource_piece: {
            view: {
                view        : "datatable",
                id          : "datatable",
                editable    : false,
                autoConfig  : true,
                footer      : true,  
                datafetch   : global_setting.datatable.rows,
                resizeColumn: true,
                urlBase     : "/resource_piece/list/all",
                url         : "/resource_piece/list/all.json",
                //save        : "myproxy->/resource_piece/list/all.json",
                columns     : [
                    {
                        id       : "id",
                        header   : webix.i18n.datatable.id,
                        footer   : webix.i18n.datatable.id,
                        sort     :"server"
                    },
                    {
                        id       : "valid_since",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_since,
                        footer   : webix.i18n.datatable.valid_since,
                    },
                    {
                        id       : "valid_till",
                        sort     : "server",
                        fillspace: true,
                        editor   : "date",
                        header   : webix.i18n.datatable.valid_till,
                        footer   : webix.i18n.datatable.valid_till,
                    },
                    {
                        id       : "resource_type",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.resource_type,
                        footer   : webix.i18n.datatable.resource_type,
                    },
                    {
                        id       : "resource_handle",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.resource_handle,
                        footer   : webix.i18n.datatable.resource_handle,
                    },
                    {
                        id       : "resource_host",
                        sort     : "server",
                        fillspace: true,
                        editor   : "text",
                        header   : webix.i18n.datatable.resource_host,
                        footer   : webix.i18n.datatable.resource_host,
                    },
                ]                
            },
            // toolbar
            toolbar: {
                view: {
                    id  : "datatable_toolbar",
                    view: "toolbar",
                    cols: [
                        {
                            view : "button",
                            id   : "datatable_add",
                            type : "icon",
                            icon : "plus",
                            label: webix.i18n.add,
                            width: 100,
                            align: "left"
                        },                        
                        {
                            view      : "menu",
                            id        : "datatable_actions",
                            autowidth : true, 
                            autoheight: true,
                            type      : {
                                subsign:true
                            },                            
                            data       :[
                                {
                                    id      : "сommunication",
                                    value   : webix.i18n.communication,
                                    submenu:[
                                        {
                                            id   : 'provisioning_agreement',
                                            value: webix.i18n.provisioning_agreements,
                                            url  : '/provisioning_agreement/list/related_to/resource_piece/{{id}}',
                                        },
                                        {
                                            id   : 'provisioning_obligation',
                                            value: webix.i18n.provisioning_obligation,
                                            url  : '/provisioning_obligation/list/related_to/resource_piece/{{id}}',
                                        }
                                    ]
                                }
                            ]
                        },
                        { gravity: 2},
                        { view: "button", value: "PNG"  , id: "datatable_export_png"  , width:100, align:"left" },
                        { view: "button", value: "PDF"  , id: "datatable_export_pdf"  , width:100, align:"left" },
                        { view: "button", value: "Excel", id: "datatable_export_excel", width:100, align:"left" },
                        { gravity: 2},
                        {
                            view: "button", value: webix.i18n.active  , id: "datatable_load_active"  , width:100, align:"left",
                            click: function(){
                                route.navigate( "/resource_piece/list/active", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.archived, id: "datatable_load_archived", width:100, align:"center",
                            click: function(){
                                route.navigate( "/resource_piece/list/archived", { trigger: true });
                            }
                        },
                        {
                            view: "button", value: webix.i18n.all     , id: "datatable_load_all"     , width:100, align:"right",
                            click: function(){
                                route.navigate( "/resource_piece/list/all", { trigger: true });
                            }
                        }
                    ]
                }                
            } // toolbar resource_piece           
        }
        
    };
    /*
        Form
    */    
    this.form = {
        //
        'login':{
            form: {
                
            }            
        },
        //
        'person': {
            form : {
                id        : "form",
                scroll    : "y",
                action    : "add",
                rows      :[
                    {
                        template : webix.i18n.form.person.header,
                        type     : "header"
                    },
                    {
                        view        : "form",
                        id          : "person_add",
                        child_obj   : ['person_x_email', 'person_x_phone'],
                        afterRender : [
                            {
                                'timezone.area': [
                                    {
                                        'fn'     : 'controller.timezone.getArea',
                                        'context': 'controller.timezone',
                                        'data'   : 'options'
                                    },
                                    {
                                        'fn'     : 'controller.timezone.onSelect',
                                        'context': 'controller.timezone',
                                        'id'     : 'timezone.area',
                                        'bind'   : {
                                            'id'   : 'timezone.city',
                                            'data' : 'options'
                                        }
                                    },
                                ]               
                            }
                        ],
                        baseURL     : "/person/form",
                        elements :[
                            {
                                view :"fieldset", 
                                label: webix.i18n.form.basic,
                                body : {
                                    rows : [
                                        {
                                            cols : [
                                                {
                                                    view : "text",
                                                    label: webix.i18n.datatable.first_name,
                                                    name : 'first_name',
                                                    labelPosition:"top"
                                                },
                                                {
                                                    view : "text",
                                                    label: webix.i18n.datatable.last_name,
                                                    name : 'last_name',
                                                    labelPosition:"top"
                                                }                                                                        
                                            ]                                        
                                        },
                                        {
                                            cols:[
                                                {
                                                    view : "datepicker",
                                                    label: webix.i18n.datatable.valid_since,
                                                    timepicker: false,
                                                    name : 'valid_since',
                                                    labelPosition:"top"
                                                },
                                                {
                                                    view : "datepicker",
                                                    label: webix.i18n.datatable.valid_till,
                                                    timepicker: false,
                                                    name : 'valid_till',
                                                    labelPosition:"top"
                                                },
                                            ]                                                                        
                                        },
                                        {
                                            cols:[
                                                {
                                                    view : "text",
                                                    label: webix.i18n.form.password,
                                                    type : "password",
                                                    name : 'password',
                                                    labelPosition:"top"
                                                },
                                                {
                                                    view   : "richselect",
                                                    id     : "language_id",
                                                    label  : webix.i18n.language,
                                                    name   : "language_id",
                                                    options: "/snippet-component/0/language.json",
                                                    labelPosition:"top"
                                                }                                            ]                                                                       
                                        },
                                        {
                                            rows:[
                                                { template: webix.i18n.timezone, type:"section" },
                                                {
                                                    cols   : [
                                                        {
                                                            view   :"richselect",
                                                            id     : "timezone.area",
                                                            label  : webix.i18n.area,
                                                            name   : "timezone.area",
                                                            labelPosition:"top"
                                                        },
                                                        {
                                                            view   :"richselect",
                                                            id     : "timezone.city",
                                                            label  : webix.i18n.city,
                                                            name   : "timezone.city",
                                                            labelPosition:"top"
                                                        }
                                                    ]
                                                },
                                            ]
                                        }
                                    ] // rows
                                }// body                            
                            },
                            {
                                view : "button",
                                value: webix.i18n.form.send,
                                id   : "send_form",
                                type : "form"
                            }                        
    
                        ], // elements
                        rules:{
                            "first_name"   : webix.rules.isNotEmpty,
                            "last_name"    : webix.rules.isNotEmpty,
                            "timezone.area": webix.rules.isNotEmpty,
                            "timezone.city": webix.rules.isNotEmpty,
                        } 
                    }, // form
                    {}
                ]
            }
        },
        //
        'contractor': {
            form : {
                id     : "form",
                action : "add",
                rows   :[
                    {
                        template : webix.i18n.form.contractor.header,
                        type     : "header"
                    },
                    {
                        view     : "form",
                        id       : "contractor_add",
                        child_obj: ['person_x_contractor'],
                        baseURL  : "/contractor/form",
                        elements : [
                            {
                                view :"fieldset", 
                                label: webix.i18n.form.basic,
                                body : {
                                    rows: [
                                        {
                                            cols:[
                                                {
                                                    view : "text",
                                                    label: webix.i18n.datatable.name,
                                                    name : 'name',
                                                    labelPosition:"top"
                                                },
                                                {
                                                    view   :"richselect", 
                                                    label  : webix.i18n.form.contractor.type_id,
                                                    name   : 'contractor_type_id',
                                                    options:[
                                                        { "id":1, "value":"1" },
                                                        { "id":2, "value":"2" },
                                                        { "id":3, "value":"3" },
                                                    ],
                                                    labelPosition:"top"
                                                },                                    
                                                {
                                                    view : "text",
                                                    label: webix.i18n.datatable.provider,
                                                    name : 'provider',
                                                    labelPosition:"top"
                                                },
                                            ]
                                        },
                                        {
                                            cols:[
                                                {
                                                    view : "datepicker",
                                                    label: webix.i18n.datatable.valid_since,
                                                    timepicker: false,
                                                    name : 'valid_since',
                                                    labelPosition:"top"
                                                },
                                                {
                                                    view : "datepicker",
                                                    label: webix.i18n.datatable.valid_till,
                                                    timepicker: false,
                                                    name : 'valid_till',
                                                    labelPosition:"top"
                                                },
                                            ]                                
                                        },                                        
                                    ] //  rows
                                } // body 
                            },                          
                            {
                                view : "button",
                                value: webix.i18n.form.send,
                                id   : "send_form",
                                type : "form"
                            }                            
                        ],
                        rules:{
                            //"valid_since":webix.rules.isNotEmpty,
                            "name" :webix.rules.isNotEmpty
                        },                          
                    },
                    {}
                ]
            }
        },
        
        'corporation': {
            form : {
                id     : "form",
                action : "add",
                rows   :[
                    {
                        template : webix.i18n.form.corporation.header,
                        type     : "header"
                    },
                    {
                        view     : "form",
                        id       : "corporation_add",
                        child_obj: ['person_x_corporation','corporation_x_contractor'],
                        baseURL  : "/corporation/form",
                        elements :[
                            {
                                view :"fieldset", 
                                label: webix.i18n.form.basic,
                                body : {
                                    rows: [
                                        {
                                            cols:[
                                                {
                                                    view : "text",
                                                    label: webix.i18n.datatable.name,
                                                    name : 'name',
                                                    labelPosition:"top"
                                                },                                  
                                                {
                                                    view : "text",
                                                    label: webix.i18n.datatable.provider,
                                                    name : 'provider',
                                                    labelPosition:"top"
                                                },
                                            ]
                                        },
                                        {
                                            cols:[
                                                {
                                                    view : "datepicker",
                                                    label: webix.i18n.datatable.valid_since,
                                                    timepicker: false,
                                                    name : 'valid_since',
                                                    labelPosition:"top"
                                                },
                                                {
                                                    view : "datepicker",
                                                    label: webix.i18n.datatable.valid_till,
                                                    timepicker: false,
                                                    name : 'valid_till',
                                                    labelPosition:"top"
                                                },
                                            ]                                
                                        },                                        
                                    ] // body rows
                                }
                            },
                            {
                                view : "button",
                                id   : "send_form",
                                value: webix.i18n.form.send,
                                type : "form"
                            },
                        ],
                        rules:{
                            //"valid_since":webix.rules.isNotEmpty,
                            "name" :webix.rules.isNotEmpty
                        } 
                    },  
                    {}
                ]
            }
        },
        
        /* snippets*/
        /*
            person_x_corporation
        */
        'corporation_x_contractor': {
            view    : "form",
            baseURL : "/snippet-component/{{id}}/corporation_x_contractor.json",
            cols    : [
                {
                    view   :"richselect", 
                    label  : webix.i18n.contractors,
                    options: "/contractor/list/all.json",
                    name   : "contractor_id",
                    labelPosition:"top"
                },                
                {
                    view : "datepicker",
                    label: webix.i18n.datatable.valid_till,
                    timepicker: false,
                    name : 'valid_till',
                    labelPosition:"top"
                }
            ]
        },
        
        'person_x_corporation':{
            view    : "form",
            baseURL : "/snippet-component/{{id}}/corporation.json",
            cols:[
                {
                    view   :"richselect", 
                    label  : webix.i18n.person,
                    options: "/person/list/all.json",
                    name   : "person_id",
                    labelPosition:"top"
                },
                {
                    view : "datepicker",
                    label: webix.i18n.datatable.valid_till,
                    timepicker: false,
                    name : 'valid_till',
                    labelPosition:"top"
                },
                {
                    view  : "checkbox",
                    labelPosition:"top",
                    name  : "admin",
                    label : "Admin", 
                    value : "0"
                },        
                {
                    view  : "checkbox",
                    labelPosition:"top",
                    name  : "billing",
                    label : "Bill", 
                    value : "0"
                },                       
                {
                    view  : "checkbox",
                    labelPosition:"top",
                    name  : "tech",
                    label : "tech", 
                    value : "0"
                },
                {
                    view : "button",
                    value: webix.i18n.delete,
                    click: function(){
                        var obj = $$("person_x_corporation");
                        if(obj) obj.removeView( this.getParentView().config.id );
                    }                    
                }
            ]            
        },
        /*
            person_x_contractor
        */
        'person_x_contractor' : {
            view    : "form",
            baseURL : "/snippet-component/{{id}}/person_x_contractor.json",
            cols    :[
                {
                    view   :"richselect", 
                    label  : webix.i18n.person,
                    options: "/person/list/all.json",
                    name   : "person_id",
                    labelPosition:"top"
                },
                {
                    view : "datepicker",
                    label: webix.i18n.datatable.valid_till,
                    timepicker: false,
                    name : 'valid_till',
                    labelPosition:"top"
                },

                {
                    view  : "checkbox",
                    labelPosition:"top",
                    name  : "admin",
                    label : "Admin", 
                    value : "0"
                },        
                {
                    view  : "checkbox",
                    labelPosition:"top",
                    name  : "billing",
                    label : "Bill", 
                    value : "0"
                },                       
                {
                    view  : "checkbox",
                    labelPosition:"top",
                    name  : "tech",
                    label : "tech", 
                    value : "0"
                },
                {
                    view : "button",
                    value: webix.i18n.delete,
                    click: function(){
                        var obj = $$("person_x_contractor");
                        if(obj) obj.removeView( this.getParentView().config.id );
                    }                    
                }
            ]             
        },
        /*
            person email
        */
        'person_x_email' : {
            view    : "form",
            baseURL : "/snippet-component/{{id}}/email.json",
            cols:[
                {
                    view   : "text", 
                    label  : webix.i18n.form.email,
                    name   : "email",
                    labelPosition:"top"
                },
                {
                    view : "datepicker",
                    label: webix.i18n.datatable.valid_till,
                    timepicker: false,
                    name : 'valid_till',
                    labelPosition:"top"
                },                
                {
                    view : "button",
                    value: webix.i18n.delete,
                    click: function(){
                        var obj = $$("person_x_email");
                        if(obj) obj.removeView( this.getParentView().config.id );
                    }                    
                }                
            ]
        },  
        /*
            person phone
        */
        'person_x_phone' : {
            view    : "form",
            baseURL : "/snippet-component/{{id}}/phone.json",
            cols    :[
                {
                    view   : "text", 
                    label  : webix.i18n.datatable.phone,
                    name   : "phone",
                    placeholder  :"380 XXX-XX-XX",
                    labelPosition:"top"
                },
                {
                    view : "datepicker",
                    label: webix.i18n.datatable.valid_till,
                    timepicker: false,
                    name : 'valid_till',
                    labelPosition:"top"
                },
                
                {
                    view : "button",
                    value: webix.i18n.delete,
                    click: function(){
                        var obj = $$("person_x_phone");
                        if(obj) obj.removeView( this.getParentView().config.id );
                    }                    
                }                
            ]
        },
        /*
            timezone
        */
    };
    
}

console.log('componets.js OK');