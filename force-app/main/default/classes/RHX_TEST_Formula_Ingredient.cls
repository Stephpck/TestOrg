@isTest(SeeAllData=true)
public class RHX_TEST_Formula_Ingredient {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Formula_Ingredient__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Formula_Ingredient__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}