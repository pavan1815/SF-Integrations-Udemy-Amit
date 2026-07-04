public with sharing class JiraService {
  public static void createIssueFromCase(Case sfCase) {
    HttpRequest req = new HttpRequest();
    req.setEndPoint('callout:Jira/rest/api/3/issue');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Accept', 'application/json');

    //Prepare a request body

    JiraIssueRequest reqBody = new JiraIssueRequest();
    reqBody.fields = new JiraIssueRequest.JiraFields();
    reqBody.fields.summary = sfCase.Subject;
    reqBody.fields.project = new JiraIssueRequest.JiraProject();
    reqBody.fields.project.Key = 'KAN';
    reqBody.fields.issuetype = new JiraIssueRequest.JiraIssueType();
    reqBody.fields.issuetype.name = 'Task';
    reqBody.fields.priority = new JiraIssueRequest.JiraPriority();
    reqBody.fields.priority.name = sfCase.Priority;

    //Apex -> JSON
    req.setBody(JSON.serialize(reqBody));

    //Create HTTP instance
    Http http = new Http();
    Httpresponse response = http.send(req);

    if (response.getStatusCode() == 201) {
      //JSON -> APEX
      JiraIssueResponse parseResponse = (JiraIssueResponse) JSON.deserialize(
        response.getBody(),
        JiraIssueResponse.class
      );
      System.debug('Id of created Issue ' + parseResponse.id);
    }
  }
}
