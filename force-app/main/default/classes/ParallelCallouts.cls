public with sharing class ParallelCallouts {
  @AuraEnabled(continuation=true cacheable=false)
  public static Object runAllChecks(String customerId) {
    Continuation con = new Continuation(120);
    con.continuationMethod = 'handleAllResponses';

    // Request 1: Credit check
    HttpRequest creditReq = new HttpRequest();
    creditReq.setEndpoint('callout:CreditCheck_API/v1/check');
    creditReq.setMethod('POST');
    creditReq.setBody('{"customerId":"' + customerId + '"}');
    con.addHttpRequest(creditReq);

    // Request 2: Fraud screen
    HttpRequest fraudReq = new HttpRequest();
    fraudReq.setEndpoint('callout:FraudScreen_API/v1/screen');
    fraudReq.setMethod('POST');
    fraudReq.setBody('{"customerId":"' + customerId + '"}');
    con.addHttpRequest(fraudReq);

    // Request 3: Compliance
    HttpRequest complianceReq = new HttpRequest();
    complianceReq.setEndpoint('callout:Compliance_API/v1/verify');
    complianceReq.setMethod('POST');
    complianceReq.setBody('{"customerId":"' + customerId + '"}');
    con.addHttpRequest(complianceReq);

    return con; // All 3 fire SIMULTANEOUSLY
  }

  @AuraEnabled(cacheable=false)
  public static Object handleAllResponses(List<String> labels, Object state) {
    // labels[0] → credit response
    // labels[1] → fraud response
    // labels[2] → compliance response

    HttpResponse creditResp = Continuation.getResponse(labels[0]);
    HttpResponse fraudResp = Continuation.getResponse(labels[1]);
    HttpResponse complianceResp = Continuation.getResponse(labels[2]);

    Map<String, Object> results = new Map<String, Object>{
      'credit' => JSON.deserializeUntyped(creditResp.getBody()),
      'fraud' => JSON.deserializeUntyped(fraudResp.getBody()),
      'compliance' => JSON.deserializeUntyped(complianceResp.getBody())
    };

    return JSON.serialize(results);
  }
}
