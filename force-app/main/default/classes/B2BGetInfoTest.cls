/**
 * Class containing tests for B2BGetInfo
 */
@IsTest with sharing public class B2BGetInfoTest {
	@TestSetup
    private static void createData() {
        B2BTestUtils utils = new B2BTestUtils();
        utils.setupStore();
    }
    
    @IsTest public static void getCartSummary() {
        User user = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'storebuyercontact@b2btestutils.test'];
        Id communityId = B2BTestUtils.getNetworkId();
        Id effectiveAccountId = user.Contact.AccountId;
        MockConnectApiService mockSvc = new MockConnectApiService();
        mockSvc.setupMockCartSummary();
        B2BGetInfo.connectApiSvc = mockSvc;
        
        System.runAs(user) {
            ConnectApi.CartSummary cartSummary = B2BGetInfo.getCartSummary(communityId, effectiveAccountId);
            
            System.assert(cartSummary != null);
            System.assert(cartSummary.accountId != null);
            System.assertEquals('MockCartId', cartSummary.cartId);
            System.assertEquals('USD', cartSummary.currencyIsoCode);
            System.assertEquals('131.60', cartSummary.grandTotalAmount);
            System.assertEquals('Cart Summary Name', cartSummary.name);
            System.assertEquals('MockOwnerId', cartSummary.ownerId);
            System.assertEquals('12345', cartSummary.purchaseOrderNumber);
            System.assertEquals(ConnectApi.CartStatus.Active, cartSummary.status);
            System.assertEquals('15.00', cartSummary.totalChargeAmount);
            System.assertEquals('110.00', cartSummary.totalListPrice);
            System.assertEquals('110.00', cartSummary.totalProductAmount);
            System.assertEquals('6', cartSummary.totalProductCount);
            System.assertEquals('6.60', cartSummary.totalTaxAmount);
            System.assertEquals(ConnectApi.CartType.Cart, cartSummary.type);
            System.assertEquals(3, cartSummary.uniqueProductCount);
            System.assert(cartSummary.webstoreId != null);
        }
    }
    
    class MockConnectApiService extends B2BTestUtils.MockConnectApiServiceAdapter {
        public override ConnectApi.PricingResult getProductPrices(String webStoreId, String effectiveAccountId, ConnectApi.PricingInput pricingInput) {
          return this.pricingResult;
        }
        public override ConnectApi.ProductCategoryPath getProductCategoryPath(String webstoreId, String productCategoryId) {
            return this.categoryPath;
        }
        public override ConnectApi.CartSummary getCartSummary(String webstoreId, String effectiveAccountId, String activeCartOrId) {
            return this.cartSummary;
        }
        public override ConnectApi.CartItem addItemToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, ConnectApi.CartItemInput cartInput) {
            return this.cartItem;
        }
    }
}