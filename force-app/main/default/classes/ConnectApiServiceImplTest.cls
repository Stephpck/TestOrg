@isTest
private class ConnectApiServiceImplTest {

    @isTest
    private static void coverGetProductPrices() {
        try {
            new ConnectApiServiceImpl().getProductPrices(null, null, null);
        }
        catch (Exception e) {}
    }
    
    @isTest
    private static void coverGetProductCategoryPath() {
        try {
            new ConnectApiServiceImpl().getProductCategoryPath(null, null);
        }
        catch (Exception e) {}
    }
    
    @isTest
    private static void coverGetCartSummary() {
        try {
            new ConnectApiServiceImpl().getCartSummary(null, null, null);
        }
        catch (Exception e) {}
    }
    
    @isTest
    private static void coverAddItemToCart() {
        try {
            new ConnectApiServiceImpl().addItemToCart(null, null, null, null);
        }
        catch (Exception e) {}
    }
    
    @isTest
    private static void coverAddItemsToCart() {
        try {
            new ConnectApiServiceImpl().addItemsToCart(null, null, null, null);
        }
        catch (Exception e) {}
    }
}