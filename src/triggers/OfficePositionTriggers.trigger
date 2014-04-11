trigger OfficePositionTriggers on Office_position__c (after insert) 
{
	TriggerDispatcher.MainEntry ('Office_position__c', trigger.isBefore, trigger.isDelete, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isExecuting,
		trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
}