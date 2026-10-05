
public with sharing class Exercice4TriggerHandler extends TriggerHandler implements ITriggerHandler{

    private Map<Id, Offer__c> newMap;
    private Map<Id, Offer__c> oldMap;
    private List<Offer__c> TriggerNew;
    private List<Offer__c> TriggerOld;
    
    public Exercice4TriggerHandler(){
        this.newMap = (Map<Id, Offer__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Offer__c>) Trigger.oldMap;
        this.TriggerNew= (List<Offer__c>) Trigger.New;
        this.TriggerOld= (List<Offer__c>) Trigger.Old;
    }
    
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {
        Exercice4.generateIdentifierOnInsert(TriggerNew);
    }
    public override void afterInsert() {
    }
    public  override void beforeUpdate() {
        Exercice4.generateIdentifiersOnUpdate(TriggerNew, oldMap);
        
    }
    public override void afterUpdate() {
    }
    
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUnDelete() {
        
    }
}