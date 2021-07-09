global with sharing class LB2B_SyncIntegrationTaxInvocable extends LB2B_BaseSyncCheckoutIntegrationStep {
    @InvocableMethod(callout=true label='Get taxes' description='Runs a synchronous version of taxes' category='B2B Commerce')
    public static void syncTaxes(List<ID> cartIds) {
        Id cartId = getCartId(cartIds);
        Id webstoreId = getWebstoreIdFromCart(cartId);

        LB2B_BaseSyncCheckoutIntegrationStep invocable = new LB2B_SyncIntegrationTaxInvocable(webstoreId, cartId);

        sfdc_checkout.CartTaxCalculations cartTaxCalculations = (sfdc_checkout.CartTaxCalculations) invocable.integrationService;
        cartTaxCalculations.startCartProcessAsync(null, cartId);

        invocable.updateCheckoutState(cartId);
    }

    private LB2B_SyncIntegrationTaxInvocable(Id webStoreId, Id cartId) {
        super(webStoreId, cartId);
    }

    global override LB2B_BaseSyncCheckoutIntegrationStep.StepType getStepType() {
        return LB2B_BaseSyncCheckoutIntegrationStep.StepType.Tax;
    }
}