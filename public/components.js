/*
    Constructor new
    var components = new Components();
*/
function Components (){
    this.args = [].slice.call(arguments);

    this.init = function () {
        var me = this;
        
        webix.ui({
            id   :'root',
            rows :[
                me.header.view,
                {
                    id   :'body',
                    cols :[
                        me.tree.view,
                        { view: "resizer" },
                        {
                            id  : 'main',
                            rows: []
                        }
                    ]
                },
                me.footer.view
            ]
        });
        
        controller.datatable.create( global_setting.datatable.id );
        /*
            Tree
        */
        var tree_ls = local_storage.get( me.tree.localStorage.key );
            if( tree_ls && $$(me.tree.view.id) ){
                $$( me.tree.view.id ).setState( tree_ls );
            }

        controller.tree.onSelectChange( $$( me.tree.view.id ), function( id ){
            global_setting.datatable.id = id;
            console.log( controller.datatable );
            return controller.datatable.create(id);
        });
        /*
            end Tree
        */
        $$('changeLocale').setValue( global_setting.i18n.locale );
        controller.onChange( $$('changeLocale'), function( locale ){
            console.log('locale ' + locale );
            global_setting.i18n.locale = locale;
            location.reload();
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
                    autoheight:true, 
                    data      :[
                        { id: "user", value: "Volodymyr Melnyk",
                            submenu:[
                                { id: 'profile', value: 'Profile' },
                                { id: 'logout',  value: 'LogOut' },
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
                    view :"button",
                    type :"icon",
                    icon :"sign-out",
                    label:"Logout",
                    width:100,
                    align:"right"
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
                { id:"1", value:"Dashboard" },
                { id:"2", value:"Clients",
                    data: [
                        { id:"person",       value:"Person"       },
                        { id:"contractors",  value:"Contractors"  },
                        { id:"corporations", value:"Corporations" },
                    ]
                },
                { id:"3", value: "Service Provisioning",
                    data:[
                        { id: "sp_agreements", value:"Agreements" },
                        { id: "obligations",   value:"Obligations"},
                        { id: "resourses",     value:"Resourses"  },
                    ]
                },
                { id:"4", value: "Partnership",
                    data:[
                        { id:"p_agreements",  value:"Agreements"  },
                    ]
                },
                { id:"5", value: "Billing",
                    data:[
                        { id:"invoces", value:"Invoces" },
                        { id:"invoces", value:"Top-ups & Write-offs" },
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
                size    : 10,
                group   : 5
            }
        },
        contextmenu    : {
            view: {
                view :"contextmenu",
                id   :"contextmenu",
                data:[
                    { value: "Edit" },
                    { value: "Delete" },
                ]
            }            
        },
        /*
            person
        */
        person:
        {
            view: {
                view : "datatable",
                id   : "datatable",
                //editable    :true,
                select      :"row",
                autoConfig  :true, 
                datafetch   :2,
                footer      :true,
                resizeColumn:true,
                url         :"myproxy->/person/list/all.json",
                save        :"myproxy->/person/list/all.json",           
                columns     :[
                    {
                        id    : "id",
                        footer: webix.i18n.datatable.id,
                        header: webix.i18n.datatable.id,
                        sort  : "server",
                        template:function(obj, common){
                            //console.log( "no more than "+ webix.i18n.datatable.id, obj, common );
                            return obj.id;
                        }
                    },
                    {
                        id       : "first_name",
                        footer   : localizator.datatable.first_name,
                        header   : localizator.datatable.first_name,
                        sort     : "server",
                        fillspace: true,
                        editor   : "text"
                    },
                    {
                        id       : "last_name",
                        footer   : localizator.datatable.last_name,
                        header   : localizator.datatable.last_name,
                        sort     : "server",
                        fillspace: true,
                        editor   : "text"
                    },
                    {
                        id       : "valid_since",
                        header   : localizator.datatable.valid_since,
                        footer   : localizator.datatable.valid_since,
                        sort     : "server",
                        format   : webix.i18n.dateFormatStr,
                        //startdate: new Date(),
                        fillspace: true,
                        editor   : "date",
                        template : function(obj, common){
                            //console.log( "no more than "+ webix.i18n.datatable.id, obj, common );
                            //return webix.i18n.dateFormat;
                            return obj.valid_since;
                        }                        
                    },
                    {
                        id       : "valid_till",
                        header   : localizator.datatable.valid_till,
                        footer   : localizator.datatable.valid_till,
                        sort     : "server",
                        startdate: new Date(),
                        fillspace: true,
                        editor   : "date"
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
                on:{
                    onBeforeLoad:function(){
                        if( localizator )
                            this.showOverlay( localizator.loading );
                    },
                    onAfterLoad:function(){
                        this.hideOverlay();
                        if (!this.count()) this.showOverlay( localizator.loading_no_data );                        
                    }
                },
                pager:"datatable_pager"
            },
            toolbar: {
                view: {
                    id  :"datatable_toolbar",
                    view:"toolbar",
                    cols:[
                        { view:"button", id:"add", type:"icon", icon:"plus", label:"ADD", width:100, align:"left" },
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
                                    id      :"сommunication",
                                    value   :"Communication",
                                    submenu:[
                                        {
                                            id   : 'provisioning_agreements',
                                            value: 'Provisioning Agreements',
                                            url  : '/provisioning_agreement/list/related_to/person/%s'
                                        },
                                        {
                                            id   : 'partnership_agreements',
                                            value: 'Partnership Agreements',
                                            url  : '/partnership_agreement/list/related_to/person/%s',
                                        },
                                        {
                                            id   : 'contractors',
                                            value: 'Contractors',
                                            url  : '/contractor/list/related_to/person/%s',
                                        },
                                        {
                                            id   : 'corporations',
                                            value: 'Corporations',
                                            url  : '/corporation/list/related_to/person/%s',
                                        },
                                    ]
                                }
                            ]
                        },             
                        { gravity: 2},
                        { view:"button", id:"LoadBut1", value:"PNG", width:100, align:"left" },
                        { view:"button", id:"LoadBut2", value:"PDF", width:100, align:"left" },
                        { view:"button", value:"CVS", width:100, align:"center" },
                        { view:"button", value:"Print", width:100, align:"right" },
                        { gravity: 2},
                        { view:"button", id:"LoadBut3", value:"Active", width:100, align:"left" },
                        { view:"button", value:"Archived", width:100, align:"center" },
                        { view:"button", value:"All", width:100, align:"right" }
                    ]
                }
            }          
        },
        /*
            contractors
        */
        contractors : {
            view: {
                view : "datatable",
                id   : "datatable",
                select      : "row",
                editable    : false,
                autoConfig  : true, 
                datafetch   : 2,
                resizeColumn: true,
                url         : "myproxy->/contractor/list/all.json",
                save        : "myproxy->/contractor/list/all.json",
                columns     : [
                    { id: "id",          sort:"server" },
                    { id: "name",        sort:"server", fillspace:true, editor:"text" },
                    { id: "valid_since", sort:"server", fillspace:true, editor:"date", format:webix.Date.dateToStr("%d-%m-%Y") },
                    { id: "valid_till",  sort:"server", fillspace:true, editor:"date", format:webix.Date.dateToStr("%d-%m-%Y")  },
                ],
                on:{
                    onBeforeLoad:function(){
                        if( localizator )
                            this.showOverlay( localizator.loading );
                    },
                    onAfterLoad:function(){
                        this.hideOverlay();
                        if (!this.count()) this.showOverlay( localizator.loading_no_data );                        
                    }
                },
                pager:"datatable_pager"
            },
            toolbar: {
                view: {
                    id  :"datatable_toolbar",
                    view:"toolbar",
                    cols:[
                        //{ view:"button", id:"LoadBut1", value:"PNG", width:100, align:"left" },
                        { view:"button", id:"LoadBut2", value:"PDF", width:100, align:"left" },
                        { view:"button", value:"CVS", width:100, align:"center" },
                        { view:"button", value:"Print", width:100, align:"right" },
                        { gravity: 4},
                        { view:"button", id:"LoadBut3", value:"Active", width:100, align:"left" },
                        { view:"button", value:"Archived", width:100, align:"center" },
                        { view:"button", value:"All", width:100, align:"right" }
                    ]
                }
            }          
            
        },
        /*
            corporations
        */
        corporations: {
            view: {            
                view : "datatable",
                id   : "datatable",
                editable    :true,
                autoConfig  :true, 
                datafetch   : 2,
                resizeColumn:true,
                url         :"myproxy->/corporation/list/all.json",
                save        :"myproxy->/corporation/list/all.json",
                columns     :[
                    { id: "id",          sort:"server" },
                    { id: "name",        sort:"server", fillspace:true, editor:"text" },
                    { id: "valid_since", sort:"server", fillspace:true, editor:"date", format:webix.Date.dateToStr("%d-%m-%Y") },
                    { id: "valid_till",  sort:"server", fillspace:true, editor:"date", format:webix.Date.dateToStr("%d-%m-%Y")  },
                    { id: "actions" }
                ],
                on:{
                    onBeforeLoad:function(){
                        if( localizator )
                            this.showOverlay( localizator.loading );
                    },
                    onAfterLoad:function(){
                        this.hideOverlay();
                        if (!this.count()) this.showOverlay( localizator.loading_no_data );                        
                    }
                },
                pager:"datatable_pager"
            },
            toolbar: {
                view: {
                    id  :"datatable_toolbar",
                    view:"toolbar",
                    cols:[
                        //{ view:"button", id:"LoadBut1", value:"PNG", width:100, align:"left" },
                        //{ view:"button", id:"LoadBut2", value:"PDF", width:100, align:"left" },
                        { view:"button", value:"CVS", width:100, align:"center" },
                        { view:"button", value:"Print", width:100, align:"right" },
                        { gravity: 4},
                        { view:"button", id:"LoadBut3", value:"Active", width:100, align:"left" },
                        { view:"button", value:"Archived", width:100, align:"center" },
                        { view:"button", value:"All", width:100, align:"right" }
                    ]
                }
            }          
            
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
                
            }
        },
        //
        'contractors': {
            form : {
                
            }
        },
        'corporations': {
            form : {
                
            }
        }
    };
    
}

console.log('componets.js OK');