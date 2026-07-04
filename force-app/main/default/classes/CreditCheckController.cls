public with sharing class CreditCheckController {
  // Phase 1: Start the Continuation
  @AuraEnabled(continuation=true cacheable=false)
  public static Object startCreditCheck(String customerId) {
    Continuation con = new Continuation(60);
    con.continuationMethod = 'handleResponse';

    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:CreditCheck_API/v1/check');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(
      JSON.serialize(new Map<String, Object>{ 'customerId' => customerId })
    );

    con.addHttpRequest(req);
    return con;
  }

  // Phase 2: Process the response (called by Salesforce automatically)
  @AuraEnabled(cacheable=false)
  public static Object handleResponse(List<String> labels, Object state) {
    HttpResponse response = Continuation.getResponse(labels[0]);

    if (response.getStatusCode() == 200) {
      Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      String decision = (String) parsed.get('decision');
      Integer score = (Integer) parsed.get('score');
      return 'Decision: ' + decision + ' | Score: ' + score;
    }

    throw new AuraHandledException(
      'Credit check failed: HTTP ' + response.getStatusCode()
    );
  }
}
