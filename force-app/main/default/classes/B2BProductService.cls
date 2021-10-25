/**
 * @description The purose of this class is to get product information back to store users
 * that cannot be retrieved via normal means such as the connect api. 
 * 
 * This class must be without sharing because not doing so results in errors that 
 * the BuyerAccount or BuyerGroupMember, etc., objects are not accessible. 
 */
public without sharing class B2BProductService {
    @TestVisible
    //private static final string GUEST_USER_BUYER_GROUP_NAME = 'Guest User';
    /**
     * Gets a List of the visible Products for the effectiveAccountId or Guest User Profile Id. 
     * The available products are those that are part of an Entitlement Policy that grants visible access.
     *
     * @param effectiveAccountId effectiveAccountId or Guest User Profile Id. 
     
    public Map<Id, Product2> getProducts(String effectiveAccountId) {
        List<CommerceEntitlementBuyerGroup> entitlementBuyerGroups = [
            SELECT PolicyId 
            FROM CommerceEntitlementBuyerGroup 
            WHERE BuyerGroupId IN (
                                      SELECT BuyerGroupId 
                                      FROM BuyerGroupMember 
                                      WHERE BuyerId = :effectiveAccountId 
                                  )
            AND Policy.IsActive = true 
            AND Policy.CanViewProduct = true
        ];

        Set<Id> policyIds = new Set<Id>();
        for (CommerceEntitlementBuyerGroup ebg : entitlementBuyerGroups) {
            policyIds.add(ebg.PolicyId);
        }

        Map<Id, Product2> products = new Map<Id, Product2>([
            SELECT Id, Name, StockKeepingUnit
            FROM Product2 
            WHERE Id IN (
                            SELECT ProductId
                            FROM CommerceEntitlementProduct 
                            WHERE PolicyId IN :policyIds
                        )
        ]);

        return products;
    }


    public Id getGuestUserProfileId() {
        List<BuyerGroupMember> guestBuyerGroupMember = [
            SELECT BuyerId
            FROM BuyerGroupMember
            WHERE Buyer.Type = 'GuestBuyerProfile'
            AND BuyerGroup.Name = :GUEST_USER_BUYER_GROUP_NAME
            LIMIT 1
        ];

        System.debug('got guest buyer group member: ' + guestBuyerGroupMember);
        return guestBuyerGroupMember[0].BuyerId;
    }
*/

    /**
     * Gets a map of Product Id to PriceBookEntry for the products available for the
     * specified effectiveAccountId. In general this method should not be called, 
     * and the ConnectAPI or product-search should be used instead; however, 
     * this may be used in areas such as PDF rendering where callouts are not allowed.
     * 
     * @param effectiveAccountId effectiveAccountId or Guest User Profile Id. 
     */
    public Map<Id, PricebookEntry> getProductMap(String effectiveAccountId)  {
        // Get Buyer Groups for Account
        List<BuyerGroupMember> buyerGroupMembers = [SELECT BuyerGroupId, BuyerId  
                                                    FROM BuyerGroupMember 
                                                    WHERE BuyerId = :effectiveAccountId];
        
        Set<Id> buyerGroupIds = new Set<Id>();
        for (BuyerGroupMember member : buyerGroupMembers) {
            buyerGroupIds.add(member.BuyerGroupId);
        }

        // Get Entitlement Policies for Buyer Groups
        List<CommerceEntitlementBuyerGroup> entitlementBuyerGroups = [SELECT PolicyId 
                                                                      FROM CommerceEntitlementBuyerGroup 
                                                                      WHERE BuyerGroupId IN :buyerGroupIds];
        
        Set<Id> policyIds = new Set<Id>();
        for (CommerceEntitlementBuyerGroup buyerGroup : entitlementBuyerGroups) {
            policyIds.add(buyerGroup.PolicyId);
        }
        
        // Filter out inactive policies or policies that do not allow viewing price or product
        Set<Id> filteredPolicyIds = new Map<Id, CommerceEntitlementPolicy>([SELECT Id 
                                                                            FROM CommerceEntitlementPolicy 
                                                                            WHERE Id IN :policyIds
                                                                                AND isActive = true
                                                                                AND canViewPrice = true
                                                                                AND canViewProduct = true]).keyset();
        // Get product ids for entitlement policies
        List<CommerceEntitlementProduct> entitlementProducts = [SELECT Product.Id 
                                                                FROM CommerceEntitlementProduct 
                                                                WHERE PolicyId IN :filteredPolicyIds];
        Set<Id> policyProductIds = new Set<Id>();
        for (CommerceEntitlementProduct entitlementProduct : entitlementProducts) {
            policyProductIds.add(entitlementProduct.Product.Id);
        }
        
        // Get active/valid Pricebooks for Buyer Groups
        Datetime currentDatetime = System.now();
        List<BuyerGroupPricebook> buyerGroupPricebooks = [SELECT BuyerGroupId,Pricebook2.Id 
                                                          FROM BuyerGroupPricebook 
                                                          WHERE BuyerGroupId IN :buyerGroupIds 
                                                            AND Pricebook2.isActive = true
                                                            AND (Pricebook2.ValidFrom = null OR Pricebook2.ValidFrom < :currentDatetime)
                                                            AND (Pricebook2.ValidTo = null OR Pricebook2.ValidTo > :currentDatetime)];
        Set<Id> pricebookIds = new Set<Id>();
        for (BuyerGroupPricebook book : buyerGroupPricebooks) {
            pricebookIds.add(book.Pricebook2.Id);
        }
        
        // Get PricebookEntries
        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2.Id, Product2.Name, Product2.Item_Number__c, Product2.Pallet_Size__c, Product2.Percent_Protein__c, Product2.Order_Requirements__c, Pallet_Price_Formula__c, UnitPrice, isActive, Pricebook2.Id
                                                 FROM PricebookEntry 
                                                 WHERE Pricebook2.Id IN :pricebookIds
                                                    AND Product2.Id IN :policyProductIds
                                                    AND isActive = true];
        
        // Create ProductId based map and only keep entries with lowest Unit Price
        Map<Id, PricebookEntry> productMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry entry : pricebookEntries) {
            if (entry.UnitPrice != null && productMap.containsKey(entry.Product2.Id)) {
                PricebookEntry existing = productMap.get(entry.Product2.Id);
                if (existing != null || existing.UnitPrice != null || entry.UnitPrice < existing.UnitPrice) {
                    productMap.put(entry.Product2.Id, entry);
                }
            } else {
                productMap.put(entry.Product2.Id, entry);
            }
        }

        return productMap;
    }
}