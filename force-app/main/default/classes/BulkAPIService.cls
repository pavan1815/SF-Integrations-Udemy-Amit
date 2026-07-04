public with sharing class BulkAPIService {
    
    @AuraEnabled
    public static string processFileWithBulkAPI(String fileId){
        System.enqueueJob(new BulkApiProcessor(fileId));
        return 'File Upload Successfully';
    }
}