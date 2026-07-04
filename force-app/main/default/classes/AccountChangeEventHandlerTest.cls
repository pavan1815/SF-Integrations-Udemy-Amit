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
private class AccountChangeEventHandlerTest {
  @isTest
  static void testDeactivationCreatesTask() {
    Test.enableChangeDataCapture();

    Account acc = new Account(Name = 'Test Deactivate', Active__c = 'Yes');
    insert acc;
    Test.getEventBus().deliver();

    Test.startTest();

    acc.Active__c = 'No';
    update acc;
    Test.getEventBus().deliver();
    Test.stopTest();

    List<Task> tasks = [
      SELECT Subject, WhatId, Priority, ActivityDate
      FROM Task
      WHERE WhatId = :acc.Id
    ];
    System.assertEquals(1, tasks.size(), 'Should create 1 follow-up task');
  }
}
