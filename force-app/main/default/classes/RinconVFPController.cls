public without sharing class RinconVFPController {
    
    public Opportunity opportunity {get;set;}
    public String oppId {get;set;}
    public String auxStage {get;set;}
    public Decimal auxPercent {get;set;}
        
    public Date auxCloseDate {get;set;}
    
    public List<Opportunity> opps {get;set;}
    
    public ContentVersion contentfile {
        get{
            if (contentfile == null)
                contentfile = new ContentVersion();
            return contentfile;
        }
        set;
    }

    public SessionData varsession {get;set;}    
    public List<ContentDocumentLink> files {get; set;}
    public String baseUrl {get; set;}    
    public Map<Id, String> links {get; set;}
    
    

    String contactId = '', oppIdSF = '';
    public List<cStage> optionsStage{get;set;}
    
    public RinconVFPController(){
        System.debug('---------------------RINCON VFP CONTROLLER---------------------');
        varsession = new SessionData();
        varsession.forgotUOP = false;
        varsession.uploadMessage = null;
        varsession.sendRequestMessage = null;
        opportunity = new Opportunity();
        baseUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/';
        links = new Map<Id, String>();
        if(ApexPages.currentPage().getParameters().get('contactId')!=null){
            System.debug(ApexPages.currentPage().getParameters().get('contactId'));
            contactId = ApexPages.currentPage().getParameters().get('contactId');
            optionsStage = new List<cStage>();
            optionsStage.add(new cStage('PRE-APPROVAL', 'In this stage we will gather all of the information required for the Letter of Interest. Please see below for what is needed.', 20));
            optionsStage.add(new cStage('UNDER APPLICATION', 'The Letter of Interest has been signed and Good Faith Deposit Received. The lender pulls credit and orders the 3rd party reports.', 30));
            optionsStage.add(new cStage('MORTGAGE DOCS', 'Collection of documents required by lender to process the mortgage application.', 40));
            optionsStage.add(new cStage('INSPECTIONS', 'Lender required inspections such as appraisal and environment reports are completed.', 50));
            optionsStage.add(new cStage('UNDERWRITING', 'The file moves to underwriting once all applications/docs have been collected. Underwriter reviews credit report, borrower’s application and documentation, and third party reports and compares them with their program guidelines.', 70));
            optionsStage.add(new cStage('COMMITMENT LETTER', 'The loan has been formally approved. The lender draws loans documents and escrow prepares closing statements.', 85));
            optionsStage.add(new cStage('CLOSED', 'Loan has closed and recorded with the county recorder\'s office.', 100));
        	String objectName = 'Opportunity';
            /*String allFields = getAllFields(objectName);
    
            String query = 'SELECT '+ allFields + ', (Select Id From NotesAndAttachments) FROM '  + objectName + ' where Borrower_Contact__c=\'' + contactId +'\'';
    
            System.debug('----------'+query);   
    
        	List<Opportunity> opportunityList = Database.query(query);
            
            if(opportunityList.size()>0){
            	varsession.homePage = true;
            	varsession.showEmpty = false;
                varsession.loginPage = false;
                opportunity = opportunityList.get(0);
                auxStage = opportunity.StageName;
                auxPercent = opportunity.Probability;
                //opportunity.Signed_Letter_of_Intent__c = system.today();
                
                System.debug(opportunity.Projected_Closed_Date__c);
                auxCloseDate = opportunity.Projected_Closed_Date__c;
                System.debug(auxCloseDate);
                loadOppsRelated();                
                system.debug(opportunity.Where_are_we__c);
            }else{*/ //REMOVE 07/08/2020
                List<OpportunityContactRole> oppList = [select OpportunityId from OpportunityContactRole where contact.Id=: contactId and (Role='Broker' OR Role='Borrower' OR Role='Other')];
                if(oppList.size()>0)
                {
                    opps = new List<Opportunity>();
                    Opportunity auxOpp; 
                    for(OpportunityContactRole ocr: oppList){                        
                        auxOpp = [select Id, Name, Interest_Rate__c, StageName, Action_needed__c, Loan_Amount__c, Prepayment_expiration_date__c, Fixed_Period_Expiration__c FROM Opportunity WHERE Id=:ocr.OpportunityId].get(0);
                        opps.add(auxOpp);
					}
                    varsession.homePage = true;
                    varsession.showEmpty = false;
                    varsession.loginPage = false;
                    //opportunity.Signed_Letter_of_Intent__c = system.today();
                    
                }
                else{
                varsession.homePage = false;
                varsession.message = 'You have no related opportunities.';
            	varsession.showEmpty = true;
                varsession.loginPage = true;
                }
                
            //}REMOVE 07/08/2020
        }else{
            if(ApexPages.currentPage().getParameters().get('opportunitySF')!=null){
                System.debug(ApexPages.currentPage().getParameters().get('opportunitySF'));
                oppIdSF = ApexPages.currentPage().getParameters().get('opportunitySF');
                
                String objectName = 'Opportunity';
                String allFields = getAllFields(objectName);
        
                String query = 'SELECT '+ allFields + ', (Select Id From NotesAndAttachments) FROM '  + objectName + ' where Id=\'' + oppIdSF +'\'';
        
                System.debug('----------'+query);   
        
                List<Opportunity> opportunityList = Database.query(query);
                
                if(opportunityList.size()>0){
                    varsession.homePage = true;
                    varsession.showEmpty = false;
                    varsession.loginPage = false;
                    opportunity = opportunityList.get(0);
                    auxStage = opportunity.StageName;
                    //opportunity.Signed_Letter_of_Intent__c = system.today();
                    
                    System.debug(opportunity.Projected_Closed_Date__c);
                    auxCloseDate = opportunity.Projected_Closed_Date__c;
                    System.debug(auxCloseDate);
                    loadOppsRelated();
                    
                    loadFiles();
                    
                    system.debug(opportunity.Where_are_we__c);
                }else{
                    varsession.homePage = false;
                    varsession.message = 'Param invalid.';
                    varsession.showEmpty = true;
                    varsession.loginPage = true;
                }
            }else{
                varsession.homePage = false;
                varsession.showEmpty = false;
                varsession.forgotUOP = false;
         		varsession.loginPage = true;
            }
        }
        
        
    }
    
    public String getAllFields(String objectName){
        String allFields = '';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        Set<string> mapset = fieldMap.keyset(); 
        /*List<String> lstFields = new List<String>();*/
        for ( String str : mapset )
        {
        	allFields = allFields + str +', '; 
            //**lstFields.add(str);**
        }
        return allFields.removeEnd(', ');
    }
    
    public void loadOppsRelated(){
        opps = [select Id, Name, Interest_Rate__c, StageName, Action_needed__c, Loan_Amount__c, Prepayment_expiration_date__c, Fixed_Period_Expiration__c
                from Opportunity
                where Borrower_Contact__r.Id =: contactId];
       	List<OpportunityContactRole> oppContactRole = [select OpportunityId from OpportunityContactRole where ContactId=: contactId and (Role='Broker' OR Role='Borrower' OR Role='Other')];
        System.debug(contactId);
    }
    
    public void loadFiles(){
        files = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.title,
                 ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId, ContentDocument.CreatedDate
                 FROM ContentDocumentLink 
                 where LinkedEntityId=:opportunity.Id
                 order by ContentDocument.LastModifiedDate desc];
                 
        System.debug(files.size());
        for(ContentDocumentLink cdl : files){
            links.put(cdl.ContentDocumentId, '#');
        }
        
        List<ContentDistribution> urlPublics = [Select Id, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId in: links.keySet()];
        for(ContentDistribution aux : urlPublics){
            links.put(aux.ContentDocumentId, aux.DistributionPublicUrl);
        }
    }
    
    
    public PageReference changeStage(){
        System.debug('Hola');
        System.debug(opportunity.StageName);
        
        return null;
    }
    
    public PageReference save() {
		PageReference page =  ApexPages.currentPage();
        System.debug('Save');
        opportunity.Projected_Closed_Date__c = auxCloseDate;
        update opportunity;
        page.getParameters().put('contactId',null);
        page.setRedirect(true);
        return page;
	}
    
    public PageReference redirectOpp() {
        System.debug('username: ' + varsession.username);
        System.debug('password: ' + varsession.password);
        varsession.sendRequestMessage = null;
        if(String.isBlank(varsession.username) || String.isBlank(varsession.password)){
            varsession.loginfail = true;
            return null;
        }
        List<Contact> contact = [SELECT Id FROM Contact WHERE Username__c=:varsession.username];
        if(contact.size()==0)
        {
            varsession.loginfail = true;
            return null;
        }
        contactId = contact.get(0).Id;
        List<OpportunityContactRole> contacts = [select contact.Id, contact.Name from OpportunityContactRole where contact.Username__c=: varsession.username and contact.Password__c=: varsession.password and (Role='Broker' OR Role='Borrower'  OR Role='Other')];
        
        System.debug(contacts.size());
        if(contacts.size()>0){
            PageReference page =  ApexPages.currentPage();
            page.getParameters().put('contactId', contacts.get(0).contact.Id);
            page.setRedirect(true);
            return page;
        } else{
            varsession.loginfail = true;
            return null;
        }
	}
    
     public PageReference redirectForgotUOP() {
        varsession.sendRequestMessage = null;
        varsession.loginfail = false;
        System.debug('Forgot password');
        varsession.forgotUOP = true;
        varsession.loginPage = false;
        PageReference page =  ApexPages.currentPage();
        return page;
	}
    
    public PageReference logOut() {
        System.debug('LogOut');
        varsession.forgotUOP = false;
        varsession.loginPage = true;
        varsession.homePage = false;
        varsession.loanPage = false;
        varsession.uploadMessage = null;
        varsession.sendRequestMessage = null;
        PageReference page =  ApexPages.currentPage();
        return page;
	}
    
    public PageReference redirectLoanPage() {
        varsession.uploadMessage = null;
        String objectName = 'Opportunity';
        String allFields = getAllFields(objectName);
        
        String query = 'SELECT '+ allFields + ', (Select Id, CreatedDate From NotesAndAttachments) FROM '  + objectName + ' where Id=\'' + oppId +'\'';
        
        System.debug('----------'+query);   
        
        List<Opportunity> opportunityList = Database.query(query);
        
        opportunity = opportunityList.get(0);
        auxStage = opportunity.StageName;
        auxPercent = opportunity.Probability;
        auxCloseDate = opportunity.Projected_Closed_Date__c;
        System.debug(auxPercent);
        varsession.homePage = false;
        varsession.loanPage = true;
        loadFiles();
        PageReference page =  ApexPages.currentPage();        
        return page;
	}
    
    /*public PageReference doAttachment(){
        System.debug('Hiiiiiis' + fileName);
        ContentVersion conVer = new ContentVersion();
		conVer.PathOnClient = fileName;
		conVer.Title = fileName;
		conVer.VersionData = EncodingUtil.base64Decode(body);
		insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        System.debug(contactId);
        cDe.LinkedEntityId = contactId;
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = conVer.Id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        System.debug('Chau: ' + cDe.Id);
        sendEmail();
        //loadFiles();
        PageReference page =  ApexPages.currentPage();
        return page;
    }*/
    public PageReference upload() {
        try {
            contentfile.PathOnClient = contentfile.Title;
            insert contentfile;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentfile.Id].ContentDocumentId;
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            System.debug(contactId);
            cDe.LinkedEntityId = contactId;
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
            sendEmail();
            
        } catch (DMLException e) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading File'));
            varsession.uploadMessage = 'Error, Uploading File';
            return null;
        } finally {
            contentfile = new ContentVersion();
        }
        varsession.uploadMessage = 'Success, File uploaded';
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        return null;
    }
    
    public void sendEmail(){
        String body = '<p>Hey Tiffany,<br/>'+
            			'You have a new file upload for this Opportunity:<br/>' +
            			Url.getSalesforceBaseUrl().toExternalForm() +'/' + opportunity.Id +'<br/>' + 
            			'Thanks!</p>';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage mail = New Messaging.SingleEmailMessage();
    String[] toAddress =  new String[]{'tiffanie@rincon-group.com'};
		//String[] toAddress =  new String[]{'gleon@cloudcreations.com'};
		mail.setToAddresses(toAddress);
		mail.setSubject('New File upload in Community');
        //mail.setPlainTextBody(String.valueOf(response.getBody()).subStringBetween('<template id="100000067"','</template>'));
        mail.setHtmlBody(body);
        mails.add(mail);
		Messaging.sendEmail(mails);
    }
    
    public PageReference sendRecoveryEmail(){
        varsession.loginfail = false;
        String body = '<p>' + varsession.name + ' has forgotten his/her username or password please reach out to the client with the following details below:<br/>' + 
            varsession.email + '<br/>' + varsession.phone;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage mail = New Messaging.SingleEmailMessage();
		//String[] toAddress =  new String[]{'rurupeque@cloudcreations.com'};
        String[] toAddress =  new String[]{'tiffanie@rincon-group.com'};
		mail.setToAddresses(toAddress);
		mail.setSubject(varsession.name + ' forgot password');
        mail.setHtmlBody(body);
        mails.add(mail);
		Messaging.sendEmail(mails);
        varsession.sendRequestMessage = 'Thanks, Thank you for submitting your request.';
        varsession.loginPage = true;
        varsession.forgotUOP = false;
        return null;
    }
    
    public class cStage{
       public String key {get;set;}
       public String helpText {get; set;}
       public Decimal prob {get; set;}
        public cStage(String vkey, String vHelpText, Decimal vProb){
            key = vkey;
            helpText = vHelpText;
            prob = vProb;
        }
    }

    public class SessionData{
        public Boolean homePage {get; set;}
        public Boolean forgotUOP {get; set;}
        public Boolean loginPage {get; set;}
        public Boolean loanPage {get; set;}
        public Boolean showEmpty {get; set;}
        public String username {get; set;}
        public String name {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public String password {get; set;}
        public Boolean loginfail {get; set;}
        public String message {get;set;}
        public String uploadMessage {get; set;}
        public String sendRequestMessage {get; set;}
    }

    
}