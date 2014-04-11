trigger UpdateCampaignMember on CampaignMember (before insert, after update, before delete) 
{
	TriggerDispatcher.MainEntry ('CampaignMember', trigger.isBefore, trigger.isDelete, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isExecuting,
		trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
}