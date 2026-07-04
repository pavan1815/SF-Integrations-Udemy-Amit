@RestResource(urlMapping='/case-management/*')
global with sharing class CaseManagementRestService {


@HttpGet
global static ApiResponse getCase(){

    String caseId = extractIdFromUrl();
    
    if(String.isBlank(caseId)){
        RestContext.response.statusCode = 400; // Bad Request
        return errorResponse('Case ID is required in the URL');
    }

    List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Description, Status, Priority,
                   Origin, Type, ContactId, AccountId, CreatedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

    if (cases.isEmpty()) {
            RestContext.response.statusCode = 404;
            return errorResponse('Case not found with Id: ' + caseId);
        }

    Case c = cases[0];
    CaseData caseData = new CaseData();
    caseData.caseId = c.Id;
    caseData.caseNumber = c.CaseNumber;
    caseData.status = c.Status;
    caseData.priority = c.Priority;
    caseData.subject = c.Subject;

    return successResponse(true, 'Case found', caseData);
}

@httppost
global static ApiResponse createCase(CaseRequest request){

    Case newCase = new Case();
    newCase.Subject = request.subject;
    newCase.Description = request.description;
    newCase.Priority = request.priority;
    newCase.Origin = request.origin;

    try {
        insert newCase;

        // Re-query to get the auto-generated CaseNumber
        Case created = [SELECT Id, CaseNumber,status,priority,subject FROM Case WHERE Id = :newCase.Id LIMIT 1];

        CaseData responseData = new CaseData();
        responseData.caseId = newCase.Id;
        responseData.caseNumber = created.CaseNumber;
        responseData.status = created.Status;
        responseData.priority = created.Priority;
        responseData.subject = created.Subject;
        RestContext.response.statusCode = 201;

        return successResponse(true, 'Case created successfully', responseData);

    } catch (Exception ex) {
        RestContext.response.statusCode = 500;
        return errorResponse('Error creating case: ' + ex.getMessage());
    }
}

@httpput
global static ApiResponse updateCase(CaseRequest request){
    String caseId = extractIdFromUrl();

    if(String.isBlank(caseId)){
        RestContext.response.statusCode = 400; // Bad Request
        return errorResponse('Case ID is required in the URL');
    }

    List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Description, Status, Priority,
                   Origin, Type, ContactId, AccountId, CreatedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

    if (cases.isEmpty()) {
            RestContext.response.statusCode = 404;
            return errorResponse('Case not found with Id: ' + caseId);
    }

    Case caseToUpdate = new Case(Id = caseId);
    caseToUpdate.Subject = request.subject;
    caseToUpdate.Description = request.description;
    caseToUpdate.Priority = request.priority;
    caseToUpdate.Origin = request.origin;

    try {
        update caseToUpdate;
        // Re-query to get updated values
        Case updated = [SELECT Id, CaseNumber, Status, Priority, Subject FROM Case WHERE Id = :caseId LIMIT 1];
        CaseData responseData = new CaseData();
        responseData.caseId = updated.Id;
        responseData.caseNumber = updated.CaseNumber;
        responseData.status = updated.Status;
        responseData.priority = updated.Priority;
        responseData.subject = updated.Subject;
        return successResponse(true, 'Case updated successfully', responseData);
    } catch (Exception ex) {
        RestContext.response.statusCode = 500;
        return errorResponse('Error updating case: ' + ex.getMessage());
    }
}

@httpPatch
global static ApiResponse patchCase(String priority , String status){
    String caseId = extractIdFromUrl();
    
    if(String.isBlank(caseId)){
        RestContext.response.statusCode = 400; // Bad Request
        return errorResponse('Case ID is required in the URL');
    }

    List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Description, Status, Priority,
                   Origin, Type, ContactId, AccountId, CreatedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

    if (cases.isEmpty()) {
            RestContext.response.statusCode = 404;
            return errorResponse('Case not found with Id: ' + caseId);
    }

    Case caseToUpdate = new Case(Id = caseId);
    if(!String.isBlank(priority)){
        caseToUpdate.Priority = priority;
    }
    if(!String.isBlank(status)){
        caseToUpdate.Status = status;
    }

    try {
        update caseToUpdate;
        // Re-query to get updated values
        Case updated = [SELECT Id, CaseNumber, Status, Priority, Subject FROM Case WHERE Id = :caseId LIMIT 1];
        CaseData responseData = new CaseData();
        responseData.caseId = updated.Id;
        responseData.caseNumber = updated.CaseNumber;
        responseData.status = updated.Status;
        responseData.priority = updated.Priority;
        responseData.subject = updated.Subject;
        return successResponse(true, 'Case patched successfully', responseData);
    } catch (Exception ex) {
        RestContext.response.statusCode = 500;
        return errorResponse('Error patching case: ' + ex.getMessage());
    }
}

@httpdelete
global static ApiResponse deleteCase(){
    String caseId = extractIdFromUrl();
    
    if(String.isBlank(caseId)){
        RestContext.response.statusCode = 400; // Bad Request
        return errorResponse('Case ID is required in the URL');
    }

    List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Description, Status, Priority,
                   Origin, Type, ContactId, AccountId, CreatedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

    if (cases.isEmpty()) {
            RestContext.response.statusCode = 404;
            return errorResponse('Case not found with Id: ' + caseId);
        }

    Case deleteCaseRecord = cases[0];
    try {
        delete deleteCaseRecord;
        return successResponse(true, 'Case deleted successfully', null);
    } catch (Exception ex) {
        RestContext.response.statusCode = 500;
        return errorResponse('Error deleting case: ' + ex.getMessage());
    }
}

private static string extractIdFromUrl(){
    RestRequest req = RestContext.request;
    String url = req.requestURI;
    String idFromUrl = url.substringAfterLast('/');
    if(idFromUrl == 'case-management'){
        return null; // No ID provided in the URL
    }
    return idFromUrl;
}

private static ApiResponse successResponse(Boolean success, String message, CaseData data){
    return new ApiResponse(success, message, data);
}

private static ApiResponse errorResponse(String message){
    return new ApiResponse(false, message, null);
}
    
 global class ApiResponse{
    public Boolean success;
    public String message;
    public CaseData data;

    public ApiResponse(Boolean success, String message, CaseData data){
        this.success = success;
        this.message = message;
        this.data = data;
    }
 }

 global class CaseData{
    public String caseId;
    public String caseNumber;
    public String status;
    public String priority;
    public String subject;

    public CaseData(){}
    public CaseData (String caseId){
        this.caseId = caseId;
    }
 }

 global class CaseRequest{
    public String subject;
    public String description;
    public String priority;
    public String origin;
 }

}