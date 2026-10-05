trigger CourseDeliveryTrigger on Course_Delivery__c (before insert, before update) {
Trigger_Switch__mdt tsw = 
Trigger_Switch__mdt.getInstance('Course_Delivery_Trigger');

    if (tsw == null || tsw.Activate_Flag__c == true) {
    Set <Date> allHolidays =new Set <Date> ();
for (Holiday h :[SELECT ActivityDate FROM Holiday]){
    allHolidays.add(h.ActivityDate);
}
for ( Course_Delivery__c cd : Trigger.new ){
    Boolean checkDate =(Trigger.isInsert || Trigger.oldMap.get(cd.Id).Start_Date__c != cd.Start_Date__c);
if (checkDate && cd.Start_Date__c!=NULL){
    if(allHolidays.contains(cd.Start_Date__c)){
        cd.Start_Date__c.addError('Label.Invalid_Delivery_Start_Date');
                        }                   
                      }
                 }
             }
         }