global with sharing class LB2B_SyncIntegrationShippingInvocable extends LB2B_BaseSyncCheckoutIntegrationStep {
    @InvocableMethod(callout=true label='Get shipping methods' description='Runs a synchronous version of shipping methods' category='B2B Commerce')
    public static void syncShipping(List<ID> cartIds) {
        Id cartId = getCartId(cartIds);
        Id webstoreId = getWebstoreIdFromCart(cartId);

        LB2B_BaseSyncCheckoutIntegrationStep invocable = new LB2B_SyncIntegrationShippingInvocable(webstoreId, cartId);

        sfdc_checkout.CartShippingCharges cartShippingCharges = (sfdc_checkout.CartShippingCharges) invocable.integrationService;
        cartShippingCharges.startCartProcessAsync(null, cartId);

        invocable.updateCheckoutState(cartId);
    }

    private LB2B_SyncIntegrationShippingInvocable(Id webStoreId, Id cartId) {
        super(webStoreId, cartId);
    }

    global override LB2B_BaseSyncCheckoutIntegrationStep.StepType getStepType() {
        return LB2B_BaseSyncCheckoutIntegrationStep.StepType.Shipment;
    }
}