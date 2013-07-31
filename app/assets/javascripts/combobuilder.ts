/// <reference path="types/jquery.d.ts" />
/// <reference path="types/underscore-typed.d.ts" />
/// <reference path="types/knockout.d.ts" />
/// <reference path="types/combobuilder.d.ts" />

function supportsEcma5(): boolean {
    return Object.create !== null && Object.create !== undefined;
}

class ComboBuilderViewModel {
    constructor() {
        this.inputSchemes = comboBuilder.inputSchemes;
        this.selectedInputScheme(this.inputSchemes[0]);

        this.hasError = ko.computed(() => {
            return this.errorMessage() != null && this.errorMessage().length > 0;
        });

        if(!supportsEcma5()) {
            this.setErrorMessage('Your browser does not support ECMAScript 5. Please upgrade to a more modern browser,'
                + " such as <a href='http://www.google.com/chrome'>Google Chrome</a>.");
            return;
        }
        else {
            this.browserSupported(true);
        }

        this.selectedInputScheme.subscribe(() => {
            if(this.comboText()) {
                this.updateCombo(this.comboText());
            }
        });

        this.comboText.subscribe((val: string) => {
            this.updateCombo(val);
        });
    }

    processCombo(text: string): void {
        if(text != this.comboText()) {
            var currentVal = this.comboText();
            setTimeout(() => {
                this.processCombo(currentVal);
            }, 500);
        }
        else {
            try {
                var param = (this.selectedInputScheme().name + '$' + text).replace(/\./g, '!').replace(/\s/g, '@');
                this.comboLink(comboBuilder.parsedComboUrl + param);
                $.get(this.comboLink() + '?no_layout=1', (data: string) => {
                        this.combo(data);
                        this.processing = false;
                    })
                    .fail((err, status: string) => {
                        console.log('Error: ' + status);
                        this.processing = false;
                    });
            } catch(e) {
                this.processing = false;
            }
        }
    }

    setErrorMessage(msg: string): void {
        if(msg === null || msg.length === 0) {
            this.errorMessage('');
            return;
        }

        this.errorMessage('<p>' + msg + '</p>');
    }

    updateCombo(val: string): void {
        if(val === null || val.length === 0) {
            this.combo('');
            this.comboLink('');
            return;
        }

        if(!this.processing) {
            this.processing = true;
            setTimeout(() => {
                this.processCombo(val);
            }, 500);
        }
    }

    public hasError: KnockoutComputed<boolean>;
    public inputSchemes: InputScheme[] ;
    public comboText = ko.observable<string>();
    public browserSupported = ko.observable<boolean>();
    public selectedInputScheme = ko.observable<InputScheme>();
    public errorMessage = ko.observable<string>();
    public combo = ko.observable<string>();
    public comboLink = ko.observable<string>();
    public processing = false;
}
