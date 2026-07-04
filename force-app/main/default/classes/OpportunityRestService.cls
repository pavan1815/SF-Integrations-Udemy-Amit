@RestResource(urlMapping='/opportunities')
global with sharing class OpportunityRestService {

    @httpPatch
    global static ResponseWrapper patchOpportunity(PatchRequestWrapper requestBody){
            RestRequest req = RestContext.request;
            String opportunityId = req.params.get('id');

        // Validate that an Id was provided
        if (String.isBlank(opportunityId)) {
            RestContext.response.statusCode = 400;
            return new ResponseWrapper(false, 'Opportunity Id is required as a query parameter (?id=...).', null);
        }

        // Validate that the Id is a valid Salesforce Id

         List<Opportunity> existingOpps = [
            SELECT Id, Name, StageName, CloseDate, Amount, Description
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        if (existingOpps.isEmpty()) {
            RestContext.response.statusCode = 404;
            return new ResponseWrapper(false, 'Opportunity not found with Id: ' + opportunityId, null);
        }

        Opportunity oppToUpdate = existingOpps[0];
        oppToUpdate.stageName = requestBody.StageName;
        oppToUpdate.amount = requestBody.Amount;
        
        try {
            update oppToUpdate;
            return new ResponseWrapper(true, 'Opportunity updated successfully.', oppToUpdate.Id);
        } catch (DmlException e) {
            RestContext.response.statusCode = 500;
            return new ResponseWrapper(false, 'Error updating Opportunity: ' + e.getMessage(), null);
        }

    }

    global class PatchRequestWrapper {
        public String StageName;
        public Decimal Amount;
    }

    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public String recordId;

        //constructor
        public ResponseWrapper(Boolean success, String message, String recordId) {
            this.success = success;
            this.message = message;
            this.recordId = recordId;
        }
    }
}