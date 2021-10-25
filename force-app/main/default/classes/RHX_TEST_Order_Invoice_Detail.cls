@isTest(SeeAllData=true)
public class RHX_TEST_Order_Invoice_Detail {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Order_Invoice_Detail__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Order_Invoice_Detail__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}