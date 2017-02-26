(function() {

    this.MultiFields = function() {

        this.field_prefix = null;
        this.id_container = null;

        var that = this;

        MultiFields.prototype.fieldAppend = function(element_id, field_value) {
            var field_sibling = document.getElementById("multiform_" + this.field_prefix + "_div_" + element_id);
            var field_created = fieldCreate(field_value);
            if(typeof(field_sibling) !== 'undefined' && field_sibling !== null) {
                document.getElementById(this.id_container).insertBefore(field_created, field_sibling.nextSibling);
            } else {
                document.getElementById(this.id_container).appendChild(field_created);
            }
            field_created.querySelectorAll('input[type="text"]')[0].focus();
            // this.buttonsEnableDisable();
        }

        MultiFields.prototype.fieldRemove = function(element_id) {
            var element = document.getElementById("multiform_" + this.field_prefix + "_div_" + element_id);
            element.parentNode.removeChild(element);
            // this.buttonsEnableDisable();
        }

        function createGuid() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random()*16|0;
                var v = (c === 'x') ? r : (r&0x3|0x8);
                return v.toString(16);
            });
        }

        function fieldCreate(field_value) {
            var guid = createGuid();
            var id_div            = "multifield_" + that.field_prefix + "_div_" + guid;
            var id_input          = "multifield_" + that.field_prefix + "_input_" + guid;
            var id_button_append  = "multifield_" + that.field_prefix + "_button_append_" + guid;
            var id_button_remove  = "multifield_" + that.field_prefix + "_button_remove_" + guid;
            var div = document.createElement("div");
                div.setAttribute("id", id_div);
                div.setAttribute("class", "form-group");
            var div_input_group = document.createElement("div");
                div_input_group.setAttribute("class", "input-group");
                div.appendChild(div_input_group);
            var input = document.createElement("input");
                input.setAttribute("id", id_input);
                input.setAttribute("name", that.field_prefix + "_" + guid);
                input.setAttribute("type", "text");
                input.setAttribute("class", "form-control required");
                div_input_group.appendChild(input);
            var div_input_group_btn = document.createElement("div");
                div_input_group_btn.setAttribute("class", "input-group-btn");
                div_input_group.appendChild(div_input_group_btn);
            var button_append = document.createElement("button");
                button_append.setAttribute("id", id_button_append);
                button_append.setAttribute("type", "button");
                button_append.setAttribute("class", "btn btn-primary");
                button_append.addEventListener("click", that.fieldAppend);
                div_input_group_btn.appendChild(button_append);
            var i_plus = document.createElement("i");
                i_plus.setAttribute("class", "fa fa-plus");
                button_append.appendChild(i_plus);
            var button_remove = document.createElement("button");
                button_remove.setAttribute("id", id_button_remove);
                button_remove.setAttribute("type", "button");
                button_remove.setAttribute("class", "btn btn-primary");
                //button_remove.onclick = that.fieldRemove(guid);
                div_input_group_btn.appendChild(button_remove);
            var i_minus = document.createElement("i");
                i_minus.setAttribute("class", "fa fa-minus");
                button_remove.appendChild(i_minus);
            return(div);
        }

        /*
        function buttonsEnableDisable() {
            var buttons = Array.from(document.querySelectorAll('button[id^="button_remove_"]'));
            var buttons_length = buttons.length;
            if(buttons_length > 1) {
                buttons.forEach(function(button) {
                    button.classList.remove("disabled");
                    button.setAttribute("onclick", "email_field_remove(\"" + button.id.substr(14, 36) + "\")");
                });
            } else if(buttons_length === 1) {
                button = buttons[0];
                button.className += " disabled"
                button.removeAttribute("onclick");
            } else {
                console.error("How on earth have they managed to remove the last button? :-)");
            }
        }
        */

    }

})();
