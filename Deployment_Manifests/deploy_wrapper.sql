SET DEFINE ON
SET SHOWMODE OFF
COLUMN CURRENT_SCHEMA       new_value CURRENT_SCHEMA      

SELECT sys_context('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA FROM DUAL;

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

--Set the DEFINE variable for the commit hash. Doing it this way means the commit will be one behind the one in in the repo
DEFINE CORE = 8e8283d198feb2965bd3c0f42401b6d6c7cc464a

ALTER SESSION DISABLE PARALLEL DML;
@./deploy.core.full.sql &CORE

PAUSE Deploy complete. Press RETURN to add a dictionary entry for the environment (Optional)
ACCEPT DEPLOY_ENV    CHAR PROMPT 'Deployment environment (i.e. DEV, TEST, PROD): '
EXEC PKG_APP_DICT.ADD_VAL_P('CORE','DEPLOY_ENVIRONMENT','&&DEPLOY_ENV', 'The deployment environment (i.e. DEV, TEST, PROD)');

SELECT * FROM APP_DICTIONARY;