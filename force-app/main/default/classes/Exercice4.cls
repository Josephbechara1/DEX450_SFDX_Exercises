public with sharing class Exercice4 {
 
    public static void generateIdentifierOnInsert(List<Offer__c> newOffers){
        generateIdentifiers(newOffers, null);
    }
    public static void generateIdentifiersOnUpdate(List<Offer__c> newOffers, Map<Id, Offer__c> oldOffersMap){
        List<Offer__c> offersToRecalculate = new List<Offer__c>();
        
        for(Offer__c currentOffer : newOffers){
            Offer__c oldOffer = oldOffersMap.get(currentOffer.Id);
            if(currentOffer.Opportunity__c != oldOffer.Opportunity__c){
                offersToRecalculate.add(currentOffer);
            }
        }
        if(!offersToRecalculate.isEmpty()){
            generateIdentifiers(offersToRecalculate, oldOffersMap);
        }
    }

    private static void generateIdentifiers(List<Offer__c> offers, Map<Id, Offer__c> oldOffersMap){
        Set<Id> oppIds = new Set<Id>();
        for(Offer__c off : offers){
            if(off.Opportunity__c != null){
                oppIds.add(off.Opportunity__c);
            }
        }
        if(oppIds.isEmpty()) return;
        Map<Id, Opportunity> oppWithOffersMap = new Map<Id, Opportunity>([
            SELECT Id, Identifier__c ,(SELECT Id FROM Offers__r)
            FROM Opportunity 
            WHERE Id IN : oppIds
        ]);

        Map<Id, Integer> oppToMaxCounterMap = new Map<Id, Integer>();

        for(Id oppId : oppWithOffersMap.keySet()){
            Opportunity opp = oppWithOffersMap.get(oppId);
            Integer existingCount = opp.Offers__r != null ? opp.Offers__r.size():0;
            oppToMaxCounterMap.put(oppId, existingCount);
        }
        //Process loop to build out the formatted string
        for(Offer__c off: offers){
            if(off.Opportunity__c == null ) continue;
            Opportunity parentOpp = oppWithOffersMap.get(off.Opportunity__c);
            String oppCode = (parentOpp != null && parentOpp.Identifier__c != null) ? parentOpp.Identifier__c : 'UNK';
            
            //Get current count from map
            Integer nextCounter = oppToMaxCounterMap.get(off.Opportunity__c);

            //Format to 3-digit string
            String formattedCounter = String.valueOf(nextCounter).leftPad(3, '0');

            //set the read-only field string sequence
            off.Identifier__c= oppCode + '-' + formattedCounter;
            
            // Increment the counter dynamically in-memory so bulk actions map correctly
            oppToMaxCounterMap.put(off.Opportunity__c, nextCounter + 1);
        }

      
    }
   
}