(function (root, $, ko) {

    function ComboParser() {
        this.modifierRegexp = new RegExp(/.*\..*/);

        function parseModifiedButtonSequence(context, part) {
            var subs = part.split('.');
            var mod = subs[0];
            var sequence = subs[1];

            if(!_.contains(context.inputScheme.modifiers, mod)) {
                return  { type: 'error', message: 'Unknown modifier' };
            }

            return parseSequence.call(this, sequence, context.buttonList,
                { type: 'sequence', parts: [], mod: mod, hasMod: true });
        }

        function parseAnySequence(context, part) {
            return parseSequence.call(this, part, context.anyList,
                { type: 'sequence', parts: [], hasMod: false });
        }

        function parseSequence(part, list, node) {
            var sequence = part;
            do {
                var found = false;
                _.all(list, function(btn) {
                    if(sequence.startsWith(btn)) {
                        console.log('Found: ' + btn);
                        node.parts.push(btn);
                        sequence = sequence.substr(btn.length);
                        found = true;
                        return false;
                    }

                    return true;
                });

                if(!found) {
                    break;
                }
            } while(sequence.length > 0);

            if(sequence.length > 0) {
                return  { type: 'error', message: 'Unknown inputs in sequence: ' +  part};
            }

            return node;
        }

        function parsePart(context, part) {
            if(this.modifierRegexp.test(part)) {
                return parseModifiedButtonSequence.call(this, context, part);
            }
            else {
                return parseAnySequence.call(this, context, part);
            }
        }

        function buildLists(context) {
            context.buttonList = _.sortBy(context.inputScheme.buttons, function(btn) {
                return -btn.length;
            });

            var any = context.inputScheme.buttons.concat(context.inputScheme.motions);
            context.anyList = _.sortBy(any, function(btn) {
               return -btn.length;
            });
        }

        this.parse = function(text, inputScheme) {
            console.log('Parsing: ' + text);

            var parseContext = { inputScheme: inputScheme, text: text };
            buildLists.call(this, parseContext);

            var parts = text.split(' ');
            var nodes = [];
            _.each(parts, $.proxy(function(part) {
                nodes.push(parsePart.call(this, parseContext, part));
            }, this));

            return nodes;
        };
    }

    function serializeCombo(nodes, inputScheme) {
        var lengths = _.map(nodes, function(node) { return node.parts.length + (node.hasMod ? 1 : 0); });
        var total = _.reduce(lengths, function(memo, num) { return memo + num }, 0) + (nodes.length - 1)
                    + inputScheme.name.length;

        var buffer = new ArrayBuffer(total);
        var byteBuf = new Uint8Array(buffer);

        for(var i = 0; i < inputScheme.name.length; i++) {
            byteBuf[i] = inputScheme.name[i];
        }

        var offset = inputScheme.name.length - 1;
        _.each(nodes, function(node) {
            if(node.hasMod) {
                byteBuf[offset] = inputScheme.encodingMap[node.mod];
                offset++;
            }
            _.each(node.parts, function(part) {
                byteBuf[offset] = inputScheme.encodingMap[part];
                offset++;
            });

            if(node != _.last(nodes)) {
                byteBuf[offset] = 0;
                offset++;
            }
        });

        return base64ArrayBuffer(buffer);
    }

    function ComboBuilderViewModel() {
        this.inputSchemes = [new MarvelInputScheme(), new StreetFighterInputScheme()];
        this.comboParser = new ComboParser();
        this.comboText = ko.observable('');
        this.browserSupported = ko.observable(false);
        this.selectedInputScheme = ko.observable(this.inputSchemes[0]);
        this.errorMessage = ko.observable('');
        this.combo = ko.observable('');
        this.comboLink = ko.observable('');
        this.processing = false;

        this.hasError = ko.computed(function () {
            return this.errorMessage() != null && this.errorMessage().length > 0;
        }, this);

        if(!supportsEcma5()) {
            this.setErrorMessage('Your browser does not support ECMAScript 5. Please upgrade to a more modern browser,'
                + " such as <a href='http://www.google.com/chrome'>Google Chrome</a>.");
            return;
        }
        else {
            this.browserSupported(true);
        }

        this.selectedInputScheme.subscribe(function() {
            this.updateCombo(this.comboText());
        }, this);

        this.comboText.subscribe(function(val) {
            this.updateCombo(val);
        }, this);
    }

    ComboBuilderViewModel.prototype.processCombo = function(text) {
        if(text != this.comboText()) {
            var currentVal = this.comboText();
            setTimeout($.proxy(function() {
                this.processCombo(currentVal);
            }, this), 500);
        }
        else {
            var nodes = this.comboParser.parse(text, this.selectedInputScheme());
            var errors = _.select(nodes, function(node) {
                return node.type === 'error';
            });

            if(errors.length > 0) {
                var msg = '';
                errors.forEach(function(error) {
                    msg += error.message + '</br>';
                });

                this.setErrorMessage(msg);
            }
            else {
                this.setErrorMessage(null);
                this.displayCombo(nodes);

                var encodedCombo = serializeCombo(nodes, this.selectedInputScheme());
                this.comboLink('http://localhost/combos/' + encodedCombo);
            }

            this.processing = false;
        }
    };

    ComboBuilderViewModel.prototype.setErrorMessage = function(msg) {
        if(msg === null || msg.length === 0) {
            this.errorMessage('');
            return;
        }

        this.errorMessage('<p>' + msg + '</p>');
    };

    ComboBuilderViewModel.prototype.updateCombo = function(val) {
        if(!this.processing) {
            this.processing = true;
            setTimeout($.proxy(function() {
                this.processCombo(val);
            }, this), 500);
        }
    };

    ComboBuilderViewModel.prototype.displayCombo = function(nodes) {
        function displayPart(part) {
            if(_.has(inputScheme.displayOverrides, part)) {
                return inputScheme.displayOverrides[part];
            }

            return root.comboAssets[part];
        }

        var display = '';
        var inputScheme = this.selectedInputScheme();
        _.each(nodes, $.proxy(function(node) {
            if(node.type !== 'sequence') {
                return;
            }

            display += '<span class="combo-part">';

            if(node.hasMod) {
                display += displayPart(node.mod);
            }

            _.each(node.parts, function(part) {
                display += displayPart(part);
            });

            display += '</span>';
        }, this));

        this.combo(display);
    };

    root.ComboBuilderViewModel = ComboBuilderViewModel;

}(window, jQuery, ko));