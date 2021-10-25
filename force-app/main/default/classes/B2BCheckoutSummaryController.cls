public inherited sharing class B2BCheckoutSummaryController {
  @AuraEnabled(cacheable=true)
	public static CartSummaryResult getCartSummary(Id cartId) {
		WebCart cart = [SELECT Id, TotalProductAmount, TotalChargeAmount, TotalTaxAmount, GrandTotalAmount, TotTons__c FROM WebCart WHERE Id = :cartId];
		return new CartSummaryResult(cart);
	}

	public class CartSummaryResult {
		@AuraEnabled
		public WebCart cart;

		public CartSummaryResult(WebCart c) {
			this.cart = c;
		}
	}
}