trigger Exercice4_Trigger on Offer__c (before insert, before update) {
new Exercice4TriggerHandler().run();
}