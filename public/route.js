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
        if( action == 'list' ){
            var comp = components.datatable[datatable];
            global_setting.datatable.id = datatable;
            
            if( comp && comp.view ){
                comp.view.url = '/' +datatable + '/' + action + '/' + filter;
                if ( related_to ) {
                    comp.view.url += '/' + related_to;
                }
                if ( id ) {
                    comp.view.url += '/' + id;
                }
                comp.view.urlBase = comp.view.url;
                comp.view.url += '.json';
                console.log( "route 1", comp.view.url );
            }
            
            controller.datatable.create( datatable );
            controller.tree.select( datatable );
            
        }
        else if( action == 'form' ){
            var comp = components.form[datatable];
            var url  = "";
            var obj  = $$("main");
            
            if( filter == 'load' ){
                url = "/" + datatable + "/form/" + filter;
                if( related_to ){
                    url += "/" + related_to;
                }
                
                url += ".json";
            }
            
            //url = "/corporation/form/load/1.json";
            
            if( obj && comp && comp.form ){
                controller.datatable.remove();
                obj.addView( comp.form );
                
                // load data form 
                if (url) {
                    $$( datatable + "_add" ).load( url, "json",
                    {
                        error: function(text, data, http_request){
                            webix.message("Server error. See console.log");
                            console.log( http_request );
                        },
                        success:function(text, data, http_request){
                            var obj = $$("person_x_corporation");
                            var person_x_corporation = JSON.parse(text)['person_x_corporation'];
                            var person_x_contractor  = JSON.parse(text)['person_x_contractor'];
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