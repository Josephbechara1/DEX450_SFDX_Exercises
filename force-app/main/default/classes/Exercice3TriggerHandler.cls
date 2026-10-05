

public with sharing class Exercice3TriggerHandler extends TriggerHandler implements ITriggerHandler{

    private Map<Id, Competitor__c> newMap;
    private Map<Id, Competitor__c> oldMap;
    private List<Competitor__c> TriggerNew;
    private List<Competitor__c> TriggerOld;
    
    public Exercice3TriggerHandler(){
        this.newMap = (Map<Id, Competitor__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Competitor__c>) Trigger.oldMap;
        this.TriggerNew= (List<Competitor__c>) Trigger.New;
        this.TriggerOld= (List<Competitor__c>) Trigger.Old;
    }
    
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {
 Exercice3.checkCompetitorLinks(TriggerNew, oldMap, newMap);
    
    }
    public override void afterInsert() {
         Exercice3.assignAccountToTop(TriggerNew, oldMap);
    }
    public  override void beforeUpdate() {
         Exercice3.checkCompetitorLinks(TriggerNew, oldMap, newMap);
    
    }
    public override void afterUpdate() {
             Exercice3.assignAccountToTop(TriggerNew, oldMap);}
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUnDelete() {
        
    }
}
    
    
