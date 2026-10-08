trigger PaymentTrigger on Paymentt__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    
    // 1. Prevent deletion of Paid payments
    if (Trigger.isBefore && Trigger.isDelete) {
        for (Paymentt__c p : Trigger.old) {
            if (p.Status__c == 'Paid') {
                p.addError('A paid payment cannot be deleted.');
            }
        }
        return; 
    }

    // 2. Gather impacted Opportunity IDs for recalculation
    Set<Id> oppIds = new Set<Id>();
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Paymentt__c p : Trigger.new) {
            if (p.OpportunityLookUp__c != null) {
                oppIds.add(p.OpportunityLookUp__c);
            }
            // If the Opportunity lookup changed, recalculate the old Opportunity too
            if (Trigger.isUpdate) {
                Paymentt__c oldP = Trigger.oldMap.get(p.Id);
                if (oldP.OpportunityLookUp__c != null && oldP.OpportunityLookUp__c != p.OpportunityLookUp__c) {
                    oppIds.add(oldP.OpportunityLookUp__c);
                }
            }
        }
    }
    
    if (Trigger.isDelete) {
        for (Paymentt__c p : Trigger.old) {
            if (p.OpportunityLookUp__c != null) {
                oppIds.add(p.OpportunityLookUp__c);
            }
        }
    }

    if (oppIds.isEmpty()) return;

    // 3. Query Opportunities and their related Paid payments to validate and recalculate
    Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>([
        SELECT Id, Amount, (SELECT Id, Amount__c FROM Paymentts__r WHERE Status__c = 'Paid') 
        FROM Opportunity WHERE Id IN :oppIds
    ]);

    // 4. Calculate new totals and validate against Opportunity Amount
    for (Id oppId : oppsToUpdate.keySet()) {
        Opportunity opp = oppsToUpdate.get(oppId);
        Decimal totalPaid = 0;

        for (Paymentt__c p : opp.Paymentts__r) {
            totalPaid += (p.Amount__c != null) ? p.Amount__c : 0;
        }

        // Validate Cap Limit: Ensure total does not exceed opportunity amount
        Decimal maxAmount = (opp.Amount != null) ? opp.Amount : 0;
        if (totalPaid > maxAmount) {
            // Throw error back to the records that caused the breach
            for (Paymentt__c p : Trigger.new) {
                if (p.OpportunityLookUp__c == oppId && p.Status__c == 'Paid') {
                    p.addError('The total paid amount (' + totalPaid + ') cannot exceed the Opportunitys amount (' + maxAmount + ').');
                }
            }
        } else {
            opp.Total_Paid__c = totalPaid;
        }
    }

    // 5. Commit the updated totals to the database
    if (!oppsToUpdate.isEmpty()) {
        update oppsToUpdate.values();
    }


}