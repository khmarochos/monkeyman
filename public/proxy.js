webix.ready(function(){
/*
    Proxy
*/
    webix.proxy.myproxy = {
        $proxy:true,
        
        load:function(view, callback, params ){
            console.log( "load myproxy->", view.config.id , callback, params);
            controller.ProgressShow( view.config.id );
            webix.ajax().bind(view).get(this.source, params,
                {
                    success:function( text, data, xmlHttpRequest ){
                        view.parse( data.json() );
                        controller.ProgressHide( view.config.id );
                        return text, data, xmlHttpRequest;
                    },
                    error: function(text, data, http_request){
                        controller.ProgressHide( view.config.id );
                        webix.message("error" + text);
                        console.log("error" + text);
                        return text, data, http_request;
                    }
                }
            );

            //webix.ajax(this.source, callback, view);
        },
        
        save:function(view, update, dp, callback){
            controller.ProgressShow( view.config.id );
            console.log( "save myproxy->", view.config.id , update, dp, callback);
            /*
            webix.ajax().post(this.source, update,
                {
                    error: function(text, data, http_request){
                        webix.alert("error" + text);
                        controller.ProgressHide( view.config.id );
                    },
                    success:function(text, data, http_request){
                        webix.message("success");
                        controller.ProgressHide( view.config.id );
                    }
                }
            );
            */
            webix.ajax().post(url, update, callback);
        },
        
        result:function(state, view, dp, text, data, loader){
            webix.message(state);
            dp.processResult(state, data, details);
        }
    };
    
    console.log('proxy.js OK');

});