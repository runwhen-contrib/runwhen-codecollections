Sometimes users have external dependencies that, when not functioning, can generate internal alerts that lead to wasted time chasing down the source of the issue. One such example would be a dependency on GitHub. This sample demonstrates how to interact with GitHub in a way that might help users determine if upstream services are functioning properly. 

This sample codebundle provides two components;
- The SLI: Checks the latency of an API request to GitHub for access to specific repositories
- The Runbook: Creates a GitHub Issue and adds the latency details to the issue

To make this a complete SLX, an SLO would be required to determine what set the ideal latency target and to determine when to execute the Runbook code. While this example demonstrates how to interact with GitHub Repos and Issues, a more normal use case would likely send an alert to Slack ot Teams based on the unavailability of the GitHub API. 
