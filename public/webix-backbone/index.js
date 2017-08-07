if (window.Backbone)
(function(){

	var cfg = {
		use_id : false
	};

	function _start_ext_load(cal){
		cal._backbone_loading = true;
		cal.callEvent("onBeforeLoad", []);
		cal.blockEvent();
	}
	function _finish_ext_load(cal){
		cal.unblockEvent();
		cal._backbone_loading = false;
		cal.refresh();
	}

webix.attachEvent("onUnSyncUnknown", function(wData, bData){
	var whandlers = wData._sync_events;
	var handlers = wData._sync_backbone_events;

	for (var i = 0; i < whandlers.length; i++)
		wData.detachEvent(whandlers[i]);

	for (var i = 0; i < handlers.length; i++)
		bData.off.apply(bData, handlers[i]);        
});

webix.attachEvent("onSyncUnknown", function(wData, bData, config){
	if (config) cfg = config;
	if (cfg.get && typeof cfg.get == "string")
		cfg.get = cfg.get.split(",");

	//remove private properties
	function sanitize(ev){
		if (cfg.use_id)
			return ev;

		var obj = {};
		for (var key in ev)
			if (key != "id")
				obj[key] = ev[key];

		return obj;
	}
	
	function _get_id(model){
		return cfg.use_id ? model.id : model.cid;
	}

	function datareset(wData, bData){
		var data = [];
		for (var i = 0; i < bData.models.length; i++){
			var model = bData.models[i];
			var cid = _get_id(model);
			var ev =  copymodel(model);
			ev.id = cid;
			data.push(ev);
		}
		wData.clearAll();
		wData._parse(data);
	}

	function copymodel(model){
		if (cfg.get){
			var data = {};
			for (var i = 0; i < cfg.get.length; i++){
				var key = cfg.get[i];
				data[key] = model.get(key);
			}
			return data;
		}
		return model.toJSON();
	}

	var handlers = [
		["change", function(model, info){
			var cid = _get_id(model);
			var ev = wData.pull[cid] = copymodel(model);
			ev.id = cid;

			if (wData._scheme_update)
				wData._scheme_update(ev);
			wData.refresh(ev.id);
		}],
		["remove", function(model, changes){
			var cid = _get_id(model);
			if (wData.pull[cid])
				wData.remove(cid);
		}],
		["add", function(model, changes){
			var cid = _get_id(model);
			if (!wData.pull[cid]){
				var ev =  copymodel(model);
				ev.id = cid;
				if (wData._scheme_init)
					wData._scheme_init(ev); 
				wData.add(ev);
			}
		}],
		["reset", function(model, changes){
			datareset(wData, bData);
		}],
		["request", function(obj){
			if (obj instanceof Backbone.Collection)
				_start_ext_load(wData);
		}],
		["sync", function(obj){
			if (obj instanceof Backbone.Collection)
				_finish_ext_load(wData);
		}],
		["error", function(obj){
			if (obj instanceof Backbone.Collection)
				_finish_ext_load(wData);
		}]
	];

	for (var i = 0; i < handlers.length; i++)
        bData.bind.apply(bData, handlers[i]);


    var whandlers = [
		wData.attachEvent("onAfterAdd", function(id){
			if (!bData.get(id)){
				var data = sanitize(wData.getItem(id));
				var model = new bData.model(data);

				var cid = _get_id(model);
				if (cid != id)
					this.changeId(id, cid);

				bData.add(model);
				bData.trigger("webix:add", model);
			}
			return true;
		}),
		wData.attachEvent("onDataUpdate", function(id){
			var ev = bData.get(id);
			var upd = sanitize(wData.getItem(id));

			ev.set(upd);
			bData.trigger("webix:change", ev);

			return true;
		}),
		wData.attachEvent("onAfterDelete", function(id){
			var model = bData.get(id);
			if (model){
				bData.trigger("webix:remove", model);
				bData.remove(id);
			}
			return true;
		})
	];

	wData._sync_source = bData;
    wData._sync_events = whandlers;
    wData._sync_backbone_events = handlers;

	if (bData.length || wData.count()){
		datareset(wData, bData);
	}
});

window.WebixView = Backbone.View.extend({
	//starting from backbone 1.1, this.options is not saved automatically
	initialize : function (options) {
		this.options = options || {};
	},
	render:function(){
		if (this.beforeRender) this.beforeRender.apply(this, arguments);

		var config = this.config || this.options.config;
		var el;

		if (!config.view || !webix.ui.hasMethod(config.view, "setPosition")){
			el = window.$ ? $(this.el)[0] : this.el;
			//clear previous content if any
			if (el && !el.config) el.innerHTML = "";
		}

		var ui = webix.copy(config);
		ui.$scope = this;
		this.root = webix.ui(ui, el);
		
		if (this.afterRender) this.afterRender.apply(this, arguments);
		return this;
	},
	destroy:function(){
		if (this.root) this.root.destructor();
	},
	getRoot:function(){
		return this.root;
	},
	getChild:function(id){
		if (!this.root.$$) webix.message("You need to set isolate property for top view");
		return this.root.$$(id);
	}
});

})();


