function supportsEcma5(): boolean {
    return Object.create !== null && Object.create !== undefined;
}
