public with sharing class AccountController {
 @AuraEnabled
 public static string createNewAccount(string accountName){
   Account acc = new Account ();
   acc.Name=accountName;
   insert acc;
   return JSON.serialize(acc);
   
 }  
@AuraEnabled (cacheable=true)
public static List<Account> getAccount(Integer maxRecords){
    List <Account> accounts  =[SELECT Id , Name FROM Account ORDER BY CreatedDate DESC LIMIT : maxRecords];
    return accounts;
}
    
    }
