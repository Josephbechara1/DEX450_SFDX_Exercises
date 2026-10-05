public with sharing class Exercice3 {
   public static void checkCompetitorLinks(List<Competitor__c> newList, Map<Id,Competitor__c> oldMap, Map<Id,Competitor__c> newMap){

        // Creating a map of Account IDs to Competitors. One for the quotes and one for the opps
        Map<Id,Competitor__c> accountIdsToCompetitorForQuotesMap = new Map<Id,Competitor__c>();
        Map<Id,Competitor__c> accountIdsToCompetitorForOppsMap = new Map<Id,Competitor__c>();

        // Looping over the new list of created competitors
        for(Competitor__c comp : newList){

            // If the old map is null (ie: in a create state) or the quote has been changed or the account has been changed
            if(
                (oldMap == null || oldMap.get(comp.Id).Quote__c != comp.Quote__c || oldMap.get(comp.Id).Account__c != comp.Account__c)
                    &&
                (comp.Quote__c != null && comp.Account__c != null)
            ) {
                // Add the account Id and the competitor to the corresponsing map
                accountIdsToCompetitorForQuotesMap.put(comp.Account__c,comp);
            }

            // If the old map is null (ie: in a create state) or the opportunity has been changed or the account has been changed
            if(
                (oldMap == null || oldMap.get(comp.Id).Opportunity__c != comp.Opportunity__c || oldMap.get(comp.Id).Account__c != comp.Account__c)
                    &&
                (comp.Opportunity__c != null && comp.Account__c != null)
            ) {
                // Add the account Id and the competitor to the corresponsing map
                accountIdsToCompetitorForOppsMap.put(comp.Account__c,comp);
            }
        }

        // If the map isn't empty
        if(!accountIdsToCompetitorForQuotesMap.isEmpty()){

            // Looping over all the accounts that have the account ids in the map and quote is not null
            for(Competitor__c comp : [SELECT Id,Account__c FROM Competitor__c WHERE Account__c IN :accountIdsToCompetitorForQuotesMap.keySet() AND Quote__c != null]){

                // If the comprtitor is not part of the current transaction
                if(newMap == null || (newMap != null && !newMap.keySet().contains(comp.Id))){
                    // Getting the competitor from the filled map
                    Competitor__c accountComp = accountIdsToCompetitorForQuotesMap.get(comp.Account__c);

                    // Adding the error
                    accountComp.addError('This account is already related to a quote through a competitor');
                }

            }
        }

        // If the map isn't empty
        if(!accountIdsToCompetitorForOppsMap.isEmpty()){

            // Looping over all the accounts that have the account ids in the map and opportunity is not null
            for(Competitor__c comp : [SELECT Id,Account__c FROM Competitor__c WHERE Account__c IN :accountIdsToCompetitorForOppsMap.keySet() AND Opportunity__c != null]){

                // If the comprtitor is not part of the current transaction
                if(newMap == null || (newMap != null && !newMap.keySet().contains(comp.Id))){
                    // Getting the competitor from the filled map
                    Competitor__c accountComp = accountIdsToCompetitorForOppsMap.get(comp.Account__c);

                    // Adding the error
                    accountComp.addError('This account is already related to an opportunity through a competitor');
                }
            }
        }

    }

    public static void assignAccountToTop(List<Competitor__c> newList, Map<Id,Competitor__c> oldMap){
      // Checks if a competitor is brand new with a quote and account assigned OR if an existing record was updated to change its quote or account
        Map<Id, Competitor__c> quoteIdToCompetitorMap = new Map<Id, Competitor__c>();
        for (Competitor__c c : newList){
            Boolean isNewQuoteCompetitor = (oldMap == null && c.Quote__c != null && c.Account__c != null);
            Boolean isUpdatedQuoteCompetitor = (oldMap != null && c.Quote__c != null && c.Account__c != null && (oldMap.get(c.Id).Quote__c != c.Quote__c || oldMap.get(c.Id).Account__c != c.Account__c));
            //if either condition is met its stores the record in a map called quoteIdCompetitorMap using the quote id as a key
            if (isNewQuoteCompetitor || isUpdatedQuoteCompetitor){
                quoteIdToCompetitorMap.put(c.Quote__c, c);
            }
        }
        // if there is no relevant records the code stops executing immediately via return 
        if (quoteIdToCompetitorMap.isEmpty()){
            return;
        }
        // map quote IDs to parent Quote object to fetch parent Opportunity IDs
        //i am runnig a SOQL query to fetch the opportunity for all the quotes collected in  the first part (Step 1 ) it stores them in parentQuotingMap
        List<Quote> parentQuotingMap = [SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIdToCompetitorMap.keySet()];
        Map<String, Competitor__c> targetOppAccInDb = new Map<String, Competitor__c>();

        // records to insert
        List<Competitor__c> newOppCompetitors = new List<Competitor__c>();

       //  loop through the valid competitors again to build lists of opportunity Ids and Accounts Ids that need validtion 
        for (Quote quote : parentQuotingMap){
            /*Quote parentQuote = parentQuotingMap.get(quoteComp.Quote__c);
            if (parentQuote != null && parentQuote.OpportunityId != null){
               
                quoteComp.Opportunity__c = parentQuote.OpportunityId;
                newOppCompetitors.add(quoteComp);
            }*/

            Competitor__c c = new Competitor__c();
            c.Opportunity__c = quote.OpportunityId;
            c.Account__c = quoteIdToCompetitorMap.get(quote.Id).Account__c;
            newOppCompetitors.add(c);
        }

        if (!newOppCompetitors.isEmpty()) {
            insert newOppCompetitors;
        } 
    }
}
