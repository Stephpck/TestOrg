@isTest
private class B2BPricingSampleTest {

    @isTest
    private static void testAlwaysReturnsSuccess() {
        Test.startTest();
        B2BPricingSample apexSample = new B2BPricingSample();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(null, null);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }
}