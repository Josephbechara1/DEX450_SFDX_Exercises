trigger Exercice3_Trigger on Competitor__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
new Exercice3TriggerHandler().run();
}
