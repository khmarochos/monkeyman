/*
    Controller
    var controller = new Controller();
    attachEvent detachEvent
*/
function Controller (arg){
    //this.args = [].slice.call(arguments);
    this.args      = arg;
    this.tree      = new Tree( this.args );
    this.datatable = new Datatable( this.args );
    this.form      = new Form ( this.args );
    
    this.auth      = function( params, callback ){
        var res = false;
        webix.ajax().post(
            "/person/login.json",
            params,
            function( text, data, http ) {
                var res = data.json();
                
                if( res.success == 1 ){
                    //webix.send( res.redirect , null, "GET");
                    res = true;
                }
                else{
                    webix.message( res.message );
                    res = false;
                }
                
                if ( callback ){
                    callback.call( this, res );
                }                
            }
        );
        
        return res;
    };
    
    this.onChange = function( obj, callback ) {
        if ( !obj ) return false;
        obj.attachEvent('onChange', function(){
            if ( callback ){
                callback.call( this, this.getValue() );
            }
        });
    };    
}
/*
    Datatable  
 */
function Datatable( components ){
    this.components = components;
    
    this.rows = {
        data : {},  
    };
    
    this.remove = function( o ) {
        var obj = o ? o : $$('main');
        if( obj ){
            //var views = obj.getChildViews();
            /*views.forEach( function(item, i, arr){
                obj.removeView( item.config.id );
                console.log( "views", item.config.id );
            });*/
            if( $$('datatable_actions') && $$('datatable_actions').hasEvent("onMenuItemClick") ){
                $$('datatable_actions').detachEvent("onMenuItemClick");
            }
            obj.removeView("form");
            obj.removeView("datatable_pager");
            obj.removeView("datatable_toolbar");
            obj.removeView("datatable");
            console.log("remove datatable...");
        }
    };
        
    this.create = function( id ){
        //route.navigate("login", {trigger: true, replace: true});
        //console.log( route );
        var name_id   = id;
        var me        = this;
        var obj       = $$("main");
        var datatable = this.components.datatable[name_id];
        me.rows.data  = {};
        this.remove( obj );
        
        if ( obj && isNaN( datatable  ) ){
            console.log('datatable '+ id +' start ... ');
                                    
            //toolbar
            if ( datatable.toolbar && datatable.toolbar.view ){
                obj.addView( datatable.toolbar.view );
            }            
            
            //datatable
            if ( datatable.view ){
                obj.addView( datatable.view  );

                //contextmenu
                webix.ui( this.components.datatable.contextmenu.view ).attachTo( $$( datatable.view.id ) );

                // refresh component
                $$( datatable.view.id ).attachEvent("onSelectChange", function(){
                    me.rows.data = this.getSelectedItem();
                });

                $$( datatable.view.id ).attachEvent("onBeforeLoad", function(){
                    this.showOverlay( webix.i18n.loading );
                });

                $$( datatable.view.id ).attachEvent("onAfterLoad", function(){
                    this.hideOverlay();
                    if (!this.count()) this.showOverlay( webix.i18n.loading_no_data );   
                });
                
                $$( datatable.view.id ).refresh();
            }
            
            // pager
            if ( this.components.datatable.datatable_pager.view ){
                obj.addView( this.components.datatable.datatable_pager.view );
                $$( this.components.datatable.datatable_pager.view.id ).refresh();
            }
            
            // menu communication
            if( $$('datatable_actions') ){
                $$('datatable_actions').attachEvent('onMenuItemClick', function(id){

                    var related_id   = me.rows.data.id;
                    var url          = this.getMenuItem(id).url;
                    var datatable_id = this.getMenuItem(id).id;

                    if( related_id ){
                        if( url ){
                            var datatable = me.components.datatable[ datatable_id ];
                            if( datatable ){
                                url = url.replace('{{id}}', related_id );
                                //datatable.view.url = url + '.json';
                                //var obj = new Datatable( me.components );
                                //obj.create( datatable_id );
                                route.navigate( url, { trigger: true });
                            }
                        }
                    }
                    else{
                        webix.message( webix.i18n.datatable.do_row_select );
                    }
                });
            }
            // button add
            $$("datatable_add").attachEvent("onItemClick", function(){
                $$("tree").unselectAll();
                route.navigate( "/" + id + "/form/add", { trigger: true });
            });
            // export
            $$("datatable_export_pdf").attachEvent("onItemClick", function(){
                webix.toPDF( $$("datatable"), {
                    orientation : "landscape",
                    autowidth   : true
                } );
                console.log("export to PDF");
            });

            $$("datatable_export_png").attachEvent("onItemClick", function(){
                webix.toPNG( $$("datatable"), {
                    orientation : "landscape",
                    autowidth   : true
                });
                console.log("export to PNG");
            });

            $$("datatable_export_excel").attachEvent("onItemClick", function(){
                webix.toExcel( $$("datatable"), {
                    orientation : "landscape",
                    autowidth   : true
                });
                console.log("export to Excel");
            });
            
            // contextmenu datatable ( edit, delete )
            $$("contextmenu").attachEvent("onItemClick", function(id){
                var obj    = this.getItem(id);
                var action = obj ? obj.action : false;
                
                if( me.rows.data.id && obj ){
                    $$("tree").unselectAll();
                    action = obj.action;                    
                    var url = name_id + "/form/" + action + "/" + me.rows.data.id;
                    route.navigate( url , { trigger: true });
                }
                else{
                    webix.message( webix.i18n.datatable.do_row_select );    
                }
            });
            
            console.log('datatable '+ id +' is created');
        }
    };
}

/*
    tree  
 */
function Tree( components ){
    this.components = components;
    this.onSelectChange = function( obj, callback ){
        if ( !obj ) return false;            
        obj.attachEvent('onSelectChange', function(){
            selected = this.getSelectedId();
            if (isNaN(selected)) {
                if ( isNaN(callback) ){
                    callback.call( this, selected );
                }
            }
        });            
    };
    
    this.select = function( id ){
        var tree = $$("tree");
        if( tree ){
            tree.select(id);
        }
        
    };
    
}
/*
    Local Storage
*/
function LocalStorage() {
    
    this.get = function( key ){
        if ( key ) {
            return webix.storage.local.get(key);
        }
        else{
            webix.message( 'not parce');
            return false;
        }
    };

    this.set = function( key, data ){
        if( key && data ){
            return webix.storage.local.put( key, data );
        }
        else{
            webix.message( 'not params key or data' );
        }
        return false;
    };
    
}
/*
    i18n
*/
function my_i18n (){
    this.locale      = "en-US";
    this.localizator = locales[this.locale];
    
    this.set = function( locale ){
        this.locale     = locale ? locale : this.locale;
        var localizator = locales[this.locale];
        if( localizator ){
            webix.i18n.setLocale( localizator );
        }
        else{
            webix.message( 'locale ' + locale + ' is not support' );
        }
        return localizator ? localizator : this.localizator;
    };
    
    this.get = function(){
        return this.localizator;
    };
}
/*
    i18n
*/
function Form ( components ){
    this.components = components;
    
    this.start = function( view ) {
        var obj = $$("main");
        if( obj && view ) {
            obj.addView( view );
            return true;
        }
        else{
            return false;
        }
    };
    
    this.end = function ( form_name ) {
        var me            = this;
        var form          = $$( form_name );
        var send_form_btn = $$("send_form");
        var url           = form.config.baseURL;
        
        if( url && form && send_form_btn ){
            /*
                Отправка формы ма сервер
            */
            send_form_btn.attachEvent("onItemClick", function(){
                var action    = $$("form").config.action;
                var formData  = form.getValues();
                var child_obj = me.getSnippet( form_name );
                
                if( $$( form_name ).validate() ) {
                    child_obj.forEach( function( item, i ){
                        var obj = $$( item );
                        if( obj ) {
                            var data = [];
                            var view = obj.getChildViews();
                            if( view ){
                                view.forEach( function( item2, i ){
                                    if( item2.config.view == 'form' ){
                                        data.push( item2.getValues() );
                                    }           
                                });
                                if ( data.length ) formData[ item ] = data;
                            }
                        }
                    });
                    
                    if( formData ){
                        webix.ajax().post(
                            url + '/' + action + ".json",
                            formData,
                            function(text,data,http) {
                                var res = data.json();
                                if( res.success == 1 ){
                                    route.navigate( res.redirect, { trigger: true });
                                }
                                else{
                                    webix.message( res.message );
                                }
                            }
                        );
                    }                
                }
            });
        }
        else{
            webix.message("controller Form->getChild form or send_form_btn not found " + form_name);
        }
    };
    /*
        Загрузка данных формы 
    */    
    this.load = function( form_name, url, callback ){
        var form = $$(form_name);
        if ( form && url ) {            
            form.load( url, "json", {
                error: function(text, data, http_request){
                    webix.message("Server error. See console.log");
                    console.log( http_request );
                },
                success: function(text, data, http_request){                    
                    if ( callback ){
                        var data = JSON.parse(text);
                        if( data.success ){
                            callback.call( this, JSON.parse(text) );
                        }
                        else{
                            webix.message( "error load data:" + data.message );
                        }
                    }
                    else{
                        return JSON.parse(text);
                    }
                }
            });
        }
        else{
            webix.message("controller Form->load do not all params: " + form_name);
        }
        return false;
    };
    
    this.getSnippet = function( form_name ){
        var form = $$(form_name);
        if( form ){
            return form.config['child_obj'] ? form.config['child_obj'] : [];
        }
        else{
            webix.message("controller Form->getChild form not found " + form_name);
        }
        return false;
    };
    
    this.setSnippet = function( form_name, snippent_name ) {
        var me   = this;
        var form = $$( form_name );
        
        var add = {
            view :"fieldset", 
            label: snippent_name,
            body : {
                id  : snippent_name,
                rows:[
                    {
                        view : "button",
                        id   : snippent_name + "_add",
                        value: webix.i18n.add
                    }
                ]
            }
        };
        
        var child = me.getChild( form_name );
        
        if( child ){
            var index = child.length - 1;
            form.addView( add, index );
        
            $$( snippent_name + "_add" ).attachEvent("onItemClick", function(){
                var obj = $$( snippent_name );
                if(obj) obj.addView(  webix.copy( components.form[ snippent_name ] ) );
            });
        }
        
        return false;  
    };
    
    this.setSnippetItem = function( snippent_name, data, index ){
        var me   = this;
        var obj  = $$( snippent_name );
        if( obj ){
            data.forEach( function( item, i ){
                var copy  = webix.copy( components.form[ snippent_name ] );
                var form  = "form_" + snippent_name + "_" + index;
                copy.form = form;
                copy.id   = form;
                if(obj) {
                    obj.addView( copy );
                    $$(form).setValues( item );
                }
            });            
        }
        return false;
    };
    
    this.getChild = function( form_name ){
        var form = $$(form_name);
        if( isNaN(form) ){
            return form.getChildViews() ? form.getChildViews() : [];
        }
        else{
            webix.message("controller Form->getChild form not found " + form_name);
        }
        return false;
    };
    
    this.getValues = function (){
        
    };
    
/*    
    this.setChild = function( form_name, snippet_name, id ){
        var me      = this;
        var form    = $$(form_name);
        var snippet = components.form[snippet_name];
        
        if( isNaN(form) && isNaN(snippet) ){
            form.addView( snippet );
        }
        else{
            webix.message("controller Form->setChild form or snippet not found " + form_name);
        }
        
        return false;
    };
*/    
    
}
console.log('controller.js OK');