public with sharing class Exercice5 {
  public static void handleBeforeDelete(List<Paymentt__c> oldPayments){
        for(Paymentt__c p : oldPayments){
            if(p.Status__c == 'Paid'){
                p.addError('A paid payment cannot be deleted.');
            }
        }
    }
    
    public static void handleAfterInsertUpdateDelete(List<Paymentt__c> newPayment, Map<Id, Paymentt__c> oldMap){
        Set<Id> oppIds = new Set<Id>();

        if(newPayment != null){
            for(Paymentt__c p : newPayment){
                if(p.OpportunityLookUp__c != null){
                    oppIds.add(p.OpportunityLookUp__c);
                }
                if(oldMap != null && oldMap.get(p.Id).OpportunityLookUp__c != p.OpportunityLookUp__c){
                    if(oldMap.get(p.Id).OpportunityLookUp__c != null){
                        oppIds.add(oldMap.get(p.Id).OpportunityLookUp__c);
                    }
                }
            }
        } else if(oldMap != null){
            for (Paymentt__c p : oldMap.values()) {
                if(p.OpportunityLookUp__c != null){
                    oppIds.add(p.OpportunityLookUp__c);
                }
            }
        }
            
        if(!oppIds.isEmpty()){
            recalculateOpportunities(oppIds, newPayment);
        }
    }

    private static void recalculateOpportunities(Set<Id> oppIds, List<Paymentt__c> TriggerNew){
        List<Opportunity> parentOpps = [
            SELECT Id, Amount, Total_Paid__c, 
            (SELECT Id, Amount__c, Status__c FROM Paymentts__r)
            FROM Opportunity
            WHERE Id IN :oppIds
        ];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(Opportunity opp : parentOpps){
            Decimal runningTotalPaid = 0.0;
            Decimal maxOppAmount = opp.Amount != null ? opp.Amount : 0.0;

            // FIXED: Changed opp.Payment__r to opp.Payments__r
            for(Paymentt__c p : opp.Paymentts__r){
                if(p.Status__c == 'Paid' && p.Amount__c != null){
                    runningTotalPaid += p.Amount__c;
                }
            }
            if(runningTotalPaid > maxOppAmount){
                if(TriggerNew != null){
                    for(Paymentt__c p : TriggerNew){
                        if(p.OpportunityLookUp__c == opp.Id && p.Status__c == 'Paid'){
                            p.addError('The total paid amount( '+ runningTotalPaid+ ') cannot exceed the Opportunity amount ('+ maxOppAmount + ').');
                        }
                    }
                }
            }
            else {
                opp.Total_Paid__c = runningTotalPaid;
                oppsToUpdate.add(opp);
            }
        }
        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
    }
}
    
