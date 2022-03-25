** Settings **
Documentation   Runbook for troubleshooting the RunWhen backend-services workspaces.
Metadata        Name      rw-workspaces-availability
Metadata        Type      Runbook
Metadata        Author    Vui Le
Force Tags      runwhen   troubleshooting   workspace   backend-services   latency   
Suite Setup     Runbook Setup
Suite Teardown  Runbook Teardown
Library         String
Library         RW.Core
Library         RW.HTTP
Library         RW.K8s
Library         RW.Report
Library         RW.Slack
Library         RWP


** Variables **
${MAX_LOGS}         100

** Tasks **
Ping backend-services endpoint
    ${hostname} =    Get Backend Services Hostname
    ${result} =      RW.Core.Ping    ${hostname}    count=10
    Add To Report    Ping result for ${hostname}
    Add To Report    * Packets sent: ${result["packets_transmitted"]}
    Add To Report    * Packets received: ${result["packets_received"]}
    Add To Report    * Packet loss: ${result["packet_loss_percentage"]}%
    Add To Report    ${result["stdout"]}

Create authenticated session with backend-services
    ${status} =      Get Backend Services Authenticated Session
    Add To Report    * backend-services authentication: ${status}

Check backend-services workspaces availability
    Get Backend Services Authenticated Session
    ${res} =         Get Workspaces Info

    Add To Report    Get all available workspaces from backend-services
    Add To Report    * HTTP code: ${res.status_code}
    Add To Report    * Latency: ${res.latency} secs
    Should Be True   ${res.latency} < 1.5   HTTP latency should be less than 1.5 seconds.

Get KBS events
    ${res} =   RW.K8s.kubectl  get options=events --sort-by=.metadata.creationTimestamp -n backend-services
    Add To Report    Recent events in backend-services
    Add To Report    * Command: ${res["command"]}
    Add To Report    * Command exit code: ${res["exit_code"]}
    Add To Report    * stdout: ${res["stdout"]}
    Add To Report    * stderr: ${res["stderr"]}

Get last 100 log entries for KBS Devkit pod
    ${pod_name} =    Get KBS Devkit Pod Name
    Add To Report    *Pod: ${pod_name}*
    
    ${res} =   RW.K8s.kubectl  logs ${pod_name} --tail ${MAX_LOGS}
    Add To Report    Last ${MAX_LOGS} log entries from pod ${pod_name}
    Add To Report    * Command: ${res["command"]}
    Add To Report    * Command exit code: ${res["exit_code"]}
    Add To Report    * stdout: ${res["stdout"]}
    Add To Report    * stderr: ${res["stderr"]}

    ${errors} =      Get Errors From Output   ${res["stdout"]}
    Add To Report    ${errors}

Get kubectl describe for KBS Devkit pod
    ${pod_name} =    Get KBS Devkit Pod Name
    ${res} =         RW.K8s.kubectl  describe pods/${pod_name} --context=k3d-backend-services
    Add To Report    kubectl describe pod ${pod_name}
    Add To Report    ${res["stdout"]}
    ${image} =       Get Pod Image Name From Output   ${res["stdout"]}
    Add To Report    Image: ${image}


** Keywords **
Runbook Setup
    Import User Variable    SLACK_CHANNEL
    Import User Secret      SLACK_BOT_TOKEN

Runbook Teardown
    ${report} =   Get Report
    RW.Slack.Post Message
    ...           token=${SLACK_BOT_TOKEN}
    ...           channel=${SLACK_CHANNEL}
    ...           flag=red
    ...           title=rw-backend-services-workspaces-availability Troubleshooting Report
    ...           msg=${report}

