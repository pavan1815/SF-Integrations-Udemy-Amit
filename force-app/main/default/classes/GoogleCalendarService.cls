public with sharing class GoogleCalendarService {
  private static final String NC_NAME = 'callout:GoogleCalender';

  public static void getUpcomingEvents(Integer maxResults) {
    String now = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    HttpRequest request = new HttpRequest();
    request.setMethod('GET');
    request.setHeader('Accept', 'application/json');
    request.setTimeout(15000);
    request.setEndpoint(
      NC_NAME +
        '/calendar/v3/calendars/primary/events' +
        '?maxResults=' +
        maxResults +
        '&orderBy=startTime' +
        '&singleEvents=true'
    );

    Http http = new Http();
    HttpResponse res = http.send(request);
    if (res.getStatusCode() == 200) {
      //System.debug('res.getBody() ' + res.getBody());
      Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      List<Object> items = (List<Object>) result.get('items');

      if (items != null) {
        for (Object item : items) {
          Map<String, Object> event = (Map<String, Object>) item;
          System.debug(
            'Event: ' +
              event.get('summary') +
              ' | Start: ' +
              event.get('start') +
              ' | Status: ' +
              event.get('status')
          );
        }
      }
      System.debug('Total events: ' + (items != null ? items.size() : 0));
    }
  }
}
