public with sharing class IntegrationLogger {
  public static void logSuccess(
    String integration,
    HttpRequest req,
    HttpResponse res,
    Id recordId,
    Long durationMs
  ) {
    insert new Integration_Log__c(
      Integration_Name__c = integration,
      Direction__c = 'Outbound',
      Endpoint__c = req.getEndpoint(),
      HTTP_Method__c = req.getMethod(),
      Request_Body__c = truncate(req.getBody()),
      Response_Body__c = truncate(res.getBody()),
      Status_Code__c = res.getStatusCode(),
      Status__c = 'Success',
      Related_Record_Id__c = recordId,
      Timestamp__c = DateTime.now(),
      Duration_ms__c = durationMs
    );
  }

  public static void logFailure(
    String integration,
    HttpRequest req,
    HttpResponse res,
    Id recordId,
    String errorMsg,
    Integer retryCount
  ) {
    insert new Integration_Log__c(
      Integration_Name__c = integration,
      Direction__c = 'Outbound',
      Endpoint__c = req.getEndpoint(),
      HTTP_Method__c = req.getMethod(),
      Request_Body__c = truncate(req.getBody()),
      Response_Body__c = res != null ? truncate(res.getBody()) : null,
      Status_Code__c = res != null ? res.getStatusCode() : null,
      Status__c = retryCount > 0 ? 'Retrying' : 'Failed',
      Error_Message__c = errorMsg,
      Related_Record_Id__c = recordId,
      Retry_Count__c = retryCount,
      Timestamp__c = DateTime.now()
    );
  }

  private static String truncate(String input) {
    if (input == null)
      return null;
    return input.length() > 131072 ? input.substring(0, 131072) : input;
  }
}
