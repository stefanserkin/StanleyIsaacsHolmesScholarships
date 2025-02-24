global class TRecPrepareSandbox implements SandboxPostCopy {

    private static Id membershipTypeStandardRecTypeId = Schema.SObjectType.TREX1__Membership_Type__c.getRecordTypeInfosByDeveloperName().get('Standard_Membership_Type').getRecordTypeId();

    private Date sessionStart;
    private Date sessionEnd;
    private TREX1__Global_Billing_Group__c gbg;
    private List<TREX1__GL_Account__c> glAccounts;
    private TREX1__Product__c freeProduct;
    private TREX1__Location__c location;
    private TREX1__Facility__c facility;
    private TREX1__Membership_Type__c fitnessMemType;
    private TREX1__Membership_Type__c programMemType;

    global TRecPrepareSandbox() {}

    global void createStuff() {
        runApexClass(null);
    }

    global void runApexClass(SandboxContext context) {
        this.sessionStart = Date.today().addDays(-30);
        this.sessionEnd = Date.today().addDays(60);
        createGlobalBillingGroup();
        createPaymentProcessorsAndTenderTypes();
        createRevenueGLAccounts();
        createFreeProduct();
        createLocationsAndFacilities();
        createMembershipConfiguration();
        createProgramLibrary();
        createAccountsAndContacts();
    }

    private void createGlobalBillingGroup() {
        gbg = new TREX1__Global_Billing_Group__c();
        gbg.Name = 'Asphalt Green';
        gbg.TREX1__Public_Name__c = 'Asphalt Green';
        gbg.TREX1__Monthly_Billing_Day__c = 1;
        gbg.TREX1__Community_Bill_To_Account__c = 'Disabled';
        gbg.TREX1__Surcharge_Configuration__c = 'Disabled';
        gbg.TREX1__Summarize_OTBS_On_Payment__c = false;
        gbg.TREX1__Locked_By_Billing_Batch__c = false;
        Database.insert(gbg, AccessLevel.SYSTEM_MODE);
    }

    private void createPaymentProcessorsAndTenderTypes() {
        List<tpay__Processor_Profile__c> profiles = new List<tpay__Processor_Profile__c>();

        tpay__Processor_Profile__c vantivProfile = new tpay__Processor_Profile__c();
        vantivProfile.Name = 'Vantiv IP Settings';
        vantivProfile.tpay__Active__c = true;
        vantivProfile.tpay__TenderEntryMethod__c = 'Present Options';
        vantivProfile.tpay__VIP_AcceptorID__c = '3928907';
        vantivProfile.tpay__VIP_AccountID__c = '1012840';
        vantivProfile.tpay__VIP_AccountToken__c = 'E025C80579D6CD4CF45EB7561CD7CA451FC828DE59C1E683DCE23FEC62DBFCB681713401';
        vantivProfile.tpay__VIP_Merchant_Id_Long_List__c = '4445048883391';
        vantivProfile.tpay__Capture_AVS__c = 'ZIP Optional';
        vantivProfile.tpay__Capture_CVV__c = 'Optional';
        profiles.add(vantivProfile);

        tpay__Processor_Profile__c nonIntegratedProcessor = new tpay__Processor_Profile__c();
        nonIntegratedProcessor.Name = 'Non-Integrated Processor';
        nonIntegratedProcessor.tpay__Active__c = true;
        nonIntegratedProcessor.tpay__TenderEntryMethod__c = 'Onscreen Only';
        profiles.add(nonIntegratedProcessor);

        Database.insert(profiles, AccessLevel.SYSTEM_MODE);

        List<tpay__Tender_Type__c> tenderTypes = new List<tpay__Tender_Type__c>();
        tpay__Tender_Type__c ttCash = new tpay__Tender_Type__c(
            tpay__Tender_Name__c = 'Cash',
            tpay__CardType__c = 'Non-Integrated',
            tpay__Tender_Label__c = 'Cash',
            Non_Integrated_Type__c = 'Cash',
            tpay__Processor_Profile__c = nonIntegratedProcessor.Id,
            tpay__Active__c = true,
            tpay__Allow_Automated_Billing__c = false
        );
        tenderTypes.add(ttCash);

        tpay__Tender_Type__c ttCreditCard = new tpay__Tender_Type__c(
            tpay__Tender_Name__c = 'Credit Card',
            tpay__CardType__c = 'Credit',
            tpay__Tender_Label__c = 'Credit Card',
            tpay__Card_Scheme__c = 'VISA',
            tpay__Processor_Profile__c = vantivProfile.Id,
            tpay__Active__c = true,
            tpay__Allow_Automated_Billing__c = true,
            tpay__Allow_Edit_On_Community__c = true,
            tpay__Available_For_Stored_Account__c = true
        );
        tenderTypes.add(ttCreditCard);

        Database.insert(tenderTypes, AccessLevel.SYSTEM_MODE);

        List<GBG_Allowed_Tender_Type__c> allowedGBGs = new List<GBG_Allowed_Tender_Type__c>();
        for (tpay__Tender_Type__c tt : tenderTypes) {
            GBG_Allowed_Tender_Type__c agbgFrontDesk = new GBG_Allowed_Tender_Type__c(
                Global_Billing_Group__c = this.gbg.Id,
                Tender_Type__c = tt.Id,
                Front_Desk_Immediate__c = true,
                Front_Desk_Recurring__c = tt.tpay__Processor_Profile__c == vantivProfile.Id,
                Online_Immediate__c = false,
                Online_Recurring__c = false
            );
            allowedGBGs.add(agbgFrontDesk);

            if (tt.tpay__Processor_Profile__c == vantivProfile.Id) {
                GBG_Allowed_Tender_Type__c agbgCommunity = new GBG_Allowed_Tender_Type__c(
                    Global_Billing_Group__c = this.gbg.Id,
                    Tender_Type__c = tt.Id,
                    Front_Desk_Immediate__c = false,
                    Front_Desk_Recurring__c = false,
                    Online_Immediate__c = true,
                    Online_Recurring__c = true
                );
                allowedGBGs.add(agbgCommunity);
            }
        }
        Database.insert(allowedGBGs, AccessLevel.SYSTEM_MODE);
    }

    private void createRevenueGLAccounts() {
        this.glAccounts = new List<TREX1__GL_Account__c>();
        String baseGl = '10-44-123-1000';
        for (Integer i = 0; i < 2; i++) {
            this.glAccounts.add(
                new TREX1__GL_Account__c(
                    Name = 'Revenue Account ' + String.valueOf(i),
                    TREX1__Active__c = true,
                    TREX1__GL_Account_Number__c = baseGl + String.valueOf(i),
                    TREX1__Type__c = 'Income'
                )
            );
        }
        Database.insert(this.glAccounts, AccessLevel.SYSTEM_MODE);
    }

    private void createFreeProduct() {
        this.freeProduct = new TREX1__Product__c();
        this.freeProduct.Name = 'Free Product';
        this.freeProduct.TREX1__Billing_Cancellation_Credit_Setting__c = 'Active Days Prorated Credit';
        this.freeProduct.TREX1__Allow_Multiple__c = true;
        this.freeProduct.TREX1__Available_Externally__c = true;
        this.freeProduct.TREX1__Global_Billing_Group__c = this.gbg.Id;
        Database.insert(this.freeProduct, AccessLevel.SYSTEM_MODE);
    }

    private void createLocationsAndFacilities() {
        this.location = new TREX1__Location__c(
            Name = 'Upper East Side',
            TREX1__Available_for_Location_Filter_Front_Desk__c = true,
            TREX1__Available_for_Location_Filter_Community__c = true
        );
        Database.insert(this.location, AccessLevel.SYSTEM_MODE);

        this.facility = new TREX1__Facility__c(
            TREX1__Location__c = this.location.Id,
            TREX1__Max_Capacity__c = 100,
            TREX1__Type__c = 'Gym'
        );
        Database.insert(this.facility, AccessLevel.SYSTEM_MODE);
    }

    private void createMembershipConfiguration() {
        List<TREX1__Membership_Category__c> memCats = new List<TREX1__Membership_Category__c>();
        TREX1__Membership_Category__c fitnessMemCat = new TREX1__Membership_Category__c(
            Name = 'Fitness Memberships',
            TREX1__Available_For_Purchase__c = true,
            TREX1__Available_Online__c = true
        );
        memCats.add(fitnessMemCat);

        TREX1__Membership_Category__c programMemCat = new TREX1__Membership_Category__c(
            Name = 'Program Participation',
            TREX1__Available_For_Purchase__c = true,
            TREX1__Available_Online__c = false
        );
        memCats.add(programMemCat);
        Database.insert(memCats, AccessLevel.SYSTEM_MODE);

        List<TREX1__Membership_Type__c> memTypes = new List<TREX1__Membership_Type__c>();
        this.fitnessMemType = new TREX1__Membership_Type__c(
            Name = 'Individual Membership',
            RecordTypeId = membershipTypeStandardRecTypeId,
            TREX1__Available_For_Purchase__c = true, 
            TREX1__Available_Online__c = true, 
            TREX1__Can_Freeze__c = true, 
            TREX1__Cancellation_Policy__c = 'N Days Notice', 
            TREX1__Category__c = fitnessMemCat.Id, 
            TREX1__End_Date_Setting__c = 'Perpetual', 
            TREX1__Location__c = location.Id, 
            TREX1__Term_Type__c = 'Monthly'
        );
        memTypes.add(this.fitnessMemType);

        this.programMemType = new TREX1__Membership_Type__c(
            Name = 'Program Participation - Upper East Side',
            RecordTypeId = membershipTypeStandardRecTypeId,
            TREX1__Available_For_Purchase__c = true, 
            TREX1__Available_Online__c = true, 
            TREX1__Can_Freeze__c = true, 
            TREX1__Cancellation_Policy__c = 'N Days Notice', 
            TREX1__Category__c = programMemCat.Id, 
            TREX1__End_Date_Setting__c = 'Fixed Term', 
            TREX1__Fixed_Term_Start_Date__c = sessionStart,
            TREX1__Term_Length__c = 3,
            TREX1__Term_Type__c = 'Monthly',
            TREX1__Location__c = location.Id
        );
        memTypes.add(this.programMemType);
        Database.insert(memTypes, AccessLevel.SYSTEM_MODE);
    }

    private void createProgramLibrary() {
        TREX1__Program_Category__c pCat = new TREX1__Program_Category__c(Name = 'Dogs');
        Database.insert(pCat, AccessLevel.SYSTEM_MODE);

        TREX1__Program__c program = new TREX1__Program__c(
            Name = 'Dog Training',
            TREX1__Available__c = true,
            TREX1__Available_Online__c = true
        );
        Database.insert(program, AccessLevel.SYSTEM_MODE);

        TREX1__Program_Category_Tag__c tag = new TREX1__Program_Category_Tag__c(
            TREX1__Program_Category__c = pCat.Id, 
            TREX1__Program__c = program.Id
        );
        Database.insert(tag, AccessLevel.SYSTEM_MODE);

        TREX1__Course__c course = new TREX1__Course__c(
            Name = 'Soggy Doggies',
            TREX1__Available__c = true, 
            TREX1__Available_Online__c = true, 
            TREX1__Program__c = program.Id
        );
        Database.insert(course, AccessLevel.SYSTEM_MODE);

        TREX1__Session__c session = new TREX1__Session__c(
            Name = sessionStart.format() + ' - ' + sessionEnd.format(),
            TREX1__Available__c = true,
            TREX1__Available_Online__c = true,
            TREX1__Available_Online_From__c = sessionStart,
            TREX1__Available_Online_To__c = sessionEnd,
            TREX1__Register_From_Date__c = sessionStart,
            TREX1__Register_To_Date__c = sessionEnd,
            TREX1__Register_Online_From_Date__c = sessionStart,
            TREX1__Register_Online_To_Date__c = sessionEnd,
            TREX1__Start_Date__c = sessionStart,
            TREX1__End_Date__c = sessionEnd,
            TREX1__Status__c = 'Available',
            UES_Free_Membership_Type__c = this.programMemType.Id,
            UES_Admin_GL_Account__c = glAccounts[0].Id,
            UES_Other_Fees_GL_Account__c = glAccounts[1].Id,
            Free_Product__c = freeProduct.Id
        );
        Database.insert(session, AccessLevel.SYSTEM_MODE);

        Staged_Program_Batch__c spb = new Staged_Program_Batch__c(
            Session__c = session.Id,
            Description__c = 'Prepare Sandbox Batch'
        );
        Database.insert(spb, AccessLevel.SYSTEM_MODE);

        List<Staged_Program__c> stagedPrograms = new List<Staged_Program__c>();

        List<String> daysOfWeek = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'};
        Integer dayOfWeekCounter = 0;
        for (Integer i = 1; i < 4; i++) {
            for (Integer j = 0; j < 3; j++) {
                Staged_Program__c stagedProgram = new Staged_Program__c(
                    Staged_Program_Batch__c = spb.Id,
                    Status__c = 'Staged',
                    Program__c = program.Id,
                    Course__c = course.Id,
                    Session__c = session.Id,
                    GL_Account__c = this.glAccounts[0].Id,
                    Location__c = this.facility.TREX1__Location__c,
                    Primary_Facility__c = this.facility.Id,
                    Course_Session_Name__c = 'Soggy Doggies Level ' + String.valueOf(i),
                    Course_Option_Name__c = 'Soggy Doggies Level ' + String.valueOf(i) + ' - ' + daysOfWeek[dayOfWeekCounter],
                    Start_Date__c = this.sessionStart,
                    End_Date__c = this.sessionEnd,
                    Start_Time__c = '08:00 AM',
                    End_Time__c = '10:00 AM',
                    Course_Option_Code__c = 'abc.def.ghijk' + String.valueOf(i),
                    Days_of_Week__c = daysOfWeek[dayOfWeekCounter],
                    Minimum_Age__c = 8.0,
                    Maximum_Age__c = 12.0,
                    Capacity__c = 20,
                    Minimum_Participants__c = 1,
                    Public_Price__c = 400.00,
                    Has_Member_Price__c = true,
                    Available_Online__c = true
                );
                stagedPrograms.add(stagedProgram);

                dayOfWeekCounter = dayOfWeekCounter >= 6 ? 0 : dayOfWeekCounter + 1;
            }
        }
        Database.insert(stagedPrograms, AccessLevel.SYSTEM_MODE);

        ProgramGeneratorBatch pgb = new ProgramGeneratorBatch(spb.Id);
        Id jobId = Database.executeBatch(pgb, 50);
    }

    private void createAccountsAndContacts() {
        Account account = new Account(Name = 'Beethoven Family Household');
        Database.insert(account, AccessLevel.SYSTEM_MODE);

        List<Contact> contacts = new List<Contact>();
        contacts.add(
            new Contact(
                AccountId = account.Id,
                FirstName = 'Beethoven',
                LastName = 'Dogg',
                Birthdate = Date.newInstance(1970, 4, 10),
                Email = 'sheckytheshark+beethoven@gmail.com',
                Phone = '(917) 123-4567'
            )
        );

        contacts.add(
            new Contact(
                AccountId = account.Id,
                FirstName = 'Lassie',
                LastName = 'Dogg',
                Birthdate = Date.newInstance(1970, 8, 14),
                Email = 'sheckytheshark+lassie@gmail.com',
                Phone = '(917) 123-4568'
            )
        );

        contacts.add(
            new Contact(
                AccountId = account.Id,
                FirstName = 'Balto',
                LastName = 'Dogg',
                Birthdate = Date.newInstance(2012, 8, 2),
                Email = 'sheckytheshark+balto@gmail.com'
            )
        );

        Database.insert(contacts, AccessLevel.SYSTEM_MODE);
    }


}