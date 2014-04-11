public with sharing class EFTController 
{
    public List<Contact> memberList {get;set;}
    public String processingDate {get;set;}
    public String JULIANDate {get;set;}
    public String UserTrailer {get;set;}
    public String VolumeHeader {get;set;}
    public String FileHeader {get;set;}
    public String UserHeader {get;set;}
    public String ContraTotal {get;set;}
    Campaign eftCampaign = null;
    
    public EFTController(ApexPages.StandardController controller) 
    {
    	eftCampaign = (Campaign)controller.getRecord();
    	if (eftCampaign.id == null) // then this is running from the maintenance page
    	{
		    String requiredStatus;
	        if (system.today().month() >= 9) requiredStatus = (date.today().year()+1).format().replace(',','');
	        else requiredStatus = (date.today().year()).format().replace(',','');
	        requiredStatus += ' Paid';
	        memberList = [select ID, firstName, lastName, Membership_number__c, Bank__r.Name, DD_Account_Name__c, DD_Account_number__c, Member_details__r.Most_recent_membership_amount__c,
	            Extra_EFT_Data__c
	            from Contact
	            where Member_Details__c != null and Member_Details__r.Pays_by_direct_debit__c = true and Membership_status__c = :requiredStatus and Member_details__r.Most_recent_membership_amount__c > 0];
    	}
    	else // running from a campaign
    	{
        	memberList = [select ID, firstName, lastName, Membership_number__c, Bank__r.Name, DD_Account_Name__c, DD_Account_number__c, Member_details__r.Most_recent_membership_amount__c,
         	   Extra_EFT_Data__c
            	from Contact
            	where Member_Details__c != null and Member_details__r.Most_recent_membership_amount__c > 0 and id in (select contactid from campaignmember where CampaignID=:eftCampaign.Id)];
    	}
        processingDate = (date.today().year()).format().right(2) + (date.today().month()>9?date.today().month().format():'0'+date.today().month().format()) + (date.today().day()>9?date.today().day().format():'0'+date.today().day().format());
        system.debug ('Processing date: ' + processingDate);
         
        VolumeHeader = 'VOL1001111' + ''.leftPad(31) + '302821' + ''.leftPad (33);
        FileHeader = 'HDR1 A302821S         00000 00000 00000F       ' + processingDate + '0100     B' + ''.leftPad(17);                 
                                                                       
         
        JULIANDate = (date.today().year()).format().right(2);
        if (date.today().dayOfYear() < 10) JULIANDate += '00' + date.today().dayOfYear();
        else if (date.today().dayOfYear() < 100) JULIANDate += '0' + date.today().dayOfYear();
        else JULIANDate += date.today().dayOfYear();
        
        UserHeader = 'UHL1 ' +  JULIANDate + '000090    010000001 DAILY  002' + ''.leftPad(40);                                        
        AddExtraDataAndTotals ();
    }
    
    public void AddExtraDataAndTotals ()
    {
        Decimal membershipTotal = 0.0;
        for (Contact oneMem: memberList)
        {
        	try
        	{
	            oneMem.Extra_EFT_Data__c = '0000000' + oneMem.Member_details__r.Most_recent_membership_amount__c.format().replace('.','') + '00';
	            oneMem.Extra_EFT_Data__c += 'MACRA NA FEIRME'.leftPad(18);
	            oneMem.Extra_EFT_Data__c += oneMem.Membership_number__c.leftPad(18);
	            oneMem.Extra_EFT_Data__c += oneMem.DD_Account_Name__c.left(18).leftPad(18);
	                
	            membershipTotal += oneMem.Member_details__r.Most_recent_membership_amount__c;
	        }
	        catch (Exception e)
	        {
	        	throw new MyException('Cannot process ETF file because of an error on member ' + oneMem.Membership_number__c + '. Please check this member\'s account name and number.');
        	}
        }
        ContraTotal = membershipTotal.format().replace(',','').leftPad(9).replace(' ', '0') + '00';
        UserTrailer = 'UTL100' + ContraTotal;
        UserTrailer += '00' + ContraTotal;
        UserTrailer += memberList.size().format().replace(',','').leftPad(7).replace(' ', '0');
        UserTrailer += '0000001';
        UserTrailer += ''.leftPad(36);
    }

}