/**
 * Base class for synchronous integrations. This class holds all the
 * boiler plate code for dealing with integrations in a synchronous way.
 * It allows using the same classes configured in commerce setup
 * but in a synchronous way.
 */
global abstract with sharing class LB2B_BaseSyncCheckoutIntegrationStep {

    global enum StepType {
        Inventory, Price, Tax, Shipment
    }

    private final static Pattern SERVICE_DEV_NAME_REGEX = Pattern.compile('^\\w+\\_\\_(.*)$');

    private final Id webStoreId;

    private final Id cartId;

    protected final Object integrationService;

    /**
     * Implementers need to simply return the correct value of the enum. Generally
     * only a single value should be returned by a class. Although it is potentially
     * possible to do a class that can handle different types and dynamically
     * return the correct step type.
     * @return Step type
     */
    global abstract StepType getStepType();

    @TestVisible
    protected LB2B_BaseSyncCheckoutIntegrationStep(Id webstoreId, Id cartId) {
        this.webStoreId = webStoreId;
        this.cartId = cartId;
        this.integrationService = resolveIntegrationService();
    }

    private Object resolveIntegrationService() { // load the service via what is configured in store admin
        String developerName;
        try {
            StoreIntegratedService storeIntegratedService = [
                    SELECT Id, Integration, Store.Id, Store.Name, ServiceProviderType
                    FROM StoreIntegratedService
                    WHERE StoreId = :this.webStoreId
                    AND ServiceProviderType = :getStepType().name()
            ];

            developerName = extractDeveloperName(storeIntegratedService.Integration);
        } catch (QueryException e) {
            String message = String.format('Unable to find integration service for webstore {0}, integration type {1}, \nerror message: {2}',
                    new Object[]{this.webStoreId, getStepType().name(), e.getMessage()}
            );
            handleError(message);
        }

        if (String.isBlank(developerName)) {
            String message = String.format('Unable to find integration service for webstore: {0}, Type: {1}, Integration: {2}',
                    new Object[]{webStoreId, getStepType().name(), storeIntegratedService.Integration}
            );
            handleError(message);
        }
        String className;
        try {
            className = findClassName(developerName);

            Type serviceType = Type.forName(className);
            Object service = serviceType.newInstance();

            return service;
        } catch (Exception e) {
            String message = String.format('Unable to created class {0}, registered service developerName: {1}',
                    new Object[]{className, developerName}
            );
            handleError(message);
        }
        // should never end up here, the handleError method will throw an exception if no service is found!
        return null;
    }

    private void handleError(String message) {
        saveCartValidationOutputError(message, cartId);
        throw new SyncCheckoutException(message);
    }

    private String findClassName(String developerName) {
        RegisteredExternalService registeredExternalService = [
                SELECT ExternalServiceProvider.Name
                FROM RegisteredExternalService
                WHERE DeveloperName = :developerName
        ];

        return registeredExternalService.ExternalServiceProvider.Name;
    }

    private String extractDeveloperName(String integration) {
        /**
         * Checking the internal code, seems we don't have access via Apex/SOQL to everything
         * so we need to do a bit of guessing here. The format is generally
         * Price__DevNameOfService
         *
         * The regex will extract the second part.
         */
        Matcher matcher = SERVICE_DEV_NAME_REGEX.matcher(integration);

        if (matcher.find() && matcher.groupCount() > 0) {
            return matcher.group(1);
        }

        return null;
    }

    protected void saveCartValidationOutputError(String errorMessage, Id cartId) {
        CartValidationOutput cartValidationError = new CartValidationOutput(
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String) cartId,
                RelatedEntityId = cartId,
                Type = getStepType().name()
        );
        insert cartValidationError;
    }

    protected void updateCheckoutState(Id cartId) {

        CartCheckoutSession cartCheckoutSession = [
                SELECT NextState
                FROM CartCheckoutSession
                WHERE WebCartId = :cartId
                AND IsArchived = FALSE
        ];

        cartCheckoutSession.State = cartCheckoutSession.NextState;
        cartCheckoutSession.NextState = null;

        update cartCheckoutSession;
    }

    public static Id getCartId(List<Id> cartIds) {
        if (cartIds == null || cartIds.size() != 1) {
            /*
            NOTE: Not creating a validation error as it would require instantiated an object.
            We can do it, but it's not really worth the effort. This will still showup in
            debug logs if it happens.
            If your checkout fails here you have some serious config problems in your flow
            which should have be fixed long before going live!
             */
            throw new SyncCheckoutException('Cart ID not found or multiple IDs! Be sure to include only a single cart ID parameter!');
        }
        return cartIds[0];
    }

    public static Id getWebstoreIdFromCart(Id cartId) {
        WebCart cart = [SELECT WebStoreId FROM WebCart WHERE Id = :cartId];
        return cart.WebStoreId;
    }

    public class SyncCheckoutException extends Exception {
    }
}