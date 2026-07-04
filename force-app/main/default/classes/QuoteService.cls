public with sharing class QuoteService {
  public static void getQuotes(String category) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:API_Ninjas' +
        '/v2/quotes?categories=' +
        EncodingUtil.urlEncode(category, 'UTF-8')
    );
    String endpoint =
      'callout:API_Ninjas/' +
      '/v2/quotes?categories=' +
      EncodingUtil.urlEncode(category, 'UTF-8');
    System.debug(endpoint);
    req.setMethod('GET');
    req.setHeader('Accept', 'application/json');
    req.setTimeout(15000);

    Http http = new Http();
    HttpResponse res = http.send(req);
    // System.debug('res.getStatusCode() ' + res.getStatusCode());
    // System.debug('res.getBody() ' + res.getBody());
    if (res.getStatusCode() == 200) {
      List<Object> objectList = (List<Object>) JSON.deserializeUntyped(
        res.getBody()
      );

      for (Object obj : objectList) {
        Map<String, Object> quoteMap = (Map<String, Object>) obj;
        String quoteFromNinja = (string) quoteMap.get('quote');
        System.debug('quoteFromNinja ' + quoteFromNinja);
      }
    }
  }
}
