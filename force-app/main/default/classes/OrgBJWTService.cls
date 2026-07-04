public with sharing class OrgBJWTService {
  public static void getAccounts() {
    HttpRequest req = new HttpRequest();
    req.setMethod('GET');
    req.setHeader('Accept', 'application/json');
    String query = 'SELECT Id, Name, Industry FROM Account LIMIT 10';
    req.setEndpoint(
      'callout:OrgB_JWT/services/data/v66.0/query/?q=' +
      EncodingUtil.urlEncode(query, 'UTF-8')
    );

    Http http = new Http();
    HttpResponse res = http.send(req);
    System.debug('Response Code ' + res.getStatusCode());
    System.debug('Response Body ' + res.getBody());
    if (res.getStatusCode() == 200) {
      Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );

      List<Object> resultList = (List<Object>) result.get('records');
      System.debug('result ' + resultList);
    }
  }
}
