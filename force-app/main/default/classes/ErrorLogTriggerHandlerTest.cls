/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ErrorLogTriggerHandlerTest {
  @isTest
  static void testSingleEventCreatesLog() {
    // TO DO: implement unit test

    // Publish event
    Error_Log__e event = new Error_Log__e(
      Source__c = 'TestClass.testMethod',
      Severity__c = 'ERROR',
      Error_Message__c = 'Test error message',
      Record_Id__c = '001000000000001',
      Stack_Trace__c = 'Line 10: NullPointerException',
      User_Id__c = UserInfo.getUserId()
    );

    Test.startTest();
    EventBus.publish(event);
    Test.stopTest();

    // Verify Integration_Log__c record was created
    List<Integration_Log__c> logs = [
      SELECT
        Source__c,
        Serverity__c,
        Error_Message__c,
        Record_Id__c,
        Stack_Trace__c,
        User_Id__c,
        Logged_At__c
      FROM Integration_Log__c
    ];

    System.assertEquals(1, logs.size(), 'Should create one log record');
  }
}
