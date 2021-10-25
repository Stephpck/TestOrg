/**
 * Class containing tests for B2BUtils
 */
@IsTest public with sharing class B2BUtilsTest {
    @TestSetup
    private static void createData() {
        B2BTestUtils utils = new B2BTestUtils();
        utils.setupStore();
    }
    
    @IsTest public static void resolveCommunityIdToWebstoreId_FirstTime() {
        Id communityId = B2BTestUtils.getNetworkId();
        Id expectedWebstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        System.debug('WebstoreId: '+webstoreId);
        
        System.assertEquals(expectedWebstoreId, webstoreId);
    }
    
    @IsTest public static void resolveCommunityIdToWebstoreId_FromCache() {
        Id communityId = B2BTestUtils.getNetworkId();
        Id expectedWebstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
        B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        System.debug('WebstoreId: '+webstoreId);
        
        System.assertEquals(expectedWebstoreId, webstoreId);
    }
    
    @IsTest public static void resolveSortParam_AllValid() {
        System.assertEquals(ConnectApi.CartItemSortOrder.CreatedDateAsc, B2BUtils.resolveSortParam('CreatedDateAsc'));
        System.assertEquals(ConnectApi.CartItemSortOrder.CreatedDateDesc, B2BUtils.resolveSortParam('CreatedDateDesc'));
        System.assertEquals(ConnectApi.CartItemSortOrder.NameAsc, B2BUtils.resolveSortParam('NameAsc'));
        System.assertEquals(ConnectApi.CartItemSortOrder.NameDesc, B2BUtils.resolveSortParam('NameDesc'));
        System.assertEquals(ConnectApi.CartItemSortOrder.SalesPriceAsc, B2BUtils.resolveSortParam('SalesPriceAsc'));
        System.assertEquals(ConnectApi.CartItemSortOrder.SalesPriceDesc, B2BUtils.resolveSortParam('SalesPriceDesc'));
    }
    
    @IsTest public static void resolveSortParam_InvalidKey_ReturnsNull() {
        System.assert(B2BUtils.resolveSortParam('PriceAsc') == null);
    }
}