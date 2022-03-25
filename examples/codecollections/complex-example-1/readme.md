While most of the time we (strongly) recommend to put involved logic in to python or java and then import it as a simple set of robot keywords, there are times when it is simply more readable to show a sequence of events.  The files here show examples.

You may also see that while most SLIs are simply pulling metrics from Datadog, Cloudwatch, GCP Ops Suite, Sysdig, Elastic, Nagios or similar, we have found a lot of use in turning some longer sequences in to SLIs to serve like synthetic tests.  (See sli.robot.)
