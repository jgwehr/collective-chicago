/**
 * Data silo for SROI_Create_Baseline_SROI_Metrics (no inputs).
 *
 * Isolated key in Flow Test Mode: Contact.Email
 *
 * Matching: Stakeholder_Status__c = 'Graduated' (sorted by residentGraduationDate__c ASC)
 * Negative: any other status; same field payload is passed through unused
 */
@IsTest
global class test_SROI_CreateBaseline_DataSilo {
    public static final String EMAIL_G01_ALL_TRUE = 'silo.g01.alltrue@example.test';
    public static final String EMAIL_G02_ALL_FALSE = 'silo.g02.allfalse@example.test';
    public static final String EMAIL_G03_REARREST = 'silo.g03.rearrest@example.test';
    public static final String EMAIL_NEG_RESIDENT = 'silo.neg.resident@example.test';
    public static final String EMAIL_NEG_APPLIED = 'silo.neg.applied@example.test';

    // Date fields are Salesforce Date (not DateTime)
    public static final Date GRAD_DATE_EARLIEST = Date.newInstance(2025, 6, 1);
    public static final Date GRAD_DATE_SAMPLE = Date.newInstance(2026, 10, 12);
    public static final Date GRAD_DATE_LATEST = Date.newInstance(2027, 1, 15);
    public static final Date MOVE_IN_DATE = Date.newInstance(2025, 1, 1);
    public static final Date REARREST_DATE = Date.newInstance(2026, 3, 15);

    public static final Decimal INTAKE_INCOME = 800;
    public static final Decimal GRAD_INCOME = 5500;
    public static final Decimal SNAP_AMOUNT = 250;
    public static final Decimal UNEMPLOYMENT_AMOUNT = 120;

    @TestSetup
    global static void seedSilo() {
        Id stakeholderRtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Stakeholder')
            .getRecordTypeId();

        // Matching graduates: boolean / date toggles. Sort key = residentGraduationDate__c ASC
        Contact g01 = graduate(
            EMAIL_G01_ALL_TRUE,
            'G01AllTrue',
            'Graduated',
            true,
            true,
            true,
            GRAD_DATE_EARLIEST,
            null,              // graduateFirstRearrestDate__c
            MOVE_IN_DATE
        );
        Contact g02 = graduate(
            EMAIL_G02_ALL_FALSE,
            'G02AllFalse',
            'Graduated',
            false,
            false,
            false,
            GRAD_DATE_SAMPLE,  // 2026-10-12
            null,
            MOVE_IN_DATE
        );
        Contact g03 = graduate(
            EMAIL_G03_REARREST,
            'G03Rearrest',
            'Graduated',
            true,
            false,
            true,
            GRAD_DATE_LATEST,
            REARREST_DATE,     // 2026-03-15
            MOVE_IN_DATE
        );

        // Negatives: identical payload to g02, only Stakeholder_Status__c differs
        Contact negResident = graduate(
            EMAIL_NEG_RESIDENT,
            'NegResident',
            'Resident',
            false,
            false,
            false,
            GRAD_DATE_SAMPLE,
            null,
            MOVE_IN_DATE
        );
        Contact negApplied = graduate(
            EMAIL_NEG_APPLIED,
            'NegApplied',
            'Applied',
            false,
            false,
            false,
            GRAD_DATE_SAMPLE,
            null,
            MOVE_IN_DATE
        );

        List<Contact> contacts = new List<Contact>{
            g01, g02, g03, negResident, negApplied
        };
        for (Contact c : contacts) {
            c.RecordTypeId = stakeholderRtId;
        }
        insert contacts;
    }

    /*
    TESTS
    */

    @IsTest
    global static void createsCalculationsForGraduatesOnly() {
        User runningUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        // Assume the running user has permissions to assign permissions (but not necessarily to edit SROI)
        System.runAs(runningUser) {
            assignGenerateSroi(runningUser.Id);
        }
        

        Test.startTest();
        System.runAs(runningUser) {
            new Flow.Interview.SROI_Create_Baseline_SROI_Metrics(new Map<String, Object>()).start();
        }
        Test.stopTest();

        List<SROI_Calculation__c> created = [
            SELECT
                graduate__r.Email,
                applicationCriminalRecord__c,
                intakeDrugAlcoholAbuse__c,
                healthBenefits__c,
                graduateFirstRearrestDate__c,
                residentGraduationDate__c,
                intakePostTaxIncome__c,
                graduatePostTaxIncome__c,
                budgetSnapLinkAmount__c,
                budgetUnemploymentAmount__c
            FROM SROI_Calculation__c
            ORDER BY residentGraduationDate__c ASC
        ];
        System.assertEquals(3, created.size(), 'Only Graduated Contacts should create SROI rows');
        System.assertEquals(EMAIL_G01_ALL_TRUE, created[0].graduate__r.Email);
        System.assertEquals(EMAIL_G02_ALL_FALSE, created[1].graduate__r.Email);
        System.assertEquals(EMAIL_G03_REARREST, created[2].graduate__r.Email);
        assertPassThrough(
            created[0],
            true,
            true,
            true,
            null,
            GRAD_DATE_EARLIEST
        );
        assertPassThrough(
            created[1],
            false,
            false,
            false,
            null,
            GRAD_DATE_SAMPLE
        );
        assertPassThrough(
            created[2],
            true,
            false,
            true,
            REARREST_DATE,
            GRAD_DATE_LATEST
        );
    }


    /*
    HELPER
    */

    static Contact graduate(
        String email,
        String lastName,
        String status,
        Boolean criminalRecord,
        Boolean substanceAbuse,
        Boolean healthBenefits,
        Date graduationDate,
        Date firstRearrestDate,
        Date moveInDate
    ) {
        return new Contact(
            LastName = lastName,
            Email = email,
            npe01__Preferred_Email__c = 'Personal',
            npe01__HomeEmail__c = email,
            Stakeholder_Status__c = status,
            applicationCriminalRecord__c = criminalRecord,
            intakeDrugAlcoholAbuse__c = substanceAbuse,
            graduateHealthBenefits__c = healthBenefits,
            graduateFirstRearrestDate__c = firstRearrestDate,
            residentGraduationDate__c = graduationDate,
            residentMoveInDate__c = moveInDate,
            intakePostTaxIncome__c = INTAKE_INCOME,
            graduatePostTaxIncome__c = GRAD_INCOME,
            budgetSnapLinkAmount__c = SNAP_AMOUNT,
            budgetUnemploymentAmount__c = UNEMPLOYMENT_AMOUNT
        );
    }

    static void assignGenerateSroi(Id userId) {
        //Do not put PermissionSetAssignment in @TestSetup if you can avoid it: Flow Builder may treat that object as part of the silo. Prefer the first pattern (PSA only in the Apex test method). For Flow Test Mode, grant SROI_Manage_Calculations to the user who clicks Run so the silo never has to assign it.
        
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'SROI_Manage_Calculations'
            LIMIT 1
        ];
        upsert new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = ps.Id
        );
    }


    
    /*
    ASSERTIONS
    */

    static void assertPassThrough(
        SROI_Calculation__c row,
        Boolean criminalRecord,
        Boolean substanceAbuse,
        Boolean healthBenefits,
        Date firstRearrestDate,
        Date graduationDate
    ) {
        System.assertEquals(criminalRecord, row.applicationCriminalRecord__c);
        System.assertEquals(substanceAbuse, row.intakeDrugAlcoholAbuse__c);
        System.assertEquals(healthBenefits, row.healthBenefits__c);
        System.assertEquals(firstRearrestDate, row.graduateFirstRearrestDate__c);
        System.assertEquals(graduationDate, row.residentGraduationDate__c);
        System.assertEquals(INTAKE_INCOME, row.intakePostTaxIncome__c);
        System.assertEquals(GRAD_INCOME, row.graduatePostTaxIncome__c);
        System.assertEquals(SNAP_AMOUNT, row.budgetSnapLinkAmount__c);
        System.assertEquals(UNEMPLOYMENT_AMOUNT, row.budgetUnemploymentAmount__c);
    }


}