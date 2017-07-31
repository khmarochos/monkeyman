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
    
    this.auth    = function( params, callback ){
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
                //console.log("datatable_add click ", datatable, id );
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
                    action = obj.action;                    
                    var url = name_id + "/form/" + action + "/" + me.rows.data.id;
                    route.navigate( url , { trigger: true });
                    console.log( me.rows.data.id , datatable, name_id);
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
                if ( callback ){
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

console.log('controller.js OK');