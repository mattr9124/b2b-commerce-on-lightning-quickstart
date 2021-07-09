# Alternative Sync Checkout

This is a quick way to convert the default async checkout to sync checkout.

Replace the template subflows with ones here. They will then call the 
invocable actions here which will do a lookup to the services
defined in commerce setup.

## Warning 

The integration classes are called with "null" for the 
Job Info parameter. The service implementations should handle 
for the case where this is null. 

For example:
```apex
sfdc_checkout.CartInventoryValidation cartInventoryValidation = (sfdc_checkout.CartInventoryValidation) invocable.integrationService;
cartInventoryValidation.startCartProcessAsync(null, cartId);
```
