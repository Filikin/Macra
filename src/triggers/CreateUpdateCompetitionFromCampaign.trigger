trigger CreateUpdateCompetitionFromCampaign on Campaign (after delete, before insert, after update) 
{
	TriggerDispatcher.MainEntry ('Campaign', trigger.isBefore, trigger.isDelete, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isExecuting,
		trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
}