/**
 * SeedContacts — Sandbox Post-Copy Seed Class
 *
 * PURPOSE
 * -------
 * This class automatically creates 80 fake Contact records in a Salesforce
 * sandbox immediately after it is created or refreshed. It produces 10 contacts
 * for each of the 8 Stakeholder Status values used by Collective Chicago, giving
 * QA testers and developers a realistic spread of data to work with right away.
 *
 * HOW TO USE
 * ----------
 * When creating or refreshing a sandbox in Salesforce Setup, set the "Apex Class"
 * field to "SeedContacts". Salesforce will call this class automatically once the
 * sandbox is ready. No manual steps are needed.
 *
 * SAFETY
 * ------
 * All seed records use email addresses ending in "@example.test", which is a
 * reserved domain that cannot receive real email. If this class is run a second
 * time, it checks for those addresses first and does nothing if they already exist,
 * so duplicate records are never created.
 *
 * CONTACTS CREATED (10 per status, 80 total)
 *   - Applied       — People who have submitted an application
 *   - Interview 1   — People who have completed their first interview
 *   - Interview 2   — People who have completed their second interview
 *   - Interview 3   — People who have completed their third interview
 *   - Denied        — People who were not accepted into the program
 *   - Resident      — People currently living in the program
 *   - Drop Out      — People who left the program before graduating
 *   - Graduated     — People who successfully completed the program
 */
