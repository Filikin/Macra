@isTest
private class TestEFTController {

    static testMethod void EFTTest() 
    {
 		Club__c club = new Club__c (Name = 'Test club');
		insert club; 

  	 	Member__c m = new Member__c (Name='Joe Walsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=club.id);
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	m.Pays_by_direct_debit__c=true;
     	insert m;
		
		Statement__c s = new Statement__c();
		insert s;
		
		Membership__c mship1 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2014', Status__c='Paid', Statement__c=s.id);
		insert mship1;
    	
    	Bank__c testBank = new Bank__c (Name='900017', Name__c='Bank of Kelly');
    	insert testBank;
    	Contact newContact = [select ID,firstName, lastName, Membership_number__c, Bank__c, DD_Account_Name__c, DD_Account_number__c, Member_details__r.Most_recent_membership_amount__c
    		from Contact where FirstName='Joe' and LastName='Walsh890' limit 1];
    	newContact.Bank__c = testBank.id;
    	newContact.DD_Account_Name__c = 'Account name';
    	newContact.DD_Account_number__c = '12345678';
    	update newContact;
    	
	   	Campaign camp = new Campaign (Name='Test');
    	insert camp;
    	CampaignMember cm = new CampaignMember (CampaignID=camp.id, ContactId=newContact.id);
    	insert cm;
	    ApexPages.StandardController eftController = new ApexPages.StandardController(camp);
    	EFTController eft = new EFTController(eftController);
    }
}