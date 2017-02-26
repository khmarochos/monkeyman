(function() {

    this.MultiFields = function(init) {

        this.id_container = init.id_container;
        this.field_prefix = init.field_prefix;
        this.field_type   = init.field_type;

        var that = this;

        MultiFields.prototype.fieldAppend = function(append_after, field_value) {
            var field_sibling = document.getElementById(composeId("div", append_after));
            var field_created = fieldCreate(field_value);
            if(typeof(field_sibling) !== 'undefined' && field_sibling !== null) {
                document.getElementById(this.id_container).insertBefore(field_created, field_sibling.nextSibling);
            } else {
                document.getElementById(this.id_container).appendChild(field_created);
            }
            field_created.querySelectorAll('input[type="' + this.field_type + '"]')[0].focus();
            buttonsEnableDisable();
        }

        MultiFields.prototype.fieldRemove = function(element_id) {
            var element_div     = document.getElementById(composeId("div", element_id));
            var element_button  = document.getElementById(composeId("button_remove", element_id));
            if(element_button.classList.contains("disabled") !== true) {
                element_div.parentNode.removeChild(element_div);
                buttonsEnableDisable();
            }
        }

        function createGuid() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random()*16|0;
                var v = (c === 'x') ? r : (r&0x3|0x8);
                return v.toString(16);
            });
        }

        function fieldCreate(field_value) {
            var guid              = createGuid();
            var id_div            = composeId("div", guid);
            var id_input          = composeId("input", guid);
            var id_button_append  = composeId("button_append", guid);
            var id_button_remove  = composeId("button_remove", guid);
            var div = document.createElement("div");
                div.setAttribute("id", id_div);
                div.setAttribute("class", "form-group");
            var div_input_group = document.createElement("div");
                div_input_group.setAttribute("class", "input-group");
                div.appendChild(div_input_group);
            var input = document.createElement("input");
                input.setAttribute("id", id_input);
                input.setAttribute("name", that.field_prefix + "_" + guid);
                input.setAttribute("type", that.field_type);
                input.setAttribute("class", "form-control required");
                div_input_group.appendChild(input);
            var div_input_group_btn = document.createElement("div");
                div_input_group_btn.setAttribute("class", "input-group-btn");
                div_input_group.appendChild(div_input_group_btn);
            var button_append = document.createElement("button");
                button_append.setAttribute("id", id_button_append);
                button_append.setAttribute("type", "button");
                button_append.setAttribute("class", "btn btn-primary");
                button_append.addEventListener("click", function() { that.fieldAppend(guid) });
                div_input_group_btn.appendChild(button_append);
            var i_plus = document.createElement("i");
                i_plus.setAttribute("class", "fa fa-plus");
                button_append.appendChild(i_plus);
            var button_remove = document.createElement("button");
                button_remove.setAttribute("id", id_button_remove);
                button_remove.setAttribute("type", "button");
                button_remove.setAttribute("class", "btn btn-primary");
                button_remove.addEventListener("click", function() { that.fieldRemove(guid) });
                div_input_group_btn.appendChild(button_remove);
            var i_minus = document.createElement("i");
                i_minus.setAttribute("class", "fa fa-minus");
                button_remove.appendChild(i_minus);
            return(div);
        }

        function buttonsEnableDisable() {
            var buttons = Array.from(document.querySelectorAll("button[id^=" + composeId("button_remove", "") + "]"));
            var buttons_length = buttons.length;
            if(buttons_length > 1) {
                buttons.forEach(function(button) { button.classList.remove("disabled"); });
            } else if(buttons_length === 1) {
                button = buttons[0];
                button.className += " disabled";
            } else {
                console.error("How on earth have they managed to remove the last button? :-)");
            }
        }

        function composeId(type, guid) {
            return("multifield_" + that.field_prefix + "_" + type + "_" + guid);
        }

    }

})();
