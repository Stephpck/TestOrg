@isTest
private class B2BDeliverySampleTest {
    @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;

        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', TotalPrice = 100.00, CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;

    }

    @isTest static void testIntegrationRunsSuccessfully() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        // Test: execute the integration for the test cart ID.
        B2BDeliverySample apexSample = new B2BDeliverySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        // Verify: the integration executed successfully
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }

    @isTest static void testIntegrationError() {
        Test.startTest();
        // Test: execute the integration for the test cart ID.
        B2BDeliverySample apexSample = new B2BDeliverySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        // Verify: the integration executed successfully
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        Test.stopTest();
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":0.00,"otherCost":5.99}},{"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":0.00,"otherCost":6.99}}]');
            res.setStatusCode(200);
            return res;
        }
    }
}