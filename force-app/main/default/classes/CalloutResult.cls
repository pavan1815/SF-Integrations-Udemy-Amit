public class CalloutResult {
  public Boolean isSuccess;
  public Integer statusCode;
  public String responseBody;
  public String errorMessage;
  public String requestId;

  public static CalloutResult createJiraIssue(Case c) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:Jira_Cloud/rest/api/3/issue');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(buildBody(c));

    try {
      Http http = new Http();
      HttpResponse res = http.send(req);
      Integer status = res.getStatusCode();

      if (status >= 200 && status < 300) {
        return CalloutResult.success(res);
      } else {
        return CalloutResult.failure(res);
      }
    } catch (CalloutException e) {
      return CalloutResult.exception(e);
    }
  }

  public static CalloutResult success(HttpResponse res) {
    CalloutResult r = new CalloutResult();
    r.isSuccess = true;
    r.statusCode = res.getStatusCode();
    r.responseBody = res.getBody();
    return r;
  }

  public static CalloutResult failure(HttpResponse res) {
    CalloutResult r = new CalloutResult();
    r.isSuccess = false;
    r.statusCode = res.getStatusCode();
    r.responseBody = res.getBody();
    r.errorMessage = parseErrorMessage(res);
    return r;
  }

  public static CalloutResult exception(Exception e) {
    CalloutResult r = new CalloutResult();
    r.isSuccess = false;
    r.statusCode = null;
    r.errorMessage = e.getMessage();
    return r;
  }

  private static String parseErrorMessage(HttpResponse res) {
    try {
      Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      if (body.containsKey('message'))
        return (String) body.get('message');
      if (body.containsKey('error'))
        return (String) body.get('error');
      if (body.containsKey('errorMessages'))
        return String.valueOf(body.get('errorMessages'));
    } catch (Exception e) {
      return res.getBody();
    }
    return 'Unknown error: ' + res.getStatusCode();
  }
}
