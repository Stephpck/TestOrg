@isTest
private class B2BShippingSampleTest {

    @testSetup
    private static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            TotalPrice=100.00,
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
    }
    
    @isTest
    private static void testIntegrationSuccess() {
        Test.startTest();
        // Test: execute the integration for the test cart ID.
        B2BShippingSample apexSample = new B2BShippingSample();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        Id cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1].Id;
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }
    
    @isTest
    private static void testFailsForNoCartItems() {
        // Test: execute the integration for the test cart ID.
        B2BShippingSample apexSample = new B2BShippingSample();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        delete [SELECT Id FROM CartItem WHERE CartId = :webCartId];
        Test.startTest();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        
        // Validate: The sample text that a product SKU is missing is returned as the failure output 
        System.assertEquals('An exception of type System.ListException has occurred: List index out of bounds: 0', cartValidationOutputs.get(0).Message);
        Test.stopTest();
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"SKU_Test1":{"taxAmount":2.8229012971048855,"taxRate":0.08,"taxName":"GST"}}');
            res.setStatusCode(200);
            return res;
        }
    }
}