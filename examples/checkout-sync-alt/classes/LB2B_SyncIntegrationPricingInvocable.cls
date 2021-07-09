global with sharing class LB2B_SyncIntegrationPricingInvocable extends LB2B_BaseSyncCheckoutIntegrationStep {
    @InvocableMethod(callout=true label='Price the cart' description='Runs a synchronous version of pricing' category='B2B Commerce')
    public static void syncPricing(List<ID> cartIds) {
        Id cartId = getCartId(cartIds);
        Id webstoreId = getWebstoreIdFromCart(cartId);

        LB2B_BaseSyncCheckoutIntegrationStep invocable = new LB2B_SyncIntegrationPricingInvocable(webstoreId, cartId);

        sfdc_checkout.CartPriceCalculations cartPriceCalculations = (sfdc_checkout.CartPriceCalculations) invocable.integrationService;
        cartPriceCalculations.startCartProcessAsync(null, cartId);

        invocable.updateCheckoutState(cartId);
    }

    private LB2B_SyncIntegrationPricingInvocable(Id webStoreId, Id cartId) {
        super(webStoreId, cartId);
    }

    global override LB2B_BaseSyncCheckoutIntegrationStep.StepType getStepType() {
        return LB2B_BaseSyncCheckoutIntegrationStep.StepType.Price;
    }
}