@isTest
private class B2BCheckInventorySampleTest {
    @testSetup static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        insertCartItem(cart.Id, cartDeliveryGroup.Id);
    }
    
    @isTest static void testWhenExternalServiceQuantityIsLargerThanTheCartItemQuantityASuccessStatusIsReturned() {
        
        // Test: execute the integration for the test cart ID.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        B2BCheckInventorySample apexSample = new B2BCheckInventorySample();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(null, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }
    
    @isTest static void testExternalServiceSkuNotFoundError() {
        // Test: execute the integration for the test cart ID.
        B2BCheckInventorySample apexSample = new B2BCheckInventorySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItem = [SELECT Sku FROM CartItem WHERE CartId = :webCart.Id];
        cartItem.Sku = 'SKU_Test3';
        update cartItem;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
         
        System.assertEquals('The product with sku SKU_Test3 could not be found in the external system', cartValidationOutputs.get(0).Message);
        Test.stopTest();
    }
    
    @isTest static void testExternalServiceNotEnoughQuantityError() {
        // Test: execute the integration for the test cart ID.
        B2BCheckInventorySample apexSample = new B2BCheckInventorySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItem = [SELECT Sku FROM CartItem WHERE CartId = :webCart.Id];
        cartItem.Sku = 'SKU_Test2';
        update cartItem;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
         
        System.assertEquals('Insufficient quantity for the product with sku SKU_Test2: 3 needed, but only 0.00 available.', cartValidationOutputs.get(0).Message);
        Test.stopTest();
    }
    
    // This test ensures that when the cart is empty that check inventory returns an error
    @isTest static void testEmptyCartHasError() {
        // Empty the cart before the test
        deleteCartItem();
        Test.startTest();

        // Test: Execute the integration for the test cart ID.
        B2BCheckInventorySample apexSample = new B2BCheckInventorySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        // Validate: IntegrationStatus.Status is FAILED.
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        
        // Validate: The sample text that the cart is empty is returned as the failure output 
        System.assertEquals('Looks like your cart is empty.', cartValidationOutputs.get(0).Message);
        Test.stopTest();

        // Undo the emptying of the cart we did at the start of the test
        insertCartItem(webCart.Id);
    }

    @isTest static void testProductsWithNoSkuHasError() {
        Test.startTest();

        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :webCart.Id LIMIT 1];

        // Insert a cart item without a SKU
        CartItem cartItemWithNoSku = new CartItem(
            CartId=webCart.Id,
            Quantity=1.0,
            Type='Product',
            Name='TestProductNoSku',
            CartDeliveryGroupId=cartDeliveryGroups.get(0).Id
        );
        insert cartItemWithNoSku;

        B2BCheckInventorySample apexSample = new B2BCheckInventorySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        // Validate: IntegrationStatus.Status is FAILED.
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        
        // Validate: The sample text that a product SKU is missing is returned as the failure output 
        System.assertEquals('The SKUs for all products in your cart must be defined.', cartValidationOutputs.get(0).Message);
        Test.stopTest();

        // Remove the invalid cart item
        delete cartItemWithNoSku;
    }

    // Inserts a cart item when we only know the cart id
    static void insertCartItem(String cartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];

        insertCartItem(cartId, cartDeliveryGroups.get(0).Id);
    }
    
    // Inserts a cart item that matches the cart and cart delivery group
    static void insertCartItem(String cartId, String cartDeliveryGroupId) {
        CartItem cartItem = new CartItem(
            CartId=cartId, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroupId
        );
        insert cartItem;
    }

    // Deletes the single cart item    
    static void deleteCartItem() {
        CartItem cartItem = [SELECT Id FROM CartItem WHERE Name = 'TestProduct' LIMIT 1];
        delete cartItem;
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"SKU_Test1":9999.00, "SKU_Test2":0.00}');
            res.setStatusCode(200);
            return res;
        }
    }
}