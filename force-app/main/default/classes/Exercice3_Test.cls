
@isTest
private class Exercice3_Test {

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        
        Account testAcc = new Account(Name = 'Test Competitor Account');
        insert testAcc;

        // Create a test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30)
        );
        insert testOpp;

        // Create a test Quote linked to the Opportunity
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            OpportunityId = testOpp.Id
        );
        insert testQuote;

        // 2. Test Scenario 1: Insert a new Quote Competitor
        Test.startTest();
        
        Competitor__c quoteComp = new Competitor__c(
            Quote__c = testQuote.Id,
            Account__c = testAcc.Id
        );
        
        // This will trigger your method (assuming this is called from a trigger handler)
        // If calling directly from a class, replace with: YourClassName.assignAccountToTop(new List<Competitor__c>{quoteComp}, null);
        insert quoteComp;
        
        Test.stopTest();

        // 3. Verify Results for Insert
        // Verify that an Opportunity-level competitor was created
        List<Competitor__c> oppComps = [SELECT Id, Opportunity__c, Account__c 
                                        FROM Competitor__c 
                                        WHERE Opportunity__c = :testOpp.Id];
        
        Assert.areEqual(1, oppComps.size(), 'One Opportunity competitor should have been automatically created.');
        Assert.areEqual(testAcc.Id, oppComps[0].Account__c, 'The Opportunity competitor should point to the correct Account.');
    }

    @isTest
    static void testPreventDuplicatesInBatch() {
        // Setup data for bulk/duplicate testing
        Account testAcc = new Account(Name = 'Test Competitor Account');
        insert testAcc;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30)
        );
        insert testOpp;

        Quote testQuote = new Quote(Name = 'Test Quote', OpportunityId = testOpp.Id);
        insert testQuote;

        // Test Scenario 2: Insert multiple records with the SAME Account & Quote in one batch
        Test.startTest();
        
        List<Competitor__c> batchComps = new List<Competitor__c>();
        batchComps.add(new Competitor__c(Quote__c = testQuote.Id, Account__c = testAcc.Id));
        batchComps.add(new Competitor__c(Quote__c = testQuote.Id, Account__c = testAcc.Id)); // Duplicate in same batch
        
        insert batchComps;
        
        Test.stopTest();

        // Verify that despite inserting 2 Quote Competitors, only 1 Opportunity Competitor was made
        List<Competitor__c> oppComps = [SELECT Id FROM Competitor__c WHERE Opportunity__c = :testOpp.Id];
        Assert.areEqual(1, oppComps.size(), 'Duplicate check failed: Only 1 Opportunity competitor should exist.');
    }
}
    
