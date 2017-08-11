var Route = Backbone.Router.extend({
    routes: {
        ""                                               : "index",
        "login"                                          : "login",
        "ajax/i18n"                                      : "i18n",
        ":datatable/:action/:filter(/:related_to)(/:id)" : "main"
    },
    
    i18n: function () {
        var url = "/ajax/i18n?language_code=" + global_setting.i18n.locale;
        controller.ajax.get( url , function( data ) {
            if( data.success ){
                console.log("route i18n");
                data.redirect = data.redirect ? data.redirect : "/person/list/all";
                route.navigate( data.redirect, { trigger: true });
                location.reload();
            }
        });
    },

    index: function () {
        //route.navigate( "/person/list/all", { trigger: true });
        console.log("route - index");
    },

    login: function () {
        console.log("route - login");
    },

    main: function ( datatable, action, filter, related_to, id ) {
        console.log("route main");
        var url = '/' +datatable + '/' + action + '/' + filter;
        if( related_to ){
            url += "/" + related_to;
        }        
        if ( id ) {
            url += '/' + id;
        }
            
        if( action == 'list' ){
            var comp = components.datatable[datatable];
            global_setting.datatable.id = datatable;
            
            if( comp && comp.view ){
                comp.view.urlBase = url;
                comp.view.url = url + '.json';
                console.log( "route 1", comp.view.url );
            }
            
            controller.datatable.create( datatable );
            controller.tree.select( datatable );
            
        }
        else if( action == 'form' ){
            var comp      = components.form[datatable];
            var obj       = $$("main");
            var form_name = datatable + "_add";            
            url += ".json";
                        
            if( obj && comp ){                
                
                if(comp.form) {
                
                    //if( controller.form.start( comp.form ) ){
                        /*
                            table_x_table
                        */
                        var child_obj = [];
                        if( filter != "remove"){
                            controller.datatable.remove();
                            controller.form.start( comp.form )
                            child_obj = controller.form.getSnippet( form_name );
                        }                        
                        
                        if( filter == "load" ){        

                            $$("form").define("action", "update");
                            
                            controller.form.load( form_name, url, function( data1 ){

                                if( child_obj ) {                                    
                                    child_obj.forEach( function( item, i ){
                                        var url_snippet = components.form[ item ].baseURL;
                                        controller.form.setSnippet( form_name, item );                                        
                                        if( url_snippet ) {                                            
                                            url_snippet = url_snippet.replace('{{id}}', id || related_to );

                                            controller.form.load( form_name, url_snippet, function( data2 ){
                                                controller.form.setSnippetItem( item, data2.data );
                                                $$( form_name ).setValues( data1.data );
                                            });
                                        }
                                    });                                    
                                }
                                
                            });
                            
                            filter = "update";

                        }
                        else if( filter == "remove" ){
                            webix.confirm({
                                title   : "Remove",
                                ok      : "Yes",
                                cancel  : "No",                
                                text    : "Are you sure?",                                
                                callback: function( e ){
                                    if( e ){
                                        console.log( "data1", url );
                                        controller.form.ajax( url, function( data ){
                                            if( data.redirect ){
                                                route.navigate( data.redirect , { trigger: true });
                                            }
                                        });
                                    }
                                }
                            });                            
                        }
                        else{                            
                            if( child_obj ) {
                                child_obj.forEach( function( item, i ){
                                    controller.form.setSnippet( form_name, item );
                                });
                            }
                        }
                        
                        if( filter != "remove"){
                            controller.form.end( form_name );
                        }
                    
                    //}
                }
                
                if( $$("form") ) $$("form").define("action", filter);
                
                return false;
            }
            //console.log( "form", url );
        }        
        console.log("route", datatable, action, filter, related_to, id);        
    }
    
});

console.log("route.js OK");