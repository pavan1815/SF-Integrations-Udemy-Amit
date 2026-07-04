// Request structure for creating a Jira issue
public class JiraIssueRequest {
  public JiraFields fields;

  public class JiraFields {
    public JiraProject project;
    public String summary;
    public JiraIssueType issuetype;
    public JiraPriority priority;
  }

  public class JiraProject {
    public String key; // e.g., "DEV"
  }

  public class JiraIssueType {
    public String name; // "Bug", "Task", "Story"
  }

  public class JiraPriority {
    public String name; // "High", "Medium", "Low"
  }
}
