public with sharing class AccountContactController {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id accountId) {
        return [
            SELECT Id, FirstName, LastName, Email, Phone 
            FROM Contact 
            WHERE AccountId = :accountId 
            WITH SECURITY_ENFORCED
            ORDER BY LastName, FirstName
        ];
    }

    @AuraEnabled
    public static void deleteContact(Id contactId) {
        try {
            delete [SELECT Id FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
