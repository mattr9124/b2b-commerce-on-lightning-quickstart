global with sharing class LB2B_SyncIntegrationInventoryInvocable extends LB2B_BaseSyncCheckoutIntegrationStep {
    @InvocableMethod(callout=true label='Validate Inventory' description='Runs a synchronous version of inventory' category='B2B Commerce')
    public static void syncInventory(List<ID> cartIds) {
        Id cartId = getCartId(cartIds);
        Id webstoreId = getWebstoreIdFromCart(cartId);

        LB2B_BaseSyncCheckoutIntegrationStep invocable = new LB2B_SyncIntegrationInventoryInvocable(webstoreId, cartId);

        sfdc_checkout.CartInventoryValidation cartInventoryValidation = (sfdc_checkout.CartInventoryValidation) invocable.integrationService;
        cartInventoryValidation.startCartProcessAsync(null, cartId);

        invocable.updateCheckoutState(cartId);

    }

    private LB2B_SyncIntegrationInventoryInvocable(Id webStoreId, Id cartId) {
        super(webStoreId, cartId);
    }

    global override LB2B_BaseSyncCheckoutIntegrationStep.StepType getStepType() {
        return LB2B_BaseSyncCheckoutIntegrationStep.StepType.Inventory;
    }
}