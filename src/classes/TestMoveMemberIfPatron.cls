@isTest
private class TestMoveMemberIfPatron {

    static testMethod void MovePatronTest() 
    {
		Club__c testclub = new Club__c (Name = 'Test club');
		insert testclub; 
		
 	  	Member__c m = new Member__c (Name='NewOfficer', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851034567';
    	m.Email__c = 'test2@test.com';
    	m.Home_club__c = testClub.id;
    	m.Patron__c = false;
    	insert m;
    	
    	m.Patron__c = true;
    	try
    	{
    		update m;
    	}
    	catch (Exception e)
    	{
    		system.assertEquals ('System.DmlException', e.getTypeName());
    	}
    	
    	Club__c patronClub = new Club__c (Name = 'Patrons');
    	insert patronClub;
    	
    	update m;
    	
    	m = [select Home_club__c from Member__c where ID = :m.id];
    	system.assertEquals (patronClub.id, m.Home_club__c);
    }
}