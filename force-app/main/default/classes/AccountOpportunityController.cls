public with sharing class AccountOpportunityController {
   public class AccountOpportunityWrapper {
        @AuraEnabled public Account acc {get;set;}
        @AuraEnabled public List<Opportunity> opps {get;set;}
        @AuraEnabled public Integer oppCount {get;set;}
        @AuraEnabled public Decimal totalAmount {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountOpportunityWrapper> getAccountOpportunities() {
        List<AccountOpportunityWrapper> wrapperList = new List<AccountOpportunityWrapper>();

        // Basic trainee query: Fetch Accounts and their related Opportunities
        List<Account> accountList = [SELECT Id, Name, 
                                     (SELECT Id, Name, StageName, Amount, IsClosed FROM Opportunities) 
                                     FROM Account LIMIT 20];

        for (Account a : accountList) {
            AccountOpportunityWrapper wrap = new AccountOpportunityWrapper();
            wrap.acc = a;
            wrap.opps = a.Opportunities;
            wrap.oppCount = a.Opportunities.size();
            
            // Simple loop to calculate the total amount
            Decimal sum = 0;
            for (Opportunity o : a.Opportunities) {
                if (o.Amount != null) {
                    sum += o.Amount;
                }
            }
            wrap.totalAmount = sum;
            wrapperList.add(wrap);
        }
        return wrapperList;
    }

    @AuraEnabled
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Basic update query
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId LIMIT 1];
        opp.StageName = newStage;
        update opp;
    }
}

    
