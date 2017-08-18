function Skin () {
    this.run = function () {
        var theme = this.getParameterByName('theme');
        webix_skin = theme ? theme : "air";
        var href =  'http://cdn.webix.com/site/skins/'+ webix_skin +'.css?t=' + Date.now();
        document.write('<link id="css" rel="stylesheet" href="' + href + '"></link>');
        return webix_skin;
    };
    
    this.getParameterByName = function (name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        var res = results && results[2] ? decodeURIComponent(results[2].replace(/\+/g, " ")) : null;
        
        url = url.replace(/[?&]*theme=\w+/ig,"");
        console.log("skin", url, results);
        window.history.replaceState( {} , '', url );
        
        if (!results) return null;
        if (!results[2]) return '';
        return res;
    };			
}