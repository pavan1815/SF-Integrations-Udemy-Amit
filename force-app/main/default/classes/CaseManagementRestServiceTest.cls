@isTest
public with sharing class CaseManagementRestServiceTest {
    //create test data

    @TestSetup
    static void setupTestData() {
        Case testCase = new Case(
            Subject = 'Test Case Subject',
            Description = 'Test Description',
            Priority = 'Medium',
            Origin = 'Web',
            Status = 'New'
        );
        insert testCase;
    } 

    //generate the fake case id
    private static String getFakeCaseId() {
        String prefix = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix();
        return prefix + '0'.repeat(12) + 'AAA';
    }

    @IsTest
    static void testGetCaseWithValidIdReturnsCase() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/case-management/' + testCase.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        System.runAs(currentUser) {
            CaseManagementRestService.ApiResponse  result = CaseManagementRestService.getCase();
            Assert.isTrue(result.success, 'Expected success to be true');
            Assert.areEqual('Case found', result.message, 'Expected Case found message');
        }
        Test.stopTest();

    }

    @IsTest
    static void testCreateCaseWithValidRequestCreatesCase(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/case-management';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        CaseManagementRestService.CaseRequest caseReq = new CaseManagementRestService.CaseRequest();
        caseReq.subject = 'New Test Case';
        caseReq.description = 'New Description';
        caseReq.priority = 'High';
        caseReq.origin = 'Email';

        Test.startTest();
         System.runAs(currentUser) {
            CaseManagementRestService.ApiResponse result = CaseManagementRestService.createCase(caseReq);
            Assert.isTrue(result.success, 'Expected success to be true');
            Assert.areEqual('Case created successfully', result.message, 'Expected Case created successfully message');
         }
        Test.stopTest();
    }

     @IsTest
    static void testUpdateCaseWithValidRequestUpdatesCase() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/case-management/' + testCase.Id;
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        CaseManagementRestService.CaseRequest caseReq = new CaseManagementRestService.CaseRequest();
        caseReq.subject = 'Updated Subject';
        caseReq.description = 'Updated Description';
        caseReq.priority = 'Low';
        caseReq.origin = 'Phone';

        Test.startTest();
        System.runAs(currentUser) {
            CaseManagementRestService.ApiResponse result = CaseManagementRestService.updateCase(caseReq);

            Assert.isTrue(result.success, 'Expected success to be true');
            Assert.areEqual('Case updated successfully', result.message, 'Expected success message');

            Case updated = [SELECT Subject, Priority FROM Case WHERE Id = :testCase.Id];
            Assert.areEqual('Updated Subject', updated.Subject, 'Expected subject to be updated');
            Assert.areEqual('Low', updated.Priority, 'Expected priority to be updated');
        }
        Test.stopTest();
    }


    @IsTest
    static void testPatchCaseWithValidFieldsPatchesCase() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/case-management/' + testCase.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"priority":"Critical","status":"Working"}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        System.runAs(currentUser) {
            CaseManagementRestService.ApiResponse result = CaseManagementRestService.patchCase('Critical', 'Working');

            Assert.isTrue(result.success, 'Expected success to be true');
            Assert.areEqual('Case patched successfully', result.message, 'Expected success message');

            Case patched = [SELECT Priority, Status FROM Case WHERE Id = :testCase.Id];
            Assert.areEqual('Critical', patched.Priority, 'Expected priority to be patched');
            Assert.areEqual('Working', patched.Status, 'Expected status to be patched');
        }
        Test.stopTest();
    }

    @IsTest
    static void testDeleteCaseWithValidIdDeletesCase() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/case-management/' + testCase.Id;
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        System.runAs(currentUser) {
            CaseManagementRestService.ApiResponse result = CaseManagementRestService.deleteCase();

            Assert.isTrue(result.success, 'Expected success to be true');
            Assert.areEqual('Case deleted successfully', result.message, 'Expected success message');
            Assert.isNull(result.data, 'Expected no data in response');

            List<Case> remaining = [SELECT Id FROM Case WHERE Id = :testCase.Id];
            Assert.isTrue(remaining.isEmpty(), 'Case should be deleted');
        }
        Test.stopTest();
    }

}