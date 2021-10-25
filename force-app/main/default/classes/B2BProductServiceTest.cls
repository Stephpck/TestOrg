/**
 * Class containing tests for B2BPriceListPDFController
 */
@IsTest public class B2BProductServiceTest {
	@TestSetup
    private static void createData() {
        B2BTestUtils utils = new B2BTestUtils();
        utils.setupStore();
    }
    
    @IsTest
    public static void testGetProductMap() {
        User user = [SELECT Id, Contact.AccountId, FirstName, LastName FROM User WHERE Username = 'storebuyercontact@b2btestutils.test'];
        
        // Setup AuthorizationRequest input
        System.runAs(user) {
            Map<Id, PricebookEntry> productMap = new B2BProductService().getProductMap(user.Contact.AccountId);
            System.assertEquals(3, productMap.size());
            for (Id key : productMap.keySet()) {
                System.assert(productMap.get(key).Product2.Name.startsWith('Test Product '));
                System.assert(productMap.get(key).isActive);
            }
        }
    }
}