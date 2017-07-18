/*
    Controller
    var controller = new Controller();
    attachEvent detachEvent
*/
function Controller (){
    this.args = [].slice.call(arguments);
    
    this.localStorge = {
        set: function( key, obj ){
            if( obj ){
                return webix.storage.local.put( key, obj.getState() );
            }
            return false;
        },
        get: function( key ){
            console.log( 'controller->get ',this);
            if( key ){
                var data = webix.storage.local.get( key );
                if( data ){
                    return data;
                }
                else{
                    webix.message('key '+key+' is not exists');
                }
            }
            else{
                webix.message('select key');
            }
            return false;
        }
    };
    
    this.locale = {
        get: function(){
            
        },
        set: function( locale ){
            if( isNaN(locale) ){
                localizator = translations[locale];
                if( isNaN(localizator) ){
                    webix.i18n.setLocale(locale);
                    return localizator;
                }
                else{
                    webix.message( 'locale ' +locale+' is not support' );
                }
            }
            else{
                webix.message( 'select locale' );
            }
            return false;
        }
    };
    
    
    this.tree = {
        onSelectChange: function( obj, callback ){
            if ( !obj ) return false;            
            obj.attachEvent('onSelectChange', function(){
                selected = this.getSelectedId();
                if (isNaN(selected)) {
                    if ( callback ){
                        callback.call( this, selected );
                    }
                }
            });            
        }
    };
    
    this.header = {
        "onChange": function( obj, callback ) {
            if ( !obj ) return false;
            obj.attachEvent('onChange', function(){
                if ( callback ){
                    callback.call( this, this.getValue() );
                }
            });            
        }
    };
    
}


function Datatable( setting ){
    this.setting = setting;
    
    this.create = function( id ){
        var me = $$("main");
        
        if ( isNaN( this.setting.datatable[id] ) ){
            datatable_id = id;
            console.log('datatable '+ id +' start ... ');
                        
            if( !this.setting.datatable[id] ) {
                webix.message('component ' + id + ' not exists');
                return false;
            }

            console.log( me.removeView("datatable_pager") );
            console.log( me.removeView("datatable_toolbar") );
            console.log( me.removeView("datatable") );
            
            if (this.setting.datatable[id].toolbar){
                me.addView( this.setting.datatable[id].toolbar.view );
            }
                
            if (this.setting.datatable[id].view){
                //datatable
                me.addView( this.setting.datatable[id].view  );
                //contextmenu
                webix.ui( this.setting.datatable.contextmenu.view ).attachTo( $$(this.setting.datatable[id].view.id) );
                $$( this.setting.datatable[id].view.id ).refresh();
            }
            
            if (this.setting.datatable.datatable_pager.view){
                me.addView( this.setting.datatable.datatable_pager.view );
                $$( this.setting.datatable.datatable_pager.view.id ).refresh();
            }                    
            console.log('datatable '+ id +' is created');
        }
    };
}

console.log('controller.js OK');
