public interface ConnectApiService {
	ConnectApi.PricingResult getProductPrices(String webStoreId, String effectiveAccountId, ConnectApi.PricingInput pricingInput);
    ConnectApi.ProductCategoryPath getProductCategoryPath(String webstoreId, String productCategoryId);
    ConnectApi.CartSummary getCartSummary(String webstoreId, String effectiveAccountId, String activeCartOrId);
    ConnectApi.CartItem addItemToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, ConnectApi.CartItemInput cartInput);
    ConnectApi.BatchResult[] addItemsToCart(String webstoreId, String effectiveAccountId, String activeCartOrId, List<ConnectApi.BatchInput> cartItems);
}