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
private class JiraServiceTest {
  //mock the success reponse
  private class JiraCalloutMockSuccess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      System.assertEquals('POST', req.getMethod(), 'Expected POST method');
      System.assert(
        req.getEndpoint().contains('/rest/api/3/issue'),
        'Expected Jira issue endpoint'
      );
      HttpResponse res = new HttpResponse();
      res.setStatusCode(201);
      res.setBody(
        '{"id":"10042","key":"KAN-42","self":"https://jira.example.com/rest/api/3/issue/10042"}'
      );
      return res;
    }
  }

  private class JiraCalloutMockFailure implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(400);
      res.setBody('{"errorMessages":["Field required"],"errors":{}}');
      return res;
    }
  }

  @TestSetup
  static void setupTestData() {
    Case testCase = new Case(
      Subject = 'Test Jira Integration',
      Priority = 'High',
      Status = 'New'
    );
    insert testCase;
  }

  @IsTest
  static void itShouldCreateJiraIssueOnSuccess() {
    Case testCase = [SELECT Id, Subject, Priority FROM Case LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new JiraCalloutMockSuccess());
    Test.startTest();
    JiraService.createIssueFromCase(testCase);
    Test.stopTest();
  }
}
