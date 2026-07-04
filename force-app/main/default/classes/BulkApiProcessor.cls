public with sharing class BulkApiProcessor implements Queueable, Database.AllowsCallouts{
   
    private String fileId; //contentDocumentId
    public BulkApiProcessor(String fileId) {
        this.fileId = fileId;
    }

    public void execute(QueueableContext context) {
        
        //get file data
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: fileId and ISlatest = true limit 1];

        if(cv == null){
            throw new BulkAPIException('File Not Found in Content Version');
        }

        //convert Blob data to String
        String csvData = cv.VersionData.toString();

       String result =  bulkAPIOperation(csvData);

       System.debug(result);
    }

    private String bulkAPIOperation(String csvContent){
        try {
           
        //step 1 - create the job
            String jobId = createBulkAPIJob();
        //step 2 - Upload the data
            uploadCSVData(jobId, csvContent);
        //Step 3 - Close the job
             closeBulkAPIJob(jobId);
           return 'BULK API Job Completed Successully';
        } catch (Exception e) {
            throw new BulkAPIException('Bulk API Processing Failed ' + e.getMessage());
        }
    }

    public string createBulkAPIJob(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v64.0/jobs/ingest');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Map<String,String> requestBody = new Map<String,String>{
            'operation' => 'insert',
            'object' => 'Account',
            'lineEnding' => 'CRLF'
        };
        req.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if(res.getStatusCode() !=200 && res.getStatusCode() != 201){
            throw new BulkAPIException('Bulk API Job Creation Failed, ERROR: ' + res.getBody());
        }

        Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        String jobId = (String) resBody.get('id');
        return jobId;
    }

    public void uploadCSVData(String jobId, String csvContent){
         HttpRequest req = new HttpRequest();
          req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v64.0/jobs/ingest/' + jobId + '/batches');
          req.setMethod('PUT');
          req.setHeader('Content-Type', 'text/csv');
          req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
          req.setBody(csvContent);
          Http http = new Http();
          HttpResponse res = http.send(req);
           if(res.getStatusCode() !=200 && res.getStatusCode() != 201){
            throw new BulkAPIException('Bulk API Job Upload Data Failed, ERROR: ' + res.getBody());
        }

    }

    public void closeBulkAPIJob(String jobId){
         HttpRequest req = new HttpRequest();
          req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v64.0/jobs/ingest/' + jobId);
          req.setMethod('PATCH');
          req.setHeader('Content-Type', 'application/json');
          req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
          Map<String,String>  requestBody = new Map<String,String>{
            'state' => 'UploadComplete'
        };
         req.setBody(JSON.serialize(requestBody));
          Http http = new Http();
           HttpResponse res = http.send(req);
           if(res.getStatusCode() !=200 && res.getStatusCode() != 201){
            throw new BulkAPIException('Bulk API Job Close Operation Failed, ERROR: ' + res.getBody());
        }
    }
    
    public class BulkAPIException extends Exception{}
}