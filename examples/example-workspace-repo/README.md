# Sample Workspace

## Key Vocabulary

### SLX
An SLX visually is a point on the SRE map, and semantically is a bundle of configuration and references to code for an SLI, SLO, Runbook and Hook.  Each of these four elements are optional, e.g. you could have a point on the map that has an SLI and SLO but is used for monitoring only, or a point that has only a Runbook and is used for triage that is not yet automated with an SLI/SLO.

#### SLI (Service Level Indicator)
An SLI in this context is the code responsible for capturing a metric for the RunWhen platform.  In our map, 70%+ of these come from our other monitoring systems (GCP Operations Suite and Prometheus).  Around 30% (ish) of our SLIs are more external, e.g. one that pings our domains every minute from a few different locations around the world and reports on round trip time or our SLIs that look like synthetic tests where we CRUD a Workspace with SLXs to simulate a new user every 10 minutes.  In a Workspace repo, you'll find slis represented by an sli.yaml file.  This represents the configuration that goes in to running SLI code, including very critically a codebundle sr that indicates the git repo where source code can be found.  This mirror git repository is called a 'CodeCollection' code repository, and while it may be the same repo as the Workspace most often they are different as codebundles are typically re-used across mny SLXs and are most often public while Workspaces are nearly always private.  On close examination of an sli.yaml file, you'll typically see the codebundle sr point to a CodeCollection repo that has a corresponding sli.robot (likely more generic than an SLX, and used across many).

#### SLO (Service Level Objective)
An SLO is a bundle of queries and alerting rules.  Our internal data model is the OpenSLO Spec and a set of alerting rules that follow the Google SRE book's multi-window-multi-burn approach.  We expose these today in a highly opinionated/simplified format ('simple slo spec' which you can see in queries.yaml), and will soon expose the OpenSLO spec and accompanying alerting spec.  (Nobody has asked.)

#### Runbook
A Runbook is a series of automated steps that is intended to either be run one at a time by a human, all at once by a machine, or some combination of the two.  (Many of our runbook steps are human steps now that we expect to move to machine-triggered over time.)  Similar to sli.robot, the codebundle resource here points to a CodeCollection with a runbook.robot file.

#### Hook
A Hook, short for webhook listener, configures the glue between SLO Alerts and Runbooks.  ('If the SLO goes red, run these 6 tasks in the Workbook but not Tasks 7 and 8'.)  While hooks by default listen for SLO Alerts from RunWhen, they can also serve as general webhook endpoints for other systems that generate alerts that you want to connect with RunWhen Runbooks.  There is some pragmatic logic that goes in to the hook implementation for creating sessions that span multiple runs of multiple runbooks, creating aliases for those sessions that map to the primary key in other systems (typically incident response systems' incident identifiers) and deduplicating runbook steps requested in the session to simplify the integration with other systems that may webhook many times in ways that create DOS risks for production systems should the runbook steps be run at high rate.


