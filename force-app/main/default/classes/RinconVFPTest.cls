@isTest
public class RinconVFPTest {
    @TestSetup
    static void makeData(){
        Account acc =  new Account(Name='TestAccount');
        insert acc;
        Contact cont = new Contact(LastName='Test',FirstName='Test',Username__c='test',Password__c='test');
        insert cont;
        Contact cont2 = new Contact(LastName='Test2',FirstName='Test',Username__c='test2',Password__c='test2');
        insert cont2;
        Opportunity opp = new Opportunity(Name='TestAsd', StageName='APPLICATION',AccountId=acc.Id,CloseDate=Date.today());
        insert opp;
        OpportunityContactRole cr = new OpportunityContactRole (OpportunityId=opp.Id,ContactId=cont.Id,Role='Broker');
        insert cr;

        ContentVersion contentfile = new ContentVersion();
        contentfile.Title = 'test2';
        contentfile.PathOnClient = contentfile.Title;
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        contentfile.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert contentfile;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentfile.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = opp.Id;
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        ContentDistribution cd = new ContentDistribution();
        cd.Name = contentfile.Title;
        cd.ContentVersionId = contentfile.Id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
    }
    @isTest
    public static void testVFPLogin(){
        Contact cont = [SELECT Id,Username__c,Password__c FROM Contact WHERE LastName =  'Test'];    
        PageReference page = Page.RinconVFP;
        page.getParameters().put('contactId', cont.Id);
        Test.setCurrentPage(page);
        RinconVFPController vfp = new RinconVFPController();
        vfp.varsession.username = cont.Username__c;
        vfp.varsession.password = cont.Password__c;
        vfp.redirectOpp();
    }
    @isTest
    public static void testVFPLoginFail(){
        Contact cont = [SELECT Id,Username__c,Password__c FROM Contact WHERE LastName = 'Test2'];    
        PageReference page = Page.RinconVFP;
        page.getParameters().put('contactId', cont.Id);
        Test.setCurrentPage(page);
        RinconVFPController vfp = new RinconVFPController();
        vfp.varsession.username = cont.Username__c;
        vfp.varsession.password = cont.Password__c;
        vfp.redirectOpp();
    }

    @isTest
    public static void testVFPLoginFail2(){
        RinconVFPController vfp = new RinconVFPController();
        vfp.varsession.username = 'fail';
        vfp.varsession.password = 'fail';
        vfp.redirectOpp();
    }

    
    @isTest
    public static void testVFPLoadOpp(){
        Contact cont = [SELECT Id,Username__c,Password__c FROM Contact WHERE LastName =  'Test'];
        Opportunity Opp = [SELECT Id FROM Opportunity Limit 1];
        PageReference page = Page.RinconVFP;
        page.getParameters().put('contactId', cont.Id);
        page.getParameters().put('opportunitySF', Opp.Id);
        Test.setCurrentPage(page);
        RinconVFPController vfp = new RinconVFPController();
        vfp.varsession.username = cont.Username__c;
        vfp.varsession.password = cont.Password__c;
        vfp.oppId = Opp.Id;
        vfp.redirectLoanPage();
    }

    
    @isTest
    public static void testVFPLogOut(){
        RinconVFPController vfp = new RinconVFPController();
        vfp.logOut();
    }

    @isTest
    public static void testVFPUploadFile(){
        Contact cont = [SELECT Id,Username__c,Password__c FROM Contact WHERE LastName =  'Test'];
        Opportunity Opp = [SELECT Id FROM Opportunity Limit 1];
        PageReference page = Page.RinconVFP;
        page.getParameters().put('contactId', cont.Id);
        page.getParameters().put('opportunitySF', Opp.Id);
        Test.setCurrentPage(page);
        RinconVFPController vfp = new RinconVFPController();
        vfp.varsession.username = cont.Username__c;
        vfp.varsession.password = cont.Password__c;
        vfp.oppId = Opp.Id;
        vfp.contentfile.Title ='Test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        vfp.contentfile.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        vfp.upload();

        vfp.contentfile.Title ='Test';
        vfp.contentfile.VersionData = null;
        vfp.upload();
    }

    @isTest
    public static void testVFPDirecOpp(){
        Opportunity Opp = [SELECT Id FROM Opportunity Limit 1];
        PageReference page = Page.RinconVFP;
        page.getParameters().put('opportunitySF', Opp.Id);
        Test.setCurrentPage(page);
        RinconVFPController vfp = new RinconVFPController();

        page.getParameters().put('opportunitySF', '');
        Test.setCurrentPage(page);
        vfp = new RinconVFPController();
    }
    @isTest
    public static void testVFPRecovery(){
        RinconVFPController vfp = new RinconVFPController();
        vfp.redirectForgotUOP();
        vfp.varsession.name = 'test';
        vfp.varsession.email = 'test@test.com';
        vfp.varsession.phone = '123456789';
        vfp.sendRecoveryEmail();
    }

    @isTest
    public static void testVFPStage(){
        Opportunity Opp = [SELECT Id FROM Opportunity Limit 1];
        PageReference page = Page.RinconVFP;
        page.getParameters().put('opportunitySF', Opp.Id);
        Test.setCurrentPage(page);
        RinconVFPController vfp = new RinconVFPController();
        vfp.changeStage();
        vfp.save();
    }
}