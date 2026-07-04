public with sharing class ExchangeRateService {
  private static final String BASE_URL = 'https://open.er-api.com/v6/latest/';
  public static void getLatestRates(String baseCurrency) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(BASE_URL + baseCurrency.toUpperCase());
    req.setMethod('GET');
    req.setHeader('Accept', 'application/json');
    req.setTimeout(15000);

    Http http = new Http();

    HttpResponse res = http.send(req);

    if (res.getStatusCode() != 200) {
      System.debug(
        'ExchangeRateService: Failed to get rates. Status: ' +
        res.getStatusCode()
      );
    }
    if (res.getStatusCode() == 200) {
      System.debug('ExchangeRateService: ' + res.getBody());

      //Parse response as typed approach
      ExchangeRateApexServiceClass parsed = ExchangeRateApexServiceClass.parse(
        res.getBody()
      );
      System.debug('Parsed rates: ' + parsed);
      System.debug(
        'USD: ' +
          parsed.rates.USD +
          ', EUR: ' +
          parsed.rates.EUR +
          ', GBP: ' +
          parsed.rates.GBP
      );

      //parse response as untyped
      Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      String result = (String) root.get('result');
      if (result == 'success') {
        Map<String, Object> rates = (Map<String, Object>) root.get('rates');
        //getting the rates for GBP
        Decimal gbpRate = (Decimal) rates.get('GBP');
        System.debug('GBP rate (untyped): ' + gbpRate);
      }
    }
  }
}
