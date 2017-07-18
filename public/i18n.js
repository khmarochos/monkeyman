//webix.ready(function(){    
    /*
     */
var locales = {
    /*
     */
    "en-US": {
        'localeName': "en-US",
        'person'    : "Person",
        'dateFormat': '%d/%m/%Y',
        'loading'   : 'Loading ...',
        'loading_no_data' : 'Sorry, there is no data',
        'timeFormat'    :"%h:%i %A",
        'longDateFormat':"%d %F %Y",
        'fullDateFormat':"%m/%d/%Y %h:%i %A",
        'dateFormatStr' :"%d/%m/%Y",

        'datatable': {
            'id'         : 'ID',
            'first_name' : 'First Name',
            'last_name'  : 'Last Name',
        }
    },
    /*
     */
    "ru-RU": {
        'localeName': "ru-RU",
        'person'    : "Персона",
        'dateFormat': '%d-%m-%Y',
        'loading'   : 'Загрузка ...',
        'loading_no_data' : 'Нет данных',
        'dateFormat':"%d-%m-%Y",
        'timeFormat':"%h:%i %A",
        'longDateFormat':"%d %F %Y",
        'fullDateFormat':"%d-%m-%Y %h:%i %A",
        'dateFormatStr' :"%d-%m-%Y",
        
        'datatable': {
            'id'         : '#',
            'first_name' : 'Имя',
            'last_name'  : 'Фамилия',
        }
    }
};
        
function my_i18n (){
    this.store_name  = "locale";
    this.locale      = "en-US";
    this.localizator = locales[this.defaultLocale];
    
    this.set = function( locale ){
        this.locale = locale ? locale : this.locale;
        this.localizator = locales[this.locale];
        webix.i18n.setLocale( locales[this.locale] );
        return this.localizator;
    };
    
    this.get = function(){
        return this.localizator;
    };
}

var i18n        = new my_i18n();
var localizator = i18n.set('en-US');

    
console.log('i18n.js OK');

//});
