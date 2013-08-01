interface InputScheme {
    name: string;
    title: string;
}

interface ComboBuilderModule {
    inputSchemes: InputScheme[];
    parsedComboUrl: string;
    comboUrl: string;
}

declare var comboBuilder: ComboBuilderModule;
declare function supportsEcma5(): boolean;