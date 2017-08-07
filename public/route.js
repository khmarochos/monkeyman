var Route = Backbone.Router.extend({
    routes: {
        ""                                               : "index",
        "login"                                          : "login",
        ":datatable/:action/:filter(/:related_to)(/:id)" : "main"
    },

    index: function () {
        //route.navigate( "/person/list/all", { trigger: true });
        console.log("route - index");
    },

    login: function () {
        console.log("route - login");
    },

    main: function ( datatable, action, filter, related_to, id ) {
        var url = '/' +datatable + '/' + action + '/' + filter;
        if( related_to ){
            url += "/" + related_to;
        }        
        if ( id ) {
            url += '/' + id;
        }
        //url += ".json";
            
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
                    controller.datatable.remove();
                    if( controller.form.start( comp.form ) ){
                        /*
                            table_x_table
                        */
                        var child_obj = controller.form.getSnippet( form_name );
                        if( filter == "load" ){
                            $$("form").define("action", "update");
                            console.log( "url", url, form_name );
                            
                            controller.form.load( form_name, url, function( data1 ){
                                console.log( "data1", data1 );
                                if( child_obj ) {
                                    
                                    child_obj.forEach( function( item, i ){
                                        var url_snippet = components.form[ item ].baseURL;
                                        controller.form.setSnippet( form_name, item );
                                        
                                        console.log( "url_snippet", url_snippet );
                                        
                                        if( url_snippet ) {                                            
                                            url_snippet = url_snippet.replace('{{id}}', id || related_to );

                                            controller.form.load( form_name, url_snippet, function( data2 ){
                                                console.log( "data2", data2 );
                                                controller.form.setSnippetItem( item, data2.data );
                                                $$( form_name ).setValues( data1.data );
                                            });
                                        }
                                    });
                                    
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
                        controller.form.end( form_name );
                    }
                }
                
                /*
                    add to form [table]_x_[table]
                */

                return false;
                
                // load data form 
                if (url) {
                    controller.form.load( form_name, url, function( data ){
                            var obj = $$("person_x_corporation");
                            var person_x_corporation = data['person_x_corporation'];
                            var person_x_contractor  = data['person_x_contractor'];
                            
                            if( person_x_contractor ){
                                obj = $$("person_x_contractor");
                            }
                            else if( person_x_corporation ) {
                                obj = $$("person_x_corporation");
                            }
    
                            if( person_x_corporation ){
                                person_x_corporation.forEach( function( item, i ){
                                    console.log( item );
                                    var copy  = webix.copy( components.form.person_x_corporation );
                                    var form  = "form_" + i;
                                    copy.form = form;
                                    copy.id   = form;
                                    if(obj) obj.addView( copy );
                                    $$(form).setValues({
                                        id       : item.id,
                                        admin    : item.admin, 
                                        person_id: item.person_id,
                                        bill     : item.bill,
                                        tech     : item.tech 
                                    });
                                });
                            }
                            
                            if( person_x_contractor ){
                                person_x_contractor.forEach( function( item, i ){
                                    console.log( item );
                                    var copy  = webix.copy( components.form.person_x_contractor );
                                    var form  = "form_" + i;
                                    copy.form = form;
                                    copy.id   = form;
                                    if(obj) obj.addView( copy );
                                    $$(form).setValues({
                                        id       : item.id,
                                        admin    : item.admin, 
                                        person_id: item.person_id,
                                        bill     : item.bill,
                                        tech     : item.tech 
                                    });
                                });
                            }                        
                    });
                }
                // end load data form 
                $$("form").define("action", filter);
            }
            console.log( "form", url );
        }
        
        console.log("route", datatable, action, filter, related_to, id);        
    }
    
});

console.log("route.js OK");