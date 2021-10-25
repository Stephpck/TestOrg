/**
 * This class is necessary because there were breaking changes
 * introduced in Apex when moving from v50 to v51 that made it
 * so that upserting while relating to the account was impossible. 
 */
@isTest
public class B2BTestUtilsBuyerHelper {
    
    public BuyerGroupMember getBuyerGroupMember(Account account, BuyerGroup buyerGroup) {
        BuyerGroupMember member = new BuyerGroupMember();
        member.Buyer = new Account(ExternalId__c = account.ExternalId__c);
        member.BuyerGroup = new BuyerGroup(ExternalId__c = buyerGroup.ExternalId__c);

        return member;
    }
}