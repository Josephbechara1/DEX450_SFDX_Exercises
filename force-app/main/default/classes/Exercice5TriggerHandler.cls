
public with sharing class Exercice5TriggerHandler extends TriggerHandler implements ITriggerHandler{

    private Map<Id,Paymentt__c> newMap;
    private Map<Id,Paymentt__c> oldMap;
    private List<Paymentt__c> TriggerNew;
    private List<Paymentt__c> TriggerOld;
    
    public Exercice5TriggerHandler(){
        this.newMap = (Map<Id,Paymentt__c>) Trigger.newMap;
        this.oldMap = (Map<Id,Paymentt__c>) Trigger.oldMap;
        this.TriggerNew= (List<Paymentt__c>) Trigger.New;
        this.TriggerOld= (List<Paymentt__c>) Trigger.Old;
    }
    
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {
        
    }
    public override void afterInsert() {
         Exercice5.handleAfterInsertUpdateDelete(TriggerNew, oldMap);
    }
    
    public  override void beforeUpdate() {
        
        
    }
    public override void afterUpdate() {
         Exercice5.handleAfterInsertUpdateDelete(TriggerNew, oldMap);
    }
    

    
    public override void beforeDelete() {
     Exercice5.handleBeforeDelete(TriggerOld);   
    }
    
    public override void afterDelete() {
        Exercice5.handleAfterInsertUpdateDelete(null, oldMap);
    }
    
    public override void afterUnDelete() {
        
    }
}