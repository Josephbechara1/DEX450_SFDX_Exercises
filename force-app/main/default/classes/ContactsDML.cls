public with sharing class ContactsDML {
    public static void standaloneDML(){
        Contact name1 = new Contact (LastName = 'Minkowitz');
        Contact name2 = new  Contact (LastName = 'Singh');
        List < Contact > contacts = new List< Contact > ( );
        contacts.add(name1);
        contacts.add(name2);
        insert contacts;
        System.debug(name1.Id);
        System.debug(name2.Id);
    }
    public static void databaseMethodDML(){
        Contact name1 = new Contact (LastName = 'Minkowitz');
        Contact name2 = new  Contact (LastName = 'Singh');
        List < Contact > contacts = new List< Contact > ( );
        contacts.add(name1);
        contacts.add(name2);
        Database.insert(contacts);
        System.debug(name1.Id);
        System.debug(name2.Id);
        
    }
    public static void databaseMethodPartialCommit(){
        Contact name1 = new Contact ();
        Contact name2 = new  Contact (LastName = 'Picasso');
        List < Contact > contacts = new List< Contact > ( );
        contacts.add(name1);
        contacts.add(name2);
        database.insert (contacts,false);
        
        System.debug(name2.Id);
    }
    public static void exceptionsDML(){
        List<Contact> contacts = new List<Contact>();
        
        Contact noName = new Contact();
        contacts.add(noName);
        
        Contact newContact = new Contact(LastName = 'Benett');
        contacts.add(newContact);
        
        Contact longName = new Contact(LastName = '00085chars00085chars00085chars00085chars00085chars00085chars00085chars00085chars00085');
        contacts.add(longName);
        List<Contact> newListContact = new List<Contact>(contacts);
        List <Database.SaveResult > srs = Database.insert(contacts,false );
        for (Database.SaveResult sr : srs){
            
            
            if (sr.isSuccess()==FALSE){
            List<Database.Error> errors =sr.getErrors();
            Integer i =1 ;
            String debugString= 'error:';
            for (Database.Error err : errors ){
                debugString += i+ '.'+err.getMessage()+';';
                i++;
                newListContact[1] = null;
                try {
                    List<Database.SaveResult> lsr2 = Database.insert(newListContact, false);
                } catch(ListException e) {
                    Error_Log__c error_null = new Error_Log__c();
                    error_null.Source__c = 'exceptionsDML';
                    error_null.Message__c = e.getMessage();
                    insert error_null;
                }
            }
        }
        }
    }
}    
    
    
