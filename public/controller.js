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
    
    this.create = function( id ){
        var me        = this;
        var obj       = $$("main");
        var datatable = this.components.datatable[id];
        me.rows.data  = {};
        
        if ( isNaN( datatable  ) ){
            console.log('datatable '+ id +' start ... ');
                        
            if( !datatable  ) {
                webix.message('component ' + id + ' not exists');
                return false;
            }

            if( $$('datatable_actions') && $$('datatable_actions').hasEvent("onMenuItemClick") ){
                $$('datatable_actions').detachEvent("onMenuItemClick");
            }
            
            obj.removeView("datatable_pager");
            obj.removeView("datatable_toolbar");
            obj.removeView("datatable");
            
            //toolbar
            if ( datatable.toolbar){
                obj.addView( datatable .toolbar.view );
            }            
            //datatable
            if ( datatable.view ){
                obj.addView( datatable.view  );
                //contextmenu
                webix.ui( this.components.datatable.contextmenu.view ).attachTo( $$( datatable.view.id ) );
                // refresh component
                $$( datatable.view.id ).attachEvent("onSelectChange", function(){
                    me.rows.data = this.getSelectedItem();
                    //console.log( me.rows.data );
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
                    //console.log( related_id, url, datatable_id );

                    if( related_id ){
                        if( url ){
                            var datatable = me.components.datatable[ datatable_id ];
                            if( datatable ){
                                url = url.replace('{{id}}', related_id );
                                datatable.view.url = url + '.json';
                                var obj = new Datatable( me.components );
                                obj.create( datatable_id );
                            }
                        }
                    }
                    else{
                        webix.message( webix.i18n.datatable.do_row_select );
                    }
                });
            }
            
            // sort active ...
            $$("datatable_load_active").attachEvent("onItemClick", function(id){
                console.log( 'onItemClick', id, datatable );
                var url = datatable.view.url;
                url = url.replace();
                if( id == '' ){
                    //
                }
            });
                                    
            console.log('datatable '+ id +' is created');
        }
    };
}

/*
    tree  
 */
function Tree(){
    
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
            webix.message( 'not param key' );
        }
        return false;
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