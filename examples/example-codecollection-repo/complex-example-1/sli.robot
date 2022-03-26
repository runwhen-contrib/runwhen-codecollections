*** Settings ***
Documentation	    Simple CRUD tests for SLI configuration
...
Library		    rwkeywords/Base.py
Library		    rwkeywords/Rest.py
Library		    String

Suite Setup	    My Suite Setup
Suite Teardown      My Suite Teardown


*** Variables ***
${WORKSPACE_NAME}		test-sli-simple-crud-s1

*** Keywords ***
My Suite Setup
  ${ln}		              Get Setting     DEFAULT_LOCATION_NAME
  Set Suite Variable	      ${LOCATION_NAME}	${ln}
  Log To Console		    ------------------------------------------------------------------------------
  Log To Console		    Sli-crud Suite Setup, variables sanity check:
  Log To Console		    WORKSPACE_NAME=${WORKSPACE_NAME}
  Log To Console		    LOCATION_NAME=${LOCATION_NAME}
  Log To Console		    Recreating workspace...
  Teardown Workspace		  ${WORKSPACE_NAME}
  Init Default Workspace	${WORKSPACE_NAME}
  Log To Console        Checking default workspace exists...
  Log To Console        Get Content     '/api/v3/workspaces/${WORKSPACE_NAME}'
  Log To Console		    ------------------------------------------------------------------------------

My Suite Teardown
  Log To Console		    ------------------------------------------------------------------------------
  ${tests_passed}=		    Get Suite Results		PASSED	
  ${tests_failed}=		    Get Suite Results		FAILED
  ${rate}=			    Evaluate			${tests_passed} / (${tests_passed} + ${tests_failed})
  Push Metric			    ${rate}	                build_number=${build}
  ...								env=${env_hash}
  ...								cluster=${cluster}
  Log To Console		    ------------------------------------------------------------------------------

*** Test Cases ***
Hello World
  Log				Hello World!

Replace SLI Config with Known Good Config
  Reset Session Branch
  ${slx_name}                   Set Variable    test-sli-goodconfig-slx
  Create Draft Slx		          ${slx_name}     workspace_name=${WORKSPACE_NAME}
  ${wys}=                       Load Template   sli-min-template.yaml
  ...						                                workspace_name=${WORKSPACE_NAME}
  ...						                                slx_name=${slx_name}
  ${body}=                      Evaluate        {'file':$wys}
  ${rsp}=                       POST            /api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml         ${body}
  ${rsp}=                       GET Content     /api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml
  Should Be Equal               ${rsp['file']}     ${wys}
  [TEARDOWN]                    Reset Session Branch

Replace SLI Config with Known Bad Config
  Reset Session Branch
  ${slx_name}                   Set Variable    test-sli-badconfig-slx
  Create Draft Slx              ${slx_name}
  ${wys}=                       Load Template   sli-bad-codebundle-template.yaml
  ...                                           workspace_name=${WORKSPACE_NAME}
  ...                                           slx_name=${slx_name}
  ${body}=                      Evaluate        {'file':$wys}
  ${rsp}=                       POST 422        /api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml        ${body}
  Should Contain                ${rsp.text}     spec.codeBundle      #Err msg should be specific
  [TEARDOWN]                    Reset Session Branch

CRUD Draft SLI With Session Branch
  Reset Session Branch
  ${slx_name}                   Set Variable    test-sli-slx
  Create Draft Slx              ${slx_name}
  ${rsp}=                       POST		    /api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml    expect_status_codes=201
  ${rsp}=                      	GET		      /api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml
  Log                           ${rsp.content}
  ${rsp}=                       DELETE     	/api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml
  ${rsp}=                       GET 404    	/api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml
  [TEARDOWN]                    Reset Session Branch		${WORKSPACE_NAME}

CRUD Draft SLI With Custom Branch
  Reset Session Branch		
  ${slx_name}                   Set Variable    test-sli-slx-cbr
  ${br}                         Set Variable    newbranch
  ${rsp}=                       POST            /api/v3/workspaces/${WORKSPACE_NAME}/branches/${br}/slxs/${slx_name}/slx.yaml    expect_status_codes=201
  ${rsp}=                       POST            /api/v3/workspaces/${WORKSPACE_NAME}/branches/${br}/slxs/${slx_name}/sli.yaml    expect_status_codes=201
  ${rsp}=                       GET             /api/v3/workspaces/${WORKSPACE_NAME}/branches/${br}/slxs/${slx_name}/sli.yaml
  #Make sure none of this slipped out to production
  ${rsp}=                       GET 404         /api/v3/workspaces/${WORKSPACE_NAME}/slxs/${slx_name}
  ${rsp}=                       GET 404         /api/v3/workspaces/${WORKSPACE_NAME}/slxs/${slx_name}/sli
  #Make sure deletes work
  ${rsp}=                       DELETE          /api/v3/workspaces/${WORKSPACE_NAME}/branches/${br}
  ${rsp}=                       GET 404         /api/v3/workspaces/${WORKSPACE_NAME}/branches/${br}/slxs/${slx_name}/sli.yaml
  [TEARDOWN]                    Reset Session Branch		${WORKSPACE_NAME}