global class SeedContacts implements SandboxPostCopy {

    /**
     * runApexClass — Entry Point
     *
     * WHAT IT DOES
     * Salesforce calls this method automatically when a sandbox is created or
     * refreshed and this class is selected as the post-copy Apex class. It looks
     * up the "Stakeholder" record type, checks whether seed data already exists,
     * and if not, builds and inserts all 90 contacts in a single database operation.
     *
     * INPUTS
     * ctx — Provided automatically by Salesforce. Contains information about the
     *       sandbox environment (name, org ID, etc.). This class does not use it
     *       directly, but the method signature requires it.
     *
     * EXPECTED RESULT
     * 90 Contact records created across all 9 Stakeholder Status values. If seed
     * records already exist (identified by their @example.test email addresses),
     * the method exits immediately without creating any duplicates.
     *
     * USE CASE
     * Run automatically during sandbox creation. Can also be executed manually
     * via Developer Console (Execute Anonymous) for a quick data refresh if the
     * sandbox has been wiped clean.
     */
    global void runApexClass(SandboxContext ctx) {
        executeSeedContacts(ctx);
    }

    public static void manuallyExecuteSeedContacts() {
        if (!FeatureManagement.checkPermission('ManualDataSeeding')) {
            throw new System.NoAccessException();
        }
        executeSeedContacts(null);
    }

    private static void executeSeedContacts(SandboxContext ctx) {
        Id stakeholderRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('Stakeholder')
            .getRecordTypeId();

        Integer existing = [
            SELECT COUNT()
            FROM Contact
            WHERE Email LIKE 'seed.contact.%@example.test'
        ];
        if (existing > 0) {
            return;
        }

        List<Contact> contacts = new List<Contact>();
        contacts.addAll(buildApplied(stakeholderRtId));
        contacts.addAll(buildInterview1(stakeholderRtId));
        contacts.addAll(buildInterview2(stakeholderRtId));
        contacts.addAll(buildInterview3(stakeholderRtId));
        contacts.addAll(buildDenied(stakeholderRtId));
        contacts.addAll(buildResident(stakeholderRtId));
        contacts.addAll(buildDropOut(stakeholderRtId));
        contacts.addAll(buildGraduated(stakeholderRtId));

        insert contacts;
    }


    /*
    -------------------------------------------------------------------------
    BUILDER METHODS
    Each method below constructs and returns a list of 10 Contact records for
    one specific Stakeholder Status. Only fields that are relevant and
    meaningful for that stage of the pipeline are populated — for example,
    interview scores are blank for someone who has Not Applied, and graduation
    dates only exist for people who have Graduated.
    -------------------------------------------------------------------------
    */

    /**
     * buildApplied — Creates 10 contacts who have submitted an application
     *
     * WHAT IT DOES
     * Builds contacts who have completed and submitted an application to the
     * program. These records include an Applied Date and basic background
     * information, but no interview scores yet since they have not been
     * interviewed.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Applied". Each record has
     * an Applied_Date__c in early 2023 and a populated intake monthly income.
     * Interview, resume, and budget scores are all blank.
     *
     * USE CASE
     * Useful for testing application review workflows, verifying that applied
     * contacts appear in the correct queues or list views, and checking that
     * scheduling an interview advances the status correctly.
     */
    static List<Contact> buildApplied(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.ap.01@example.test', 'Davenport',  'Calvin',    'Applied', Date.newInstance(2023,1,3),  null, null, false, false, false, false, null, null, null, 0.00,   null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.02@example.test', 'Hollis',     'Tremaine',  'Applied', Date.newInstance(2023,1,10), null, null, true,  false, true,  false, null, null, null, 350.00, null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.03@example.test', 'Overton',    'Darius',    'Applied', Date.newInstance(2023,1,17), null, null, false, false, false, false, null, null, null, 0.00,   null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.04@example.test', 'Malone',     'Kendrick',  'Applied', Date.newInstance(2023,1,24), null, null, false, false, false, false, null, null, null, 200.00, null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.05@example.test', 'Bassett',    'Tyrone',    'Applied', Date.newInstance(2023,2,1),  null, null, true,  false, true,  false, null, null, null, 0.00,   null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.06@example.test', 'Thornton',   'Jermaine',  'Applied', Date.newInstance(2023,2,8),  null, null, false, false, false, false, null, null, null, 300.00, null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.07@example.test', 'Pendleton',  'Shawn',     'Applied', Date.newInstance(2023,2,15), null, null, false, false, false, false, null, null, null, 0.00,   null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.08@example.test', 'Kimble',     'Brandon',   'Applied', Date.newInstance(2023,2,22), null, null, false, false, false, false, null, null, null, 200.00, null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.09@example.test', 'Burgess',    'Nathan',    'Applied', Date.newInstance(2023,3,1),  null, null, true,  false, false, true,  null, null, null, 0.00,   null, null, false, null, null, null, null, null, null, null));
        records.add(make(rtId, 'seed.contact.ap.10@example.test', 'Tillman',    'Corey',     'Applied', Date.newInstance(2023,3,8),  null, null, false, false, false, false, null, null, null, 250.00, null, null, false, null, null, null, null, null, null, null));
        return records;
    }

    /**
     * buildInterview1 — Creates 10 contacts in the first round of interviews
     *
     * WHAT IT DOES
     * Builds contacts who have progressed past the application stage and completed
     * their first interview with Collective Chicago staff. These records include
     * interview scores assigned by the interviewer, rated on a scale of 1-10.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Interview 1". Each record
     * has an Applied Date, an intake monthly income, and interview scores in the
     * moderate range (6-8). Resume and budget scores are still blank.
     *
     * USE CASE
     * Useful for testing interview scoring logic, verifying that score-based
     * automation triggers correctly at this stage, and checking that the Interview
     * 1 page layout renders all the right fields.
     */
    static List<Contact> buildInterview1(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.i1.01@example.test', 'Norris',    'DeShawn',   'Interview 1', Date.newInstance(2023,3,15), null, null, false, false, false, false, 7, 6, 7, 0.00,   7, 6, false, 7, 7, 7, 7, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.02@example.test', 'Prichard',  'Wendell',   'Interview 1', Date.newInstance(2023,3,22), null, null, true,  false, true,  false, 6, 7, 6, 300.00, 6, 6, false, 6, 6, 7, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.03@example.test', 'Merritt',   'Alonzo',    'Interview 1', Date.newInstance(2023,3,29), null, null, false, false, false, false, 8, 8, 7, 0.00,   7, 7, false, 7, 8, 8, 7, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.04@example.test', 'Langston',  'Courtney',  'Interview 1', Date.newInstance(2023,4,5),  null, null, false, false, false, false, 6, 7, 6, 200.00, 6, 6, false, 6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.05@example.test', 'Dunbar',    'Marquise',  'Interview 1', Date.newInstance(2023,4,12), null, null, true,  false, true,  false, 7, 7, 7, 0.00,   7, 7, false, 7, 7, 7, 7, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.06@example.test', 'Caldwell',  'Preston',   'Interview 1', Date.newInstance(2023,4,19), null, null, false, false, false, false, 7, 7, 7, 250.00, 6, 7, false, 6, 7, 7, 7, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.07@example.test', 'Howell',    'Devin',     'Interview 1', Date.newInstance(2023,4,26), null, null, false, false, false, false, 8, 8, 7, 0.00,   8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.08@example.test', 'Stanton',   'Elijah',    'Interview 1', Date.newInstance(2023,5,3),  null, null, false, false, false, false, 6, 6, 6, 300.00, 6, 6, false, 6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.09@example.test', 'Ingram',    'Rashad',    'Interview 1', Date.newInstance(2023,5,10), null, null, true,  false, true,  false, 7, 7, 7, 0.00,   7, 7, false, 7, 7, 7, 7, null, null, null));
        records.add(make(rtId, 'seed.contact.i1.10@example.test', 'Vance',     'Cornelius', 'Interview 1', Date.newInstance(2023,5,17), null, null, false, false, false, false, 7, 7, 6, 500.00, 7, 7, false, 7, 7, 7, 7, null, null, null));
        return records;
    }

    /**
     * buildInterview2 — Creates 10 contacts in the second round of interviews
     *
     * WHAT IT DOES
     * Builds contacts who have passed their first interview and are progressing
     * through the second interview. Scores are slightly higher than Interview 1,
     * reflecting that this group has demonstrated stronger potential.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Interview 2". Interview
     * scores fall in the 7-8 range. Resume and budget scores are still blank.
     *
     * USE CASE
     * Useful for testing multi-stage interview workflows, verifying that contacts
     * move correctly between Interview 1 and Interview 2 statuses, and checking
     * score aggregation or display at this stage.
     */
    static List<Contact> buildInterview2(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.i2.01@example.test', 'Kessler',    'Damien',    'Interview 2', Date.newInstance(2023,5,24), null, null, false, false, false, false, 8, 8, 8, 0.00,   8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.02@example.test', 'Maxwell',    'Tavion',    'Interview 2', Date.newInstance(2023,5,31), null, null, true,  false, true,  false, 8, 8, 8, 500.00, 8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.03@example.test', 'Fontaine',   'Broderick', 'Interview 2', Date.newInstance(2023,6,7),  null, null, false, false, false, false, 7, 8, 7, 0.00,   8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.04@example.test', 'Ashworth',   'Kelvin',    'Interview 2', Date.newInstance(2023,6,14), null, null, false, false, false, false, 8, 7, 8, 500.00, 8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.05@example.test', 'Edmonds',    'Jarvis',    'Interview 2', Date.newInstance(2023,6,21), null, null, true,  false, true,  false, 8, 8, 8, 0.00,   8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.06@example.test', 'Okonkwo',    'Terrell',   'Interview 2', Date.newInstance(2023,6,28), null, null, false, false, false, false, 7, 8, 7, 500.00, 7, 8, false, 7, 8, 7, 7, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.07@example.test', 'Rutherford', 'Dwayne',    'Interview 2', Date.newInstance(2023,7,5),  null, null, false, false, false, false, 8, 8, 8, 0.00,   8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.08@example.test', 'Givens',     'Fletcher',  'Interview 2', Date.newInstance(2023,7,12), null, null, false, false, false, false, 8, 8, 8, 350.00, 8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.09@example.test', 'Whittaker',  'Jerome',    'Interview 2', Date.newInstance(2023,7,19), null, null, true,  false, true,  false, 8, 8, 8, 0.00,   8, 8, false, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i2.10@example.test', 'Delaney',    'Carlton',   'Interview 2', Date.newInstance(2023,7,26), null, null, false, false, false, false, 7, 7, 7, 500.00, 7, 7, false, 7, 7, 7, 7, null, null, null));
        return records;
    }

    /**
     * buildInterview3 — Creates 10 contacts in the final round of interviews
     *
     * WHAT IT DOES
     * Builds contacts who are in the final and most selective interview stage.
     * These are the strongest candidates in the pipeline. Scores are high (8-9)
     * and bank account status is marked true, reflecting that budget review has
     * begun at this stage.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Interview 3". Interview
     * scores are in the 8-9 range. Bank account is set to true for all records.
     * Resume scores are also populated since resume review occurs at this stage.
     *
     * USE CASE
     * Useful for testing final admissions decisions, verifying that acceptance
     * automation fires correctly, and checking that the full interview scorecard
     * displays and calculates as expected.
     */
    static List<Contact> buildInterview3(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.i3.01@example.test', 'Holloway',  'Demetrius', 'Interview 3', Date.newInstance(2023,8,2),  null, null, false, false, false, false, 9, 9, 8, 0.00,   9, 8, true, 9, 8, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.02@example.test', 'Whitfield', 'Tremaine',  'Interview 3', Date.newInstance(2023,8,9),  null, null, true,  false, true,  false, 9, 9, 8, 500.00, 9, 8, true, 9, 8, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.03@example.test', 'Clayborne', 'Damarius',  'Interview 3', Date.newInstance(2023,8,16), null, null, false, false, false, false, 9, 9, 9, 0.00,   9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.04@example.test', 'Hatchett',  'Lionel',    'Interview 3', Date.newInstance(2023,8,23), null, null, false, false, false, false, 9, 8, 8, 250.00, 8, 9, true, 8, 9, 9, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.05@example.test', 'Grimes',    'Octavious', 'Interview 3', Date.newInstance(2023,8,30), null, null, true,  false, true,  false, 9, 9, 9, 0.00,   9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.06@example.test', 'Beaumont',  'Stephon',   'Interview 3', Date.newInstance(2023,9,6),  null, null, false, false, false, false, 8, 8, 8, 200.00, 8, 8, true, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.07@example.test', 'Culpepper', 'Tyrone',    'Interview 3', Date.newInstance(2023,9,13), null, null, false, false, false, false, 9, 9, 9, 0.00,   9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.08@example.test', 'Drummond',  'Lavell',    'Interview 3', Date.newInstance(2023,9,20), null, null, false, false, false, false, 8, 8, 8, 500.00, 8, 8, true, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.09@example.test', 'Odom',      'Marcellis', 'Interview 3', Date.newInstance(2023,9,27), null, null, true,  false, true,  false, 9, 9, 9, 0.00,   9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.i3.10@example.test', 'Fullerton', 'Zacharias', 'Interview 3', Date.newInstance(2023,10,4), null, null, false, false, false, false, 8, 8, 8, 500.00, 8, 8, true, 8, 8, 8, 8, null, null, null));
        return records;
    }

    /**
     * buildDenied — Creates 10 contacts who were not accepted into the program
     *
     * WHAT IT DOES
     * Builds contacts who went through at least one interview but were ultimately
     * not accepted. Their interview scores are intentionally low (3-5) to reflect
     * the reasons they were not admitted.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Denied". Each has an
     * Applied Date, a low fervor score, and a Denied_Reason__c picklist value
     * explaining why the person was not admitted (e.g. "Lost Contact", "Apathy").
     * Resume and budget fields are blank because the process did not advance that far.
     *
     * USE CASE
     * Useful for testing denial workflows and notifications, verifying that denied
     * contacts are excluded from active pipeline reports, and checking that the
     * Denied Reason field and related automations behave correctly.
     */
    static List<Contact> buildDenied(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.dn.01@example.test', 'Boateng',   'Shelton',   'Denied', Date.newInstance(2023,10,11), null, null, false, false, false, false, 5, null, null, 0.00,   null, null, false, null, null, null, null, null, null, 'Lost Contact'));
        records.add(make(rtId, 'seed.contact.dn.02@example.test', 'Foxworth',  'Wendell',   'Denied', Date.newInstance(2023,10,18), null, null, true,  false, true,  false, 4, null, null, 200.00, null, null, false, null, null, null, null, null, null, 'Apathy'));
        records.add(make(rtId, 'seed.contact.dn.03@example.test', 'Townsend',  'Reginald',  'Denied', Date.newInstance(2023,10,25), null, null, false, false, false, false, 5, null, null, 0.00,   null, null, false, null, null, null, null, null, null, 'Does Not Fit Admission Criteria'));
        records.add(make(rtId, 'seed.contact.dn.04@example.test', 'Okafor',    'Bertrand',  'Denied', Date.newInstance(2023,11,1),  null, null, true,  false, true,  true,  3, null, null, 200.00, null, null, false, null, null, null, null, null, null, 'Absentee'));
        records.add(make(rtId, 'seed.contact.dn.05@example.test', 'Whitaker',  'Lamont',    'Denied', Date.newInstance(2023,11,8),  null, null, false, false, false, false, 4, null, null, 0.00,   null, null, false, null, null, null, null, null, null, 'Aggression'));
        records.add(make(rtId, 'seed.contact.dn.06@example.test', 'Sampson',   'Donnell',   'Denied', Date.newInstance(2023,11,15), null, null, false, false, false, false, 4, null, null, 250.00, null, null, false, null, null, null, null, null, null, 'Found Alternate'));
        records.add(make(rtId, 'seed.contact.dn.07@example.test', 'Moorehead', 'Terrence',  'Denied', Date.newInstance(2023,11,22), null, null, true,  false, true,  false, 5, null, null, 0.00,   null, null, false, null, null, null, null, null, null, 'More Work Needed on Resume'));
        records.add(make(rtId, 'seed.contact.dn.08@example.test', 'Beauchamp', 'Clarence',  'Denied', Date.newInstance(2023,11,29), null, null, false, false, false, false, 4, null, null, 300.00, null, null, false, null, null, null, null, null, null, 'More Work Needed on Budget'));
        records.add(make(rtId, 'seed.contact.dn.09@example.test', 'Gillespie', 'Marvin',    'Denied', Date.newInstance(2023,12,6),  null, null, false, false, false, false, 4, null, null, 0.00,   null, null, false, null, null, null, null, null, null, 'Found Alternate'));
        records.add(make(rtId, 'seed.contact.dn.10@example.test', 'Hargrave',  'Quentin',   'Denied', Date.newInstance(2023,12,13), null, null, true,  false, true,  false, 3, null, null, 200.00, null, null, false, null, null, null, null, null, null, 'No Openings'));
        return records;
    }

    /**
     * buildResident — Creates 10 contacts who are currently living in the program
     *
     * WHAT IT DOES
     * Builds contacts who have been fully accepted and have moved into Collective
     * Chicago housing. These are the most data-rich records in the active pipeline:
     * they have applied, interviewed, and moved in, so nearly all scored fields
     * are populated.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Resident". Each record has
     * an Applied Date, a Move-In Date in mid-2023, high interview scores (8-9),
     * populated resume and budget scores, and bank account set to true. Move-Out
     * Date and Graduation Date are blank because they are still in the program.
     *
     * USE CASE
     * Useful for testing the resident dashboard, rent tracking, check-up workflows,
     * and any logic that should only apply to people who are currently housed. Also
     * useful for testing SROI baseline calculations that depend on move-in date.
     */
    static List<Contact> buildResident(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.rs.01@example.test', 'Pennington',   'Aloysius',   'Resident', Date.newInstance(2023,1,10),  Date.newInstance(2023,6,1),  null, true,  false, true,  false, 9, 8, 9, 500.00, 8, 9, true, 8, 9, 9, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.02@example.test', 'Underwood',    'Broderick',  'Resident', Date.newInstance(2023,1,17),  Date.newInstance(2023,6,15), null, false, false, false, false, 9, 9, 9, 250.00, 8, 9, true, 8, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.03@example.test', 'Kimborough',   'Rasheed',    'Resident', Date.newInstance(2023,1,24),  Date.newInstance(2023,7,1),  null, false, false, false, false, 9, 8, 8, 0.00,   8, 8, true, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.04@example.test', 'Morrow',       'Fitzgerald', 'Resident', Date.newInstance(2023,2,1),   Date.newInstance(2023,7,15), null, true,  false, true,  false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.05@example.test', 'Abernathy',    'Kentrell',   'Resident', Date.newInstance(2023,2,8),   Date.newInstance(2023,8,1),  null, false, false, false, false, 9, 8, 8, 250.00, 8, 9, true, 8, 9, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.06@example.test', 'Hightower',    'Donavon',    'Resident', Date.newInstance(2023,2,15),  Date.newInstance(2023,8,15), null, false, false, false, false, 9, 9, 9, 0.00,   9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.07@example.test', 'Dupree',       'Marcelino',  'Resident', Date.newInstance(2023,2,22),  Date.newInstance(2023,9,1),  null, false, false, false, false, 9, 8, 8, 500.00, 8, 8, true, 8, 8, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.08@example.test', 'Ogletree',     'Sylvester',  'Resident', Date.newInstance(2023,3,1),   Date.newInstance(2023,9,15), null, true,  false, true,  false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.09@example.test', 'Bankhead',     'Elsworth',   'Resident', Date.newInstance(2023,3,8),   Date.newInstance(2023,10,1), null, false, false, false, false, 9, 8, 8, 250.00, 8, 9, true, 8, 9, 8, 8, null, null, null));
        records.add(make(rtId, 'seed.contact.rs.10@example.test', 'Featherstone', 'Carnell',    'Resident', Date.newInstance(2023,3,15),  Date.newInstance(2023,10,15),null, false, false, false, false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, null, null, null));
        return records;
    }

    /**
     * buildDropOut — Creates 10 contacts who left the program before graduating
     *
     * WHAT IT DOES
     * Builds contacts who were accepted and moved in, but exited the program
     * before completing it. These records have both a Move-In Date and a Move-Out
     * Date, but no Graduation Date. Scores are in the mid range (5-7), reflecting
     * that these residents showed some promise but encountered obstacles.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Drop Out". Each record has
     * an Applied Date, a Move-In Date, and a Move-Out Date (all in 2022-2023).
     * Graduation Date is blank. Scores are populated but lower than Resident or
     * Graduated records.
     *
     * USE CASE
     * Useful for testing exit workflows, verifying that dropped-out contacts are
     * correctly excluded from active resident counts, and checking that SROI
     * calculations handle incomplete program histories appropriately.
     */
    static List<Contact> buildDropOut(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.do.01@example.test', 'Whitmore',   'Algernon',  'Drop Out', Date.newInstance(2022,3,22),  Date.newInstance(2022,7,1),   Date.newInstance(2022,10,15), false, false, false, false, 7, 6, 6, 0.00,   6, 7, true,  7, 7, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.02@example.test', 'Threadgill', 'Beaumont',  'Drop Out', Date.newInstance(2022,4,5),   Date.newInstance(2022,8,1),   Date.newInstance(2022,11,1),  true,  false, true,  false, 7, 6, 6, 200.00, 6, 6, true,  6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.03@example.test', 'Pressley',   'Octavian',  'Drop Out', Date.newInstance(2022,4,19),  Date.newInstance(2022,9,1),   Date.newInstance(2022,11,15), false, false, false, false, 7, 6, 6, 250.00, 6, 6, true,  6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.04@example.test', 'Dillworth',  'Reginald',  'Drop Out', Date.newInstance(2022,5,3),   Date.newInstance(2022,9,15),  Date.newInstance(2022,12,1),  false, false, false, false, 6, 6, 6, 200.00, 6, 6, false, 6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.05@example.test', 'Hightower',  'Cornelius', 'Drop Out', Date.newInstance(2022,5,17),  Date.newInstance(2022,10,1),  Date.newInstance(2022,12,15), true,  false, true,  false, 6, 6, 6, 250.00, 6, 6, true,  6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.06@example.test', 'Kilpatrick', 'Wendell',   'Drop Out', Date.newInstance(2022,6,1),   Date.newInstance(2022,10,15), Date.newInstance(2023,1,15),  false, false, false, false, 7, 6, 6, 0.00,   6, 7, true,  7, 7, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.07@example.test', 'Pendergast', 'Lemuel',    'Drop Out', Date.newInstance(2022,6,15),  Date.newInstance(2022,11,1),  Date.newInstance(2023,2,1),   false, false, false, false, 6, 7, 6, 300.00, 6, 6, true,  6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.08@example.test', 'Covington',  'Thaddeus',  'Drop Out', Date.newInstance(2022,7,6),   Date.newInstance(2022,11,15), Date.newInstance(2023,2,15),  true,  false, true,  false, 6, 6, 6, 0.00,   6, 6, true,  6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.09@example.test', 'Harrington', 'Valentino', 'Drop Out', Date.newInstance(2022,7,20),  Date.newInstance(2022,12,1),  Date.newInstance(2023,3,1),   false, false, false, false, 6, 6, 6, 250.00, 6, 6, false, 6, 6, 6, 6, null, null, null));
        records.add(make(rtId, 'seed.contact.do.10@example.test', 'Flemming',   'Ezekiel',   'Drop Out', Date.newInstance(2022,8,3),   Date.newInstance(2022,12,15), Date.newInstance(2023,3,15),  false, false, false, false, 7, 7, 7, 500.00, 7, 7, true,  6, 6, 6, 6, null, null, null));
        return records;
    }

    /**
     * buildGraduated — Creates 10 contacts who successfully completed the program
     *
     * WHAT IT DOES
     * Builds the most complete contacts in the data set: people who applied,
     * interviewed, moved in, and graduated. These records have the full set of
     * dates (Applied, Move-In, Move-Out, and Graduation) as well as post-program
     * outcome data including graduate income and credit score. All scores are high
     * (9s), reflecting that graduates represent the program's best outcomes.
     *
     * INPUTS
     * rtId — The Salesforce Record Type ID for "Stakeholder".
     *
     * EXPECTED RESULT
     * 10 Contact records with Stakeholder_Status__c = "Graduated". Each record has
     * all four date fields populated (2021-2023), near-perfect scores across all
     * categories, health benefits set to true, a post-program monthly income
     * between $2,800 and $3,600, and a graduate credit score between 700 and 790.
     * Graduation Date is automatically set equal to Move-Out Date by the make()
     * method.
     *
     * USE CASE
     * Useful for testing SROI calculations, graduation reports, outcome dashboards,
     * and any logic that compares a graduate's pre-program intake income against
     * their post-program income. Also the primary data set for testing the Annual
     * Giving Statement flow.
     */
    static List<Contact> buildGraduated(Id rtId) {
        List<Contact> records = new List<Contact>();
        records.add(make(rtId, 'seed.contact.gr.01@example.test', 'Winslow',    'Bartholomew', 'Graduated', Date.newInstance(2021,3,1),  Date.newInstance(2021,9,1),  Date.newInstance(2022,6,1),  true,  false, true,  false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3200.00, 750, null));
        records.add(make(rtId, 'seed.contact.gr.02@example.test', 'Ashworth',   'Cornelius',   'Graduated', Date.newInstance(2021,4,1),  Date.newInstance(2021,10,1), Date.newInstance(2022,7,15), false, false, false, false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3500.00, 770, null));
        records.add(make(rtId, 'seed.contact.gr.03@example.test', 'Abington',   'Desmond',     'Graduated', Date.newInstance(2021,5,1),  Date.newInstance(2021,11,1), Date.newInstance(2022,8,1),  false, false, false, false, 9, 9, 9, 0.00,   9, 9, true, 9, 9, 9, 9, 2900.00, 700, null));
        records.add(make(rtId, 'seed.contact.gr.04@example.test', 'Goldsworth', 'Fabian',      'Graduated', Date.newInstance(2021,6,1),  Date.newInstance(2021,12,1), Date.newInstance(2022,9,1),  false, false, false, false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3100.00, 760, null));
        records.add(make(rtId, 'seed.contact.gr.05@example.test', 'Fulton',     'Jamarius',    'Graduated', Date.newInstance(2021,7,1),  Date.newInstance(2022,1,1),  Date.newInstance(2022,10,1), true,  false, true,  false, 9, 8, 9, 200.00, 9, 9, true, 9, 9, 9, 9, 2800.00, 720, null));
        records.add(make(rtId, 'seed.contact.gr.06@example.test', 'Beauregard', 'Kelton',      'Graduated', Date.newInstance(2021,8,1),  Date.newInstance(2022,2,1),  Date.newInstance(2022,11,1), false, false, false, false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3300.00, 780, null));
        records.add(make(rtId, 'seed.contact.gr.07@example.test', 'Caldwell',   'Lysander',    'Graduated', Date.newInstance(2021,9,1),  Date.newInstance(2022,3,1),  Date.newInstance(2022,12,1), false, false, false, false, 9, 9, 9, 250.00, 9, 9, true, 9, 9, 9, 9, 3000.00, 740, null));
        records.add(make(rtId, 'seed.contact.gr.08@example.test', 'Blackstone', 'Remington',   'Graduated', Date.newInstance(2021,10,1), Date.newInstance(2022,4,1),  Date.newInstance(2023,1,1),  true,  false, true,  false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3600.00, 790, null));
        records.add(make(rtId, 'seed.contact.gr.09@example.test', 'Alderman',   'Sylvanus',    'Graduated', Date.newInstance(2021,11,1), Date.newInstance(2022,5,1),  Date.newInstance(2023,2,1),  false, false, false, false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3100.00, 755, null));
        records.add(make(rtId, 'seed.contact.gr.10@example.test', 'Whitfield',  'Theron',      'Graduated', Date.newInstance(2021,12,1), Date.newInstance(2022,6,1),  Date.newInstance(2023,3,1),  false, false, false, false, 9, 9, 9, 500.00, 9, 9, true, 9, 9, 9, 9, 3200.00, 745, null));
        return records;
    }


    /*
    -------------------------------------------------------------------------
    FACTORY METHOD
    -------------------------------------------------------------------------
    */

    /**
     * make — Constructs a single Contact record from individual field values
     *
     * WHAT IT DOES
     * This is the shared helper that all the builder methods above call. It
     * accepts every configurable field as a separate input, assembles them into
     * a Salesforce Contact object, and returns it. Score fields that are passed
     * as null are simply left blank on the record rather than set to zero, so
     * that early-stage contacts don't appear to have been scored when they haven't.
     *
     * For Graduated contacts, the Graduation Date is automatically set to match
     * the Move-Out Date, since those two dates are always the same in practice.
     *
     * INPUTS — in order
     *   rtId                   — The Salesforce Record Type ID for "Stakeholder"
     *   email                  — A unique @example.test address used as the seed key
     *   lastName               — Last name (fictional)
     *   firstName              — First name (fictional)
     *   status                 — Stakeholder Status picklist value (e.g. "Resident")
     *   appliedDate            — Date the application was submitted; null if not yet applied
     *   moveInDate             — Date the person moved into the program; null if not yet a resident
     *   moveOutDate            — Date the person left the program; null if still active
     *   criminalRecord         — True if any criminal record was disclosed on the application
     *   criminalFelony         — True if the criminal record includes a felony
     *   criminalMisdemeanor    — True if the criminal record includes a misdemeanor
     *   drugAlcohol            — True if drug or alcohol history was disclosed at intake
     *   fervor                 — Interview score: enthusiasm for the opportunity (1-10); null if not yet interviewed
     *   levelOfNeed            — Interview score: assessed level of need (1-10); null if not yet interviewed
     *   ownership              — Interview score: sense of personal ownership/accountability (1-10); null if not yet interviewed
     *   intakeIncome           — Monthly post-tax income reported at intake, in dollars
     *   marketability          — Interview score: employability and marketability (1-10); null if not yet interviewed
     *   interviewBudgetScore   — Interest in learning about budgeting, scored during interview (1-10)
     *   bankAccount            — True if the person has a bank account at the time of assessment
     *   resumeInitialQuality   — Resume score: quality of the initial resume submission (1-10)
     *   resumeProgress         — Resume score: improvement made over the course of coaching (1-10)
     *   resumeOnlineMarketability — Resume score: quality of online presence (LinkedIn, etc.) (1-10)
     *   resumeTimeliness       — Resume score: whether assignments were completed on time (1-10)
     *   graduateIncome         — Monthly post-tax income after graduating the program, in dollars; null if not graduated
     *   graduateCreditScore    — Credit score at time of graduation (e.g. 720); null if not graduated
     *   deniedReason           — A valid picklist value from Denied_Reason__c explaining why the person was not
     *                            accepted (e.g. "Lost Contact", "Apathy"); must be null for all statuses other
     *                            than "Denied"
     *
     * EXPECTED RESULT
     * A single Contact object ready to be added to a list and inserted. The
     * record is not saved to the database by this method — that happens in
     * runApexClass after all 90 records are assembled.
     *
     * USE CASE
     * Called exclusively by the builder methods in this class. Not intended to
     * be called directly from outside this class.
     */
    static Contact make(
        Id      rtId,
        String  email,
        String  lastName,
        String  firstName,
        String  status,
        Date    appliedDate,
        Date    moveInDate,
        Date    moveOutDate,
        Boolean criminalRecord,
        Boolean criminalFelony,
        Boolean criminalMisdemeanor,
        Boolean drugAlcohol,
        Integer fervor,
        Integer levelOfNeed,
        Integer ownership,
        Decimal intakeIncome,
        Integer marketability,
        Integer interviewBudgetScore,
        Boolean bankAccount,
        Integer resumeInitialQuality,
        Integer resumeProgress,
        Integer resumeOnlineMarketability,
        Integer resumeTimeliness,
        Decimal graduateIncome,
        Integer graduateCreditScore,
        String  deniedReason
    ) {
        Contact c = new Contact(
            RecordTypeId                       = rtId,
            LastName                           = lastName,
            FirstName                          = firstName,
            Email                              = email,
            npe01__Preferred_Email__c          = 'Personal',
            npe01__HomeEmail__c                = email,
            Stakeholder_Status__c              = status,
            Applied_Date__c                    = appliedDate,
            residentMoveInDate__c              = moveInDate,
            residentMoveOutDate__c             = moveOutDate,
            applicationCriminalRecord__c       = criminalRecord,
            intakeCriminalRecordFelony__c      = criminalFelony,
            intakeCriminalRecordMisdemeanor__c = criminalMisdemeanor,
            intakeDrugAlcoholAbuse__c          = drugAlcohol,
            intakePostTaxIncome__c             = intakeIncome,
            budgetBankAccount__c               = bankAccount,
            graduatePostTaxIncome__c           = graduateIncome
        );

        if (fervor != null)                    c.interviewFervorForOpportunity__c  = fervor;
        if (levelOfNeed != null)               c.interviewLevelOfNeed__c           = levelOfNeed;
        if (ownership != null)                 c.interviewOwnership__c             = ownership;
        if (marketability != null)             c.interviewMarketability__c         = marketability;
        if (interviewBudgetScore != null)      c.budgetInterestInLearning__c       = interviewBudgetScore;
        if (resumeInitialQuality != null)      c.resumeInitialQuality__c           = resumeInitialQuality;
        if (resumeProgress != null)            c.resumeProgressMade__c             = resumeProgress;
        if (resumeOnlineMarketability != null) c.resumeOnlineMarketability__c      = resumeOnlineMarketability;
        if (resumeTimeliness != null)          c.resumeTimeliness__c               = resumeTimeliness;
        if (graduateCreditScore != null)       c.graduateCreditScore__c            = graduateCreditScore;
        if (deniedReason != null)              c.Denied_Reason__c                  = deniedReason;

        // Graduation date always matches move-out date for graduates
        if (status == 'Graduated' && moveOutDate != null) {
            c.residentGraduationDate__c = moveOutDate;
        }

        return c;
    }
}