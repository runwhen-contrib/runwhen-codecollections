** Settings **
Documentation   This runbook is used to troubleshoot metric collection. It checks
...             the following:
...             - Check if location exists
...             - Check if location is running
...             - Check if Cortex receives messages from pushgateway
...             - Check if Cortex sees metrics
Metadata        Name      rw-metric-continuity
Metadata        Type      Runbook
Metadata        Author    Vui Le
Force Tags      runwhen   metric   metricstore   metric-collection  troubleshooting   backend-services
Suite Setup     Runbook Setup
Suite Teardown  Runbook Teardown
Library         RW.Core
Library         RW.Report
Library         RW.Slack
Library         RWP

** Variables **
${SESSION}

** Tasks **
Check SLI Status
    ${name} =               Get SLI Name
    Add To Report           * SLI found: ${name}
    Should Not Be Empty     ${name}   SLI name does not exist

Check SLI Location
    ${location} =           Get SLI Location
    Add To Report           * SLI location: ${location}
    Should Not Be Empty     ${location}   SLI location is not defined

Check SLI Running Status
    ${status} =             Get SLI Running Status
    Add To Report           * SLI status: ${status}
    Should Be True          '${status}' == 'Running'   SLI is not running (phase: ${status})
    
Check If Cortex Receives Messages From Pushgateway
    ${result} =             Get Cortex Result
    Add To Report           * Cortex result:
    Add To Report           ${result}    prettify=${true}
    Should Not Be Empty     ${result}    Cortex does not have any result

Check Cortex Metric Collection
    ${metrics} =            Get Metrics From Cortex
    Add To Report           * SLIX metrics:
    Add To Report           ${metrics}   prettify=${true}
    Should Not Be Empty     ${metrics}   Cortex is not receiving metrics
 
** Keywords **
Runbook Setup
    Import User Variable    SLX_NAME
    Import User Variable    SLACK_CHANNEL
    Import User Secret      SLACK_BOT_TOKEN

    ${status} =             Get Backend Services Authenticated Session
    Add To Report           * backend-services authentication: ${status}

Runbook Teardown
    ${report} =   Get Report
    RW.Slack.Post Message
    ...           token=${SLACK_BOT_TOKEN}
    ...           channel=${SLACK_CHANNEL}
    ...           flag=red
    ...           title=rw-metric-continuity Troubleshooting Report
    ...           msg=${report}

