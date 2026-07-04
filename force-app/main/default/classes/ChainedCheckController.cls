public with sharing class ChainedCheckController {
  // Phase 1: First callout — get credit score
  @AuraEnabled(continuation=true cacheable=false)
  public static Object startProcess(String customerId) {
    Continuation con = new Continuation(60);
    con.continuationMethod = 'handleCreditScore';
    con.state = customerId; // pass data to callback

    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:CreditScore_API/v1/score');
    req.setMethod('POST');
    req.setBody('{"customerId":"' + customerId + '"}');
    con.addHttpRequest(req);

    return con;
  }

  // Phase 2: Process first response → start SECOND callout
  @AuraEnabled(cacheable=false)
  public static Object handleCreditScore(List<String> labels, Object state) {
    HttpResponse response = Continuation.getResponse(labels[0]);

    Map<String, Object> scoreData = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    String creditScore = String.valueOf(scoreData.get('score'));

    // CHAIN: Return another Continuation instead of final result
    Continuation con2 = new Continuation(60);
    con2.continuationMethod = 'handleInsuranceQuote';
    con2.state = creditScore; // pass score to next callback

    HttpRequest req2 = new HttpRequest();
    req2.setEndpoint('callout:Insurance_API/v1/quote');
    req2.setMethod('POST');
    req2.setBody('{"creditScore":' + creditScore + '}');
    con2.addHttpRequest(req2);

    return con2; // ← Returning Continuation = CHAINING
  }

  // Phase 3: Final callback — return combined result to LWC
  @AuraEnabled(cacheable=false)
  public static Object handleInsuranceQuote(List<String> labels, Object state) {
    HttpResponse response = Continuation.getResponse(labels[0]);
    String creditScore = (String) state; // from previous phase

    Map<String, Object> result = new Map<String, Object>{
      'creditScore' => creditScore,
      'insuranceQuote' => response.getBody()
    };

    return JSON.serialize(result);
  }
}
