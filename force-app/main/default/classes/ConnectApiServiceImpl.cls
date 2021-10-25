public class ConnectApiServiceImpl implements ConnectApiService {
    public ConnectApi.PricingResult getProductPrices(String webStoreId, String effectiveAccountId, ConnectApi.PricingInput pricingInput) {
        return ConnectApi.CommerceStorePricing.getProductPrices(webStoreId, effectiveAccountId, pricingInput);
    }
    public ConnectApi.ProductCategoryPath getProductCategoryPath(String webstoreId, String productCategoryId) {
        return ConnectApi.CommerceCatalog.getProductCategoryPath(webstoreId, productCategoryId);
    }
    public ConnectApi.CartSummary getCartSummary(String webstoreId, String effectiveAccountId, String activeCartOrId) {
        return ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeCartOrId);
    }
    public ConnectApi.CartItem addItemToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, ConnectApi.CartItemInput cartInput) {
        return ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, activeCartOrId, cartInput);
    }
    public ConnectApi.BatchResult[] addItemsToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, List<ConnectApi.BatchInput> cartItems) {
        return ConnectApi.CommerceCart.addItemsToCart(webstoreId, effectiveAccountId, activeCartOrId, cartItems);
    }
}