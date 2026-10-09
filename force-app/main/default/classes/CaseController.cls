public with sharing class CaseController {
     @AuraEnabled(cacheable=true)
    public static List<Case> getCases(String searchNumber, String statusFilter) {
        // If search number is blank, return recent cases. Otherwise, search by case number.
        if (String.isBlank(searchNumber)&&(String.isBlank(statusFilter)||statusFilter=='ALL')) {
            return [SELECT Id, CaseNumber, Subject, Description, Status
            FROM Case 
            ORDER BY CreatedDate DESC LIMIT 50];
        } 
        String query ='SELECT Id, CaseNumber, Subject, Description, Status FROM Case WHERE Id != null';
      if (String.isNotBlank(searchNumber)) {
            String searchKey = '%' + searchNumber.trim() + '%';
            query += ' AND CaseNumber LIKE :searchKey';
        }
        
        // Append new picklist filter matching criteria if a status is active
        if (String.isNotBlank(statusFilter) && statusFilter != 'All') {
               query += ' AND Status = \'' + String.escapeSingleQuotes(statusFilter) + '\'';
        }
        
        query += ' ORDER BY CreatedDate DESC LIMIT 50';
        return Database.query(query);
    }       
    

    @AuraEnabled
    public static Case createCaseRecord(String subject, String description) {
        Case newCase = new Case(
            Subject = subject,
            Description = description,
            Status = 'New' // Default status
        );
        insert newCase;
        return newCase;
    }
    
}