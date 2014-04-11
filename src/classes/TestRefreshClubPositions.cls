/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestRefreshClubPositions {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Club__c c1 = new Club__c(Name = 'Test Club 1');
        insert c1;
        
        Club__c c2 = new Club__c(Name = 'Test Club 2');
        insert c2;
        
        Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=c1.id);
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
		
  	 	Member__c m2 = new Member__c (Name='JoeWalsh891', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=c1.id);
    	m2.City_or_County__c='County Clare';
    	m2.Phone__c = '0851234566';
    	m2.Email__c = 'test1@test.com';
    	insert m2;
         
        Member__c m3 = new Member__c (Name='JoeWalsh893', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=c1.id);
    	m3.City_or_County__c='County Clare';
    	m3.Phone__c = '0851234566';
    	m3.Email__c = 'test1@test.com';
    	insert m3;
    	
    	Member__c m4 = new Member__c (Name='JoeWalsh894', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=c1.id);
    	m4.City_or_County__c='County Clare';
    	m4.Phone__c = '0851234566';
    	m4.Email__c = 'test1@test.com';
    	insert m4;
    	
    	Member__c m5 = new Member__c (Name='JoeWalsh895', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=c1.id);
    	m5.City_or_County__c='County Clare';
    	m5.Phone__c = '0851234566';
    	m5.Email__c = 'test1@test.com';
    	insert m5;
    	
    	Member__c m6 = new Member__c (Name='JoeWalsh896', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=c2.id);
    	m6.City_or_County__c='County Clare';
    	m6.Phone__c = '0851234566';
    	m6.Email__c = 'test1@test.com';
    	insert m6;
    	
    	Office_position__c p1 = new Office_position__c (Member__c = m.id, Position__c = 'Club Chair', Start_Date__c=Date.newInstance(2013, 6, 5), End_Date__c=Date.newInstance(2014,11,11), Club__c=c1.id);
		insert p1;
		
		Office_position__c p2 = new Office_position__c (Member__c = m2.id, Position__c = 'Club Secretary', Start_Date__c=Date.newInstance(2014, 1, 5), End_Date__c=Date.newInstance(2015,10,01), Club__c=c1.id);
		insert p2;
		
		Office_position__c p3 = new Office_position__c (Member__c = m3.id, Position__c = 'Club PRO', Start_Date__c=Date.newInstance(2014, 1, 5), End_Date__c=Date.newInstance(2015,10,01), Club__c=c1.id);
		insert p3;
		
		Office_position__c p4 = new Office_position__c (Member__c = m4.id, Position__c = 'Club Treasurer', Start_Date__c=Date.newInstance(2014, 1, 5), End_Date__c=Date.newInstance(2015,10,01), Club__c=c1.id);
		insert p4;
        
        // Now make things wrong
        c1.Club_Chair__c = m4.id;
        c1.Club_Secretary__c = m3.id;
        c1.Club_PRO__c = m2.id;
        c1.Club_Treasurer__c = null;
        update c1;
        
        //Now run the test 
        RefreshClubPositions mytest = new RefreshClubPositions();
        mytest.AddNewPositions();
         
        
        //Check it worked
        List<Club__c> checkClubs = new List<Club__c>([SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c1.Id]);	
        Club__c cc = checkClubs[0];
        
        System.assertEquals(cc.Club_Chair__c, m.Id);
        System.assertEquals(cc.Club_Secretary__c, m2.Id);
        System.assertEquals(cc.Club_PRO__c, m3.Id);
        System.assertEquals(cc.Club_Treasurer__c,m4.Id);
        
              
        //Now update some end dates to expire them 
        Date testDate = Date.today().addDays(-1);
        p1.End_Date__c = testDate;
        update p1;  
        p2.End_Date__c = testDate;
        update p2;
        p3.End_Date__c = testDate;
        update p3;
        p4.End_Date__C = testDate;
        update p4;
        
        Office_position__c p5 = new Office_position__c (Member__c = m5.id, Position__c = 'Club Treasurer', Start_Date__c=Date.newInstance(2014, 4, 3), End_Date__c=Date.newInstance(2015,10,01), Club__c=c1.id);
		insert p5;
        Office_position__c p6 = new Office_position__c (Member__c = m6.id, Position__c = 'Club Treasurer', Start_Date__c=Date.newInstance(2014, 3, 30), End_Date__c=Date.newInstance(2015,10,01), Club__c=c2.id);
		insert p6;
       
        List<Club__c> checkClubs1 = new List<Club__c>([SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c1.Id]);	
        Club__c cc1 = checkClubs1[0];
        List<Club__c> checkClubs2 = new List<Club__c>([SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c2.Id]);	
        Club__c cc2 = checkClubs2[0];

		System.Debug('cc1: '+cc1);
		System.Debug('cc2: '+cc2);
 
 		mytest.RemoveOldPositions();
 
 		checkClubs1 = [SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c1.Id];	
        cc1 = checkClubs1[0];
        checkClubs2 = [SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c2.Id];	
        cc2 = checkClubs2[0];  
 
 		
        System.assertEquals(null,cc1.Club_Chair__c);
        System.assertEquals(m5.Id,cc1.Club_Treasurer__c);  
        
        mytest.AddNewPositions();

 		checkClubs1 = [SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c1.Id];	
        cc1 = checkClubs1[0];
        checkClubs2 = [SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c2.Id];	
        cc2 = checkClubs2[0];
        
        System.assertEquals(cc1.Club_Treasurer__c,m5.Id); 
        System.assertEquals(cc2.Club_Treasurer__c,m6.Id);
        
        p5.End_date__c = testdate;
        update p5;
        p6.End_date__c = testdate;
        update p6;
        
        mytest.RemoveOldPositions();
        
        checkClubs1 = [SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c1.Id];	
        cc1 = checkClubs1[0];
        checkClubs2 = [SELECT Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE Id = :c2.Id];	
        cc2 = checkClubs2[0];
        
        
        System.assertEquals(cc1.Club_Treasurer__c,null); 
        System.assertEquals(cc2.Club_Treasurer__c,null);
       
    }
}