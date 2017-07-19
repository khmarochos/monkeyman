webix.ready(function(){
/*
    Proxy
*/
    webix.proxy.myproxy = {
        $proxy:true,
        
        load:function(view, callback){
            //console.log( 'proxy', view, callback );
            webix.ajax(
                this.source,
                callback,
                view
            );
        },
        
        save:function(view, update, dp, callback){
            webix.ajax().post(this.source, update,
                {
                    error: function(text, data, http_request){
                      webix.alert("error" + text);
                    },
                    success:function(text, data, http_request){
                      webix.message("success");
                    }
                }
            );
        },
        result:function(state, view, dp, text, data, loader){
            webix.message(state);
            dp.processResult(state, data, details);
        }
    };
    
    console.log('proxy.js OK');

});