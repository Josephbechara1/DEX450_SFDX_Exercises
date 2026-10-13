public with sharing class QuoteCreationController {
    @AuraEnabled(cacheable=true)
    public static String getOpportunityLeaseType(Id oppId) {
        Opportunity opp = [SELECT Lease_Type__c FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED LIMIT 1];
        return opp.Lease_Type__c;
    }
}