# Sample CodeCollection

## TL;DR
Start with the simple-codebundle-X directories, then a few tactical examples, and eventually the complex-codebundle.


## Key Vocabulary

### Codebundle
A codebundle is, loosely speaking, a directory in the codecollection repository where one or more of an sli.robot, runbook.robot, queries.yaml (used for SLOs) or openslo.yaml can be found.  The code in these codebundles requires configuration to run on the RunWhen platform, e.g. the locations where the code should be run, the frequency, config needed (more on that below), etc.  If you look at the sample-workspace readme file and some of those sli.yaml, slo.yaml and runbook.yaml files, you'll see that a Workspace represents configuration while a CodeCollection represents source code.

### Robot Files
Robot Framework (https://robotframework.org/) is a mature, open source low-code language whose origins are in software QA.  There are approximately 41k people on LinkedIn who site Robot Framework on their profiles, and 200+ major open source robot libraries from various contributors.  While it is nominally a 'low code' language, its popularity is partly due to its construction as a wrapper language.  The 'keywords' that show up in a robot scripts are simply names of python, java and (roadmap) golang functions that are imported at the of the robot script.  Logic requiring loops or conditionals typically resides in these more expressive languages, leaving the robot script very easy to read.  The execution order of a Robot Framework script is entirely linear: the suite setup is run, each task is run to completion or exception, the suite teardown is run.  This simplicity lends itself to very easy sharing across teams and organizations.

### Supporting Files
While the platform will inject the "RW" keyword libraries with Robot keywords that are commonly used, developers who want to write keywords in python accomplish this by adding .py files in the same directory as the .robot file, and then importing the file using the robot "Library" directive.  You can see a few examples of that in this directory.  As these python files may themselves have pypi dependencies, a requirements.txt file can also be put in the codebundle directory.  (The platform currently uses pip3 to parse requirements.text and build it, though both poetry for .toml and .lock files as well as conda options are under investigation.)  Typically resource or configuration files would *not* be found in these codebundle directories as any parameters required for configuration would, in practice, come from an sli.yaml or robot.yaml file in a workspace.

### Locations
RunWhen has the concept of locations. A location either be public (managed by RunWhen in the public cloud), or private (post-beta, running in a customers VPC or on-prem location). Locations are the execution environment for SLI and Runbook code, enabling customers execute these tasks in secure environments. 