Create SLI and Merge To Prod
  Reset Session Branch	        ${WORKSPACE_NAME}
  ${slx_name}                   Set Variable     test-sli-pprod
  ${sli_yaml}=                  Load Template    sli-min-template.yaml
  ...						                                workspace_name=${WORKSPACE_NAME}
  ...						                                slx_name=${slx_name}
  Create Draft Slx              ${slx_name}
  ...                           workspace_name=${WORKSPACE_NAME}
  ...                           sli_yaml=${sli_yaml}
  ...                           sli_locations=${LOCATION_NAME}
  ${rsp}=                      	GET     /api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml
  ${rsp}=                      	POST    /api/v3/workspaces/${WORKSPACE_NAME}/merge/--
  Log                           Merge to prod response: ${rsp.text}
  Sleep                         3s    Wait for git/corestate/db sync
  #Check to make sure the content exists on the prod branch
  ${rsp}=                      	GET Content     /api/v3/workspaces/${WORKSPACE_NAME}/branches/$PROD/slxs/${slx_name}/sli.yaml
  #Check to make sure the operational state is available
  ${rsp}=                       GET     /api/v3/workspaces/${WORKSPACE_NAME}/slxs/${slx_name}/sli
  ${rsp}=                       GET     /api/v3/workspaces/${WORKSPACE_NAME}/slxs/${slx_name}/sli/ready
  Log                           Production state of the sli is: ${rsp.text}
  #[TEARDOWN]                    Teardown_Slx_And_Reset_Session_Branch    ${slx_name}     ${WORKSPACE_NAME}

Create Prod SLI and Check Recent Values
  Reset Session Branch	        ${WORKSPACE_NAME}
  ${slx_name}                   Set Variable    test-sli-pprod
  ${sli_yaml}=                  Load Template   sli-min-template.yaml
  ...						                                workspace_name=${WORKSPACE_NAME}
  ...						                                slx_name=${slx_name}
  Create Prod Slx               ${slx_name}
  ...                           workspace_name=${WORKSPACE_NAME}
  ...                           sli_yaml=${sli_yaml}
  ...                           sli_locations=${LOCATION_NAME}
  Sleep                         10s    Wait for the first metrics to start flowing
  ${rsp}=                       GET Content     /api/v3/workspaces/${WORKSPACE_NAME}/slxs/${slx_name}/sli/recent
  Log                           /sli/recent was ${rsp}
  #[TEARDOWN]                    Teardown_Slx_And_Reset_Session_Branch    ${slx_name}     ${WORKSPACE_NAME}


Delete SLX draft also deletes SLI
  Reset Session Branch
  ${slx_name}                   Set Variable    test-sli-slx-delete
  ${sli_yaml}=                  Load Template   sli-min-template.yaml
  ...						                                workspace_name=${WORKSPACE_NAME}
  ...						                                slx_name=${slx_name}
  Create Draft Slx              ${slx_name}
  ...                           sli_yaml=${sli_yaml}
  ...                           sli_locations=${LOCATION_NAME}
  ${dys}=                     	GET Content	/api/v3/workspaces/${WORKSPACE_NAME}/branches/--/slxs/${slx_name}/sli.yaml
  ${rsp}=                       DELETE     	/api/v3/workspaces/${workspace_name}/branches/--/slxs/${slx_name}
  ${rsp}=                       GET 404    	/api/v3/workspaces/${workspace_name}/branches/--/slxs/${slx_name}
  ${rsp}=                       GET 404    	/api/v3/workspaces/${workspace_name}/branches/--/slxs/${slx_name}/slx.yaml
  ${rsp}=                       GET 404    	/api/v3/workspaces/${workspace_name}/branches/--/slxs/${slx_name}/sli.yaml
  [TEARDOWN]			              Teardown Slx and Reset Session Branch	${slx_name}
