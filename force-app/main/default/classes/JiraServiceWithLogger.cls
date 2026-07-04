public with sharing class JiraServiceWithLogger {
  private static final String INTEGRATION = 'Jira';
  private static final String NC = 'callout:Jira_Cloud';

  public static CalloutResult createIssue(Case c) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(NC + '/rest/api/3/issue');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(buildBody(c));
    req.setTimeout(30000);

    Long startTime = DateTime.now().getTime();

    try {
      Http http = new Http();
      HttpResponse res = http.send(req);
      Long duration = DateTime.now().getTime() - startTime;
      Integer status = res.getStatusCode();

      if (status == 201) {
        IntegrationLogger.logSuccess(INTEGRATION, req, res, c.Id, duration);
        return CalloutResult.success(res);
      } else {
        IntegrationLogger.logFailure(
          INTEGRATION,
          req,
          res,
          c.Id,
          'HTTP ' + status,
          0
        );
        return CalloutResult.failure(res);
      }
    } catch (CalloutException e) {
      IntegrationLogger.logFailure(
        INTEGRATION,
        req,
        null,
        c.Id,
        e.getMessage(),
        0
      );
      return CalloutResult.exception(e);
    }
  }
}
