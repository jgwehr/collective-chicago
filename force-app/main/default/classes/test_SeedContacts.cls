/**
 * test_SeedContacts
 *
 * Verifies that SeedContacts inserts the correct number of Contact records
 * per Stakeholder Status, and that the idempotency guard prevents duplicates
 * on a second run.
 */
@IsTest
global class test_SeedContacts {

    /*
    TESTS
    */

    /**
     * Verifies that running SeedContacts once produces exactly 80 Contact
     * records — 10 for each of the 8 Stakeholder Status values.
     */
    @IsTest
    static void singleRun_creates80Contacts() {
        Test.startTest();
        SeedContacts seed = new SeedContacts();
        seed.runApexClass(null);
        Test.stopTest();

        System.assertEquals(
            80,
            [SELECT COUNT() FROM Contact WHERE Email LIKE 'seed.contact.%@example.test'],
            'Expected 80 seed contacts (10 per status) after a single run'
        );
    }

    /**
     * Verifies that each of the 8 Stakeholder Status values has exactly
     * 10 seed contacts after a single run.
     */
    @IsTest
    static void singleRun_creates10ContactsPerStatus() {
        Test.startTest();
        SeedContacts seed = new SeedContacts();
        seed.runApexClass(null);
        Test.stopTest();

        List<String> statuses = new List<String>{
            'Applied',
            'Interview 1', 'Interview 2', 'Interview 3',
            'Denied', 'Resident', 'Drop Out', 'Graduated'
        };

        for (String status : statuses) {
            Integer count = [
                SELECT COUNT()
                FROM Contact
                WHERE Email LIKE 'seed.contact.%@example.test'
                AND   Stakeholder_Status__c = :status
            ];
            System.assertEquals(
                10,
                count,
                'Expected 10 seed contacts with status "' + status + '"'
            );
        }
    }

    /**
     * Verifies that every Denied contact has a non-null Denied_Reason__c value,
     * and that all other contacts have a null Denied_Reason__c.
     */
    @IsTest
    static void deniedContacts_haveReasonPopulated() {
        Test.startTest();
        SeedContacts seed = new SeedContacts();
        seed.runApexClass(null);
        Test.stopTest();

        // All Denied contacts must have a reason
        Integer deniedWithoutReason = [
            SELECT COUNT()
            FROM Contact
            WHERE Email LIKE 'seed.contact.%@example.test'
            AND   Stakeholder_Status__c = 'Denied'
            AND   Denied_Reason__c = null
        ];
        System.assertEquals(
            0,
            deniedWithoutReason,
            'Every Denied seed contact must have Denied_Reason__c populated'
        );

        // All non-Denied contacts must have a null reason
        Integer nonDeniedWithReason = [
            SELECT COUNT()
            FROM Contact
            WHERE Email LIKE 'seed.contact.%@example.test'
            AND   Stakeholder_Status__c != 'Denied'
            AND   Denied_Reason__c != null
        ];
        System.assertEquals(
            0,
            nonDeniedWithReason,
            'Non-Denied seed contacts must have Denied_Reason__c left blank'
        );
    }

    

    /**
     * Verifies that a user without the ManualDataSeeding custom permission
     * cannot call manuallyExecuteSeedContacts() — an exception is thrown and
     * no Contact records are created.
     */
    @IsTest
    static void manualRun_withoutPermission_throwsAndCreatesNoData() {
        User testUser = createMinimalUser('seed-denied@example.test');
        insert testUser;

        Boolean exceptionThrown = false;
        System.runAs(testUser) {
            Test.startTest();
            try {
                SeedContacts.manuallyExecuteSeedContacts();
            } catch (System.NoAccessException e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(
                false,
                FeatureManagement.checkPermission('ManualDataSeeding'),
                'The test user should have the custom permission.'
            );
        }

        System.assert(exceptionThrown, 'Expected NoAccessException for user without ManualDataSeeding permission');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Contact WHERE Email LIKE 'seed.contact.%@example.test'],
            'No seed contacts should exist after a blocked manual run'
        );
    }

    /**
     * Verifies that running SeedContacts a second time does not insert any
     * additional records — the total stays at 80.
     */
    @IsTest
    static void secondRun_doesNotCreateDuplicates() {
        SeedContacts seed = new SeedContacts();

        Test.startTest();
        seed.runApexClass(null);
        seed.runApexClass(null);
        Test.stopTest();

        System.assertEquals(
            80,
            [SELECT COUNT() FROM Contact WHERE Email LIKE 'seed.contact.%@example.test'],
            'Expected exactly 80 seed contacts after two runs — no duplicates'
        );
    }


    /*
    HELPERS
    */

    static User createMinimalUser(String email) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return new User(
            LastName          = 'TestUser',
            Email             = email,
            Username          = email + '.' + UserInfo.getOrganizationId(),
            Alias             = 'tstusr',
            TimeZoneSidKey    = 'America/Chicago',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id
        );
    }

    static void assignPermissions(Id userId) {
        List<PermissionSetGroup> groups = [
            SELECT Id FROM PermissionSetGroup
            WHERE DeveloperName IN ('Volunteer_Admin', 'Life_Coach_Advanced')
        ];
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSetGroup psg : groups) {
            assignments.add(new PermissionSetAssignment(
                AssigneeId            = userId,
                PermissionSetGroupId  = psg.Id
            ));
        }
        insert assignments;
    }
}