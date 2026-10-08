
@isTest
private class Exercice4_Test {

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
         Opportunity oppA = new Opportunity(
            Name = 'Test Opportunity A',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Identifier__c = 'EIT' // Required 3-digit code
        );
        
        Opportunity oppB = new Opportunity(
            Name = 'Test Opportunity B',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Identifier__c = 'ABC' // Required 3-digit code
        );
        
        insert new List<Opportunity>{oppA, oppB};

        // Step 2: Test Bulk Insert on Opportunity A
        List<Offer__c> offersToInsert = new List<Offer__c>();
        
        // Let's add 2 offers to Opportunity A at the exact same time
        offersToInsert.add(new Offer__c(Name = 'Offer 1', Opportunity__c = oppA.Id));
        offersToInsert.add(new Offer__c(Name = 'Offer 2', Opportunity__c = oppA.Id));

        Test.startTest();
        insert offersToInsert;
        Test.stopTest();

        // Step 3: Verify the Inserted Identifiers (EIT-000 and EIT-001)
        List<Offer__c> insertedOffers = [SELECT Id, Identifier__c, Opportunity__c FROM Offer__c WHERE Id IN :offersToInsert ORDER BY Name ASC];
        
        System.assertEquals(2, insertedOffers.size(), 'Two offers should have been created.');
        System.assertEquals('EIT-000', insertedOffers[0].Identifier__c, 'First offer should start sequence at 000.');
        System.assertEquals('EIT-001', insertedOffers[1].Identifier__c, 'Second bulk offer should increment to 001.');

        // Step 4: Test Reparenting (Move the second offer from Opp A to Opp B)
        Offer__c offerToMove = insertedOffers[1];
        offerToMove.Opportunity__c = oppB.Id; // Change parent to Opportunity B
        
        update offerToMove;

        // Step 5: Verify the Updated Identifier (Should change to ABC-000)
        Offer__c updatedOffer = [SELECT Id, Identifier__c FROM Offer__c WHERE Id = :offerToMove.Id];
        System.assertEquals('ABC-000', updatedOffer.Identifier__c, 'The moved offer should pull Opp B prefix and restart sequence at 000.');
    }
}
    
