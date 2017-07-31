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
            
            if( filter == 'remove' ) {
                
            }
            
            if( obj && comp && comp.form ){
                controller.datatable.remove();
                obj.addView( comp.form );
                
                if (url) $$( datatable + "_add" ).define("url", url);
                $$("form").define("action", filter);
            }
            console.log( "form", url );
        }
        
        console.log("route", datatable, action, filter, related_to, id);        
    }
    
});

console.log("route.js OK");