public with sharing class Exercice2 {
    public static void countContact(List<Contact> TriggerNew, Map<Id, Contact> oldMap){
        List<String> Ids = new List<String>();
        for(Contact c : TriggerNew){
            if(oldMap == null || oldMap.get(c.id).accountId != c.AccountId ||  (c.firstName != oldMap.get(c.id).firstName || c.lastname != oldMap.get(c.id).lastname )){
                Ids.add(c.AccountId );
            }
        }
        
        if (!Ids.isEmpty()){
            List<Account> accounts = new List<Account> ([SELECT Id, 
                                        (SELECT Id, FirstName, LastName 
                                        FROM Contacts 
                                        WHERE FirstName = null 
                                        OR LastName = 'Smith')
                                    FROM Account
                                    ]);
            List<Account> updatedAccounts = new List<Account>();
            for (Account a : accounts){
                a.Contact_Count__c = a.Contacts.size();
                updatedAccounts.add(a);
            }
            update updatedAccounts;
        }
    }
}