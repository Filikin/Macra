public class TriggerDispatcher 
{
    public static Boolean InTrigger = false;
    public interface ITriggerEntry 
    {
        void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
            List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap);
    }
    
    public static ITriggerEntry activeFunction = null;
    
    public static void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
        List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
    {
        if (TriggerObject == 'Campaign' && isAfter && isUpdate)
        {
            activeFunction = new CreateUpdateCompetitionFromCampaignClass();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
        }
        else if (TriggerObject == 'Campaign' && isBefore && isInsert)
        {
            activeFunction = new CreateUpdateCompetitionFromCampaignClass();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
        }
        else if (TriggerObject == 'Campaign' && isAfter && isDelete)
        {
            activeFunction = new CreateUpdateCompetitionFromCampaignClass();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
        }
        
        else if (TriggerObject == 'Competition_Member__c')
        {
            if (InTrigger) return; // removing && isDelete
            InTrigger = true;
            activeFunction = new CreateUpdateCampaignMemberOnCompMember();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
            InTrigger = false;
        }
        
        else if (TriggerObject == 'CampaignMember')
        {
            if (InTrigger) return; // removing && isDelete
            InTrigger = true;
            activeFunction = new UpdateCampaignMember();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
            InTrigger = false;
        }

        else if (TriggerObject == 'Statement__c')
        {
            if (InTrigger) return; // removing && isDelete
            InTrigger = true;
            activeFunction = new statementTriggerHandler();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
            InTrigger = false;
        }
    
        else if (TriggerObject == 'Office_position__c')
        {
            if (InTrigger) return; // removing && isDelete
            InTrigger = true;
            activeFunction = new CreateUpdateOfficePosition();
            activeFunction.MainEntry (TriggerObject, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting, newList, newMap, oldList, oldMap);
            InTrigger = false;
        }
}

}