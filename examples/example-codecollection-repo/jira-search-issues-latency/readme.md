Sometimes users have external dependencies that, when not functioning, can generate internal alerts that lead to wasted time chasing down the source of the issue. One such example would be a dependency on Jira. This sample demonstrates how to interact with Jira in a way that might help users determine if upstream services are functioning properly. 

This sample codebundle provides two components;
- The SLI: Checks the latency of a search request in Jira issues
- The Runbook: Creates a Jira Issue and adds the latency details to the issue

To make this a complete SLX, an SLO would be required to determine what set the ideal latency and to determine when to execute the Runbook code. While this example demonstrates how to interact with Jira issues, a more normal use case would likely send an alert to Slack ot Teams based on the unavailability or violation of the Jira search functionality. 
