
@isTest
private class PaymentTest {
    
    @isTest
    static void testPaymentRollupAndValidations() {
        // 1. Setup Test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // 2. Setup Test Opportunity (Populating the required Identifier__c field)
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000000,
            AccountId = acc.Id,
            Identifier__c = 'MOC' // Fixed the missing field error here
        );
        insert opp;

        Paymentt__c p1 = new Paymentt__c(
           OpportunityLookUp__c = opp.Id,
            Amount__c = 4000,
            Status__c = 'Paid',
            Payment_Date__c = Date.today()
        );
        insert p1;

        Opportunity checkOpp1 = [SELECT Total_Paid__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(4000, checkOpp1.Total_Paid__c, 'Total paid should roll up to 4000');

      
        Paymentt__c p2 = new Paymentt__c(
           OpportunityLookUp__c = opp.Id,
            Amount__c = 3000,
            Status__c = 'Pending'
        );
        insert p2;

        Opportunity checkOpp2 = [SELECT Total_Paid__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(4000, checkOpp2.Total_Paid__c, 'Pending payments must not affect Total Paid');

        // --- TEST 3: Breach Cap Limit (7,000 Paid + 4,000 Paid = 11,000 -> Exceeds 10,000) ---
        Paymentt__c p3 = new Paymentt__c(
          OpportunityLookUp__c = opp.Id,
            Amount__c = 7000,
            Status__c = 'Paid',
            Payment_Date__c = Date.today()
        );
        
        Test.startTest();
        try {
            insert p3;
            System.assert(false, 'Exception expected: Over-cap limit breach should be blocked.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('cannot exceed the Opportunitys amount'), 
                'Expected over-cap validation error, got: ' + e.getMessage());
        }

        // --- TEST 4: Delete Prevention of a Paid Record ---
        try {
            delete p1;
            System.assert(false, 'Exception expected: Paid payments cannot be deleted.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('A paid payment cannot be deleted'), 
                'Expected deletion validation error, got: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testReparentOpportunity() {
        // Setup base data
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;
        
        Opportunity opp1 = new Opportunity(Name = 'Opp 1', StageName = 'Prospecting', CloseDate = Date.today(), Amount = 5000, AccountId = acc.Id, Identifier__c = 'IDo');
        Opportunity opp2 = new Opportunity(Name = 'Opp 2', StageName = 'Prospecting', CloseDate = Date.today(), Amount = 5000, AccountId = acc.Id, Identifier__c = 'IDp');
        insert new List<Opportunity>{opp1, opp2};
        
        Paymentt__c p = new Paymentt__c(
            OpportunityLookUp__c = opp1.Id,
            Amount__c = 2000,
            Status__c = 'Paid',
            Payment_Date__c = Date.today()
        );
        insert p;
        
        // Move payment from Opp 1 to Opp 2
        p.OpportunityLookUp__c = opp2.Id;
        
        Test.startTest();
        update p;
        Test.stopTest();
        
        // Verify changes reflected on both opportunities
        Opportunity checkOpp1 = [SELECT Total_Paid__c FROM Opportunity WHERE Id = :opp1.Id];
        Opportunity checkOpp2 = [SELECT Total_Paid__c FROM Opportunity WHERE Id = :opp2.Id];
        
        System.assertEquals(0, checkOpp1.Total_Paid__c, 'Opp 1 total should drop to 0');
        System.assertEquals(2000, checkOpp2.Total_Paid__c, 'Opp 2 total should rise to 2000');
    }
}

    
