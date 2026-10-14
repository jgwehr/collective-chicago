/**
 * Data silo + Apex tests for SROI_After_Create_Update_Calculate_SROI_Metrics.
 * Isolated key in Flow Test Mode: Contact.Email
 *
 * Trigger: insert SROI_Calculation__c (after save, sroiTotal__c IsChanged = false).
 */
@IsTest
global class test_SROI_After_Create_Update_SROI {
    public static final String EMAIL_NO_SUBSTANCE = 'silo.sroi.no-substance@example.test';
    public static final String EMAIL_NO_CRIMINAL = 'silo.sroi.no-criminal@example.test';
    public static final String EMAIL_SNAP_NULL = 'silo.sroi.snap-null@example.test';
    public static final String EMAIL_SNAP_ZERO = 'silo.sroi.snap-zero@example.test';

    public static final Date MOVE_IN_DATE = Date.newInstance(2025, 1, 1);
    public static final Date GRAD_DATE = Date.newInstance(2026, 10, 12);

    public static final Decimal INTAKE_INCOME = 800;
    public static final Decimal GRAD_INCOME = 5500;
    public static final Decimal UNEMPLOYMENT_AMOUNT = 120;
    public static final Decimal SNAP_POSITIVE = 250;

    @TestSetup
    global static void seedSilo() {
        Id stakeholderRtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Stakeholder')
            .getRecordTypeId();

        List<Contact> contacts = new List<Contact>{
            graduate(EMAIL_NO_SUBSTANCE, 'NoSubstance'),
            graduate(EMAIL_NO_CRIMINAL, 'NoCriminal'),
            graduate(EMAIL_SNAP_NULL, 'SnapNull'),
            graduate(EMAIL_SNAP_ZERO, 'SnapZero')
        };
        for (Contact c : contacts) {
            c.RecordTypeId = stakeholderRtId;
        }
        insert contacts;
    }

    @IsTest
    global static void substanceAbuseFalse_setsSroiSubstanceAbuseToZero() {
        SROI_Calculation__c row = calculate(
            EMAIL_NO_SUBSTANCE,
            false, // intakeDrugAlcoholAbuse__c
            true,  // applicationCriminalRecord__c
            SNAP_POSITIVE
        );
        System.assertEquals(false, row.intakeDrugAlcoholAbuse__c);
        System.assertEquals(0, row.sroiSubstanceAbuse__c);
    }

    @IsTest
    global static void criminalRecordFalse_setsSroiRecidivismToZero() {
        SROI_Calculation__c row = calculate(
            EMAIL_NO_CRIMINAL,
            true,
            false,
            SNAP_POSITIVE
        );
        System.assertEquals(false, row.applicationCriminalRecord__c);
        System.assertEquals(0, row.sroiRecidivism__c);
    }

    @IsTest
    global static void snapAmountNull_setsSroiSnapLinkToZero() {
        SROI_Calculation__c row = calculate(
            EMAIL_SNAP_NULL,
            true,
            true,
            null
        );
        System.assertEquals(null, row.budgetSnapLinkAmount__c);
        System.assertEquals(0, row.sroiSnapLink__c);
    }

    @IsTest
    global static void snapAmountZero_setsSroiSnapLinkToZero() {
        SROI_Calculation__c row = calculate(
            EMAIL_SNAP_ZERO,
            true,
            true,
            0
        );
        System.assertEquals(0, row.budgetSnapLinkAmount__c);
        System.assertEquals(0, row.sroiSnapLink__c);
    }

    static Contact graduate(String email, String lastName) {
        return new Contact(
            LastName = lastName,
            Email = email,
            npe01__Preferred_Email__c = 'Personal',
            npe01__HomeEmail__c = email,
            Stakeholder_Status__c = 'Graduated',
            residentGraduationDate__c = GRAD_DATE,
            residentMoveInDate__c = MOVE_IN_DATE
        );
    }

    static SROI_Calculation__c calculate(
        String email,
        Boolean substanceAbuse,
        Boolean criminalRecord,
        Decimal snapAmount
    ) {
        Contact c = [SELECT Id FROM Contact WHERE Email = :email];

        Test.startTest();
        insert new SROI_Calculation__c(
            graduate__c = c.Id,
            residentGraduationDate__c = GRAD_DATE,
            residentMoveInDate__c = MOVE_IN_DATE,
            intakeDrugAlcoholAbuse__c = substanceAbuse,
            applicationCriminalRecord__c = criminalRecord,
            budgetSnapLinkAmount__c = snapAmount,
            budgetUnemploymentAmount__c = UNEMPLOYMENT_AMOUNT,
            intakePostTaxIncome__c = INTAKE_INCOME,
            graduatePostTaxIncome__c = GRAD_INCOME
        );
        Test.stopTest();

        return [
            SELECT
                intakeDrugAlcoholAbuse__c,
                applicationCriminalRecord__c,
                budgetSnapLinkAmount__c,
                sroiSubstanceAbuse__c,
                sroiRecidivism__c,
                sroiSnapLink__c
            FROM SROI_Calculation__c
            WHERE graduate__c = :c.Id
        ];
    }
}