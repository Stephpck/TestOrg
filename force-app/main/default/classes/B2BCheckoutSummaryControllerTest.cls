@IsTest
private class B2BCheckoutSummaryControllerTest {
	@IsTest
	static void cartSummary() {
		B2BTestUtils testUtils = new B2BTestUtils();
		Account acct = testUtils.getAccount('Store Account');
		insert acct;
		WebStore store = testUtils.getStore('Test Store');
		insert store;
		List<Product2> productList = testUtils.getProducts(3);
		insert productList;

		WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=acct.Id);
        insert cart;

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;

        List<CartItem> cartItemList = new List<CartItem>();
        Integer i = 1;
        for(Product2 prod : productList) {
            CartItem cartItem = new CartItem(CartId=cart.Id, Product2Id = prod.Id, Quantity = 5, Type='Product', Name='TestProduct ' + i, SKU = 'TEST' + i, CartDeliveryGroupId=cartDeliveryGroup.Id);
            cartItemList.add(cartItem);
            i++;
        }
        insert cartItemList;

		List<CartItem> cartItemsBefore = [SELECT Id, UnitAdjustmentAmount, Quantity, SalesPrice, UnitAdjustedPrice, TotalLineAmount, TotalPrice FROM CartItem WHERE CartId = :cart.Id];
		boolean first = true;
		for(CartItem cartItem : cartItemsBefore) {
			if(first) {
				cartItem.UnitAdjustmentAmount = -10;
				cartItem.SalesPrice = 100;
				cartItem.UnitAdjustedPrice = 90;
			} else {
				cartItem.SalesPrice = 100;
				cartItem.UnitAdjustedPrice = 100;
			}
			first = false;
			cartItem.TotalLineAmount = cartItem.UnitAdjustedPrice * cartItem.Quantity;
			cartItem.TotalPrice = cartItem.UnitAdjustedPrice  * cartItem.Quantity;
		}
		update cartItemsBefore;

		Test.startTest();
		B2BCheckoutSummaryController.CartSummaryResult result = B2BCheckoutSummaryController.getCartSummary(cart.Id);
		Test.stopTest();
		WebCart resultCart = result.cart;
		System.assertEquals(1450, resultCart.TotalProductAmount, 'total product amount should be 1450');
		System.assertEquals(0, resultCart.TotalChargeAmount, 'total charge amount should be 0');
		System.assertEquals(0, resultCart.TotalTaxAmount, 'total tax amount should be 0');
		System.assertEquals(1450, resultCart.GrandTotalAmount, 'grand total should be 1450');
	}
}