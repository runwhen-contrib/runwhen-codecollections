** Settings **
Documentation   SLI to check DNS latency for Google Resolver
Library         RW.Core
Library         RW.DNS

** Tasks **
Check DNS latency for Google Resolver
    [Documentation]         Get DNS latency for Google resolver
    Import User Variable    HOSTNAME_TO_RESOLVE
    ${latency_ms} =         Lookup Latency In Milliseconds
    ...                     host=${HOSTNAME_TO_RESOLVE}   nameservers=8.8.8.8
    Debug                   Latency in milliseconds: ${latency_ms}
    Push Metric             ${latency_ms}
