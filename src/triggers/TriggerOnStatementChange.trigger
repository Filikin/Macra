trigger TriggerOnStatementChange on Statement__c (after update, before insert) 
{
	TriggerDispatcher.MainEntry ('Statement__c', trigger.isBefore, trigger.isDelete, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isExecuting,
		trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
}