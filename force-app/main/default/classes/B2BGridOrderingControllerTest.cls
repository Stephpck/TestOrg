@IsTest
private with sharing class B2BGridOrderingControllerTest {
    @IsTest
    private static void getProductsWithCategoriesAndPrices() {
        B2BTestUtils utils = new B2BTestUtils();
        utils.setupStore();
        
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'storebuyercontact@b2btestutils.test' Limit 1];

        System.runAs(user) {
            Test.startTest();
            List<B2BGridOrderingController.ProductsByCategoryWrapper> result = B2BGridOrderingController.getProductsWithCategoriesAndPrices(user.Contact.AccountId);
            Test.stopTest();
            System.assert(result != null);
            System.assertEquals(1, result.size());
            System.assertEquals('Test Category', result[0].categoryName);
            System.assert(result[0].products != null);
            System.assertEquals(3, result[0].products.size());
        }
    }

    @isTest
    private static void testAddItemsToCart() {
        Id communityId = B2BTestUtils.getNetworkId();
        B2BTestUtils utils = new B2BTestUtils();
        utils.setupStore();
        B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        MockConnectApiService mockSvc = new MockConnectApiService();
        mockSvc.setupMockCartSummary();
        B2BGridOrderingController.connectApiSvc = mockSvc;
        
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'storebuyercontact@b2btestutils.test' Limit 1];
        
        System.runAs(user) {
            Test.startTest();
            List<B2BGridOrderingController.ProductQuantity> itemList = new List<B2BGridOrderingController.ProductQuantity>();
            List<B2BGridOrderingController.ProductsByCategoryWrapper> result = B2BGridOrderingController.getProductsWithCategoriesAndPrices(user.Contact.AccountId);
            System.assert(result != null);
            System.assertEquals(1, result.size());
            System.assertEquals('Test Category', result[0].categoryName);
            System.assert(result[0].products != null);
            System.assertEquals(3, result[0].products.size());
            for (B2BGridOrderingController.ProductWrapper p : result[0].products) {
                B2BGridOrderingController.ProductQuantity item = new B2BGridOrderingController.ProductQuantity();
                item.productId = p.product.Id;
                item.quantity = '1';
                itemList.add(item);
            }
            Boolean validCart = B2BGridOrderingController.addItemsToCart(itemList, user.Contact.AccountId, communityId);
            System.assertEquals(true, validCart);
            Test.stopTest();
        }
    }

    /*@isTest(seeAllData=true)
    private static void testAddItemsToCart_SeeAllData() {
        Id communityId = B2BTestUtils.getNetworkId();
        Id webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        Webstore store = [SELECT Id, ExternalId__c FROM Webstore WHERE Id = :webstoreId];
        B2BTestUtils utils = new B2BTestUtils();
        utils.setupStore(store, true);
        
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'storebuyercontact@b2btestutils.test' Limit 1];
        
        System.runAs(user) {
            Test.startTest();
            List<B2BGridOrderingController.ProductQuantity> itemList = new List<B2BGridOrderingController.ProductQuantity>();
            List<B2BGridOrderingController.ProductsByCategoryWrapper> result = B2BGridOrderingController.getProductsWithCategoriesAndPrices(user.Contact.AccountId);
            System.assert(result != null);
            System.assertEquals(1, result.size());
            System.assertEquals('Test Category', result[0].categoryName);
            System.assert(result[0].products != null);
            System.assertEquals(3, result[0].products.size());
            for (B2BGridOrderingController.ProductWrapper p : result[0].products) {
                B2BGridOrderingController.ProductQuantity item = new B2BGridOrderingController.ProductQuantity();
                item.productId = p.product.Id;
                item.quantity = '1';
                itemList.add(item);
            }
            Boolean validCart = B2BGridOrderingController.addItemsToCart(itemList, user.Contact.AccountId, communityId);
            System.assertEquals(true, validCart);
            Test.stopTest();
        }
    }*/
    
    private class MockConnectApiService extends B2BTestUtils.MockConnectApiServiceAdapter {
    }
}