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
                    console.log( me.rows.data );
                });
                
                $$( datatable.view.id ).refresh();
            }            
            // pager
            if ( this.components.datatable.datatable_pager.view ){
                obj.addView( this.components.datatable.datatable_pager.view );
                $$( this.components.datatable.datatable_pager.view.id ).refresh();
            }
            
            if( $$('datatable_actions') ){
                $$('datatable_actions').attachEvent('onMenuItemClick', function(id){
                    webix.message("Global click: "+this.getMenuItem(id).value);
                    webix.message("Global click: "+this.getMenuItem(id).url  );
                });
            }
                        
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