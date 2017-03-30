(function(window) {

    window.multiField = function(init) {

        this.idContainer    = init.idContainer;
        this.fieldPrefix    = init.fieldPrefix;
        this.fieldType      = init.fieldType;
        this.addClasses     = typeof(init.addClasses) == 'Array' ? init.addClasses : [ init.addClasses ];
        this.beforeAppend   = init.beforeAppend;
        this.afterAppend    = init.afterAppend;

        var that = this;

        this.fieldAppend = function(appendAfter, fieldValue) {
            var fieldSibling = document.getElementById(composeId("div", appendAfter));
            var fieldCreated = fieldCreate(fieldValue);
            if(fieldSibling != null) {
                if(this.beforeAppend != null) this.beforeAppend(fieldSibling);
                document.getElementById(this.idContainer).insertBefore(fieldCreated, fieldSibling.nextSibling);
            } else {
                document.getElementById(this.idContainer).appendChild(fieldCreated);
            }
            fieldCreated.querySelectorAll('input[type="' + this.fieldType + '"]')[0].focus();
            buttonsEnableDisable();
            if(this.afterAppend != null) this.afterAppend(fieldSibling, fieldCreated);
            return(fieldCreated);
        }

        this.fieldRemove = function(elementId) {
            var elementDiv    = document.getElementById(composeId("div", elementId));
            var elementButton = document.getElementById(composeId("button-remove", elementId));
            if(elementButton.classList.contains("disabled") !== true) {
                elementDiv.parentNode.removeChild(elementDiv);
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

        function fieldCreate(fieldValue) {
            var guid            = createGuid();
            var idDiv           = composeId("div", guid);
            var idInput         = composeId("input", guid);
            var idButtonAppend  = composeId("button-append", guid);
            var idButtonRemove  = composeId("button-remove", guid);
            var div = document.createElement("div");
                div.setAttribute("id", idDiv);
                div.setAttribute("class", [ "form-group", that.addClasses ].join(" "));
            var divInputGroup = document.createElement("div");
                divInputGroup.setAttribute("class", "input-group");
                div.appendChild(divInputGroup);
            var input = document.createElement("input");
                input.setAttribute("id", idInput);
                input.setAttribute("name", that.fieldPrefix + "-" + guid);
                input.setAttribute("type", that.fieldType);
                input.setAttribute("class", "form-control required");
                if(fieldValue != null) input.setAttribute("value", fieldValue);
                divInputGroup.appendChild(input);
            var divInputGroupBtn = document.createElement("div");
                divInputGroupBtn.setAttribute("class", "input-group-btn");
                divInputGroup.appendChild(divInputGroupBtn);
            var buttonAppend = document.createElement("button");
                buttonAppend.setAttribute("id", idButtonAppend);
                buttonAppend.setAttribute("type", "button");
                buttonAppend.setAttribute("class", "btn btn-primary");
                buttonAppend.addEventListener("click", function() { that.fieldAppend(guid) });
                divInputGroupBtn.appendChild(buttonAppend);
            var iPlus = document.createElement("i");
                iPlus.setAttribute("class", "fa fa-plus");
                buttonAppend.appendChild(iPlus);
            var buttonRemove = document.createElement("button");
                buttonRemove.setAttribute("id", idButtonRemove);
                buttonRemove.setAttribute("type", "button");
                buttonRemove.setAttribute("class", "btn btn-primary");
                buttonRemove.addEventListener("click", function() { that.fieldRemove(guid) });
                divInputGroupBtn.appendChild(buttonRemove);
            var iMinus = document.createElement("i");
                iMinus.setAttribute("class", "fa fa-minus");
                buttonRemove.appendChild(iMinus);
            return(div);
        }

        function buttonsEnableDisable() {
            var buttons = Array.from(document.querySelectorAll("button[id^=" + composeId("button-remove", "") + "]"));
            var buttonsLength = buttons.length;
            if(buttonsLength > 1) {
                buttons.forEach(function(button) { button.classList.remove("disabled"); });
            } else if(buttonsLength === 1) {
                button = buttons[0];
                button.className += " disabled";
            } else {
                console.error("How on earth have they managed to remove the last button? :-)");
            }
        }

        function composeId(type, guid) {
            return("multifield-" + that.fieldPrefix + "-" + type + "-" + guid);
        }

    }

})(window);
