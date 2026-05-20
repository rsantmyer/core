PROMPT Deploy <my_app> applications (MAIN)...

COLUMN CURRENT_SCHEMA       new_value CURRENT_SCHEMA      
SELECT sys_context('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA FROM DUAL;

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

--Set the DEFINE variables for the commit hashes
@./env.sql
DEFINE;

--PAUSE Delete <my_app> applications in current schema ( &&CURRENT_SCHEMA ) and reinstall...
--EXEC PKG_APPLICATION.delete_system_p;

SET ECHO OFF
--
ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL DDL;
--
@../utl_interval/Deployment_Manifests/1.0.0/deploy.sql &UTL_INTERVAL
@../UTL_METADATA_SCRIPT/Deployment_Manifests/1.0.0/deploy.sql &UTL_METADATA_SCRIPT
@../job_control/Deployment_Manifests/1.0.0/deploy.sql &JOB_CONTROL
@../my_app/Deployment_Manifests/1.0.0/deploy.sql &MY_APP --depends on UTL_INTERVAL, UTL_METADATA_SCRIPT and JOB_CONTROL

PAUSE Deploy complete. Press RETURN to compile invalid objects.

PROMPT Compiling invalid application schema objects...
EXEC DBMS_UTILITY.COMPILE_SCHEMA(SCHEMA => SYS_CONTEXT('USERENV','CURRENT_SCHEMA'), COMPILE_ALL => FALSE);

SELECT OBJECT_NAME, OBJECT_TYPE FROM USER_OBJECTS WHERE STATUS = 'INVALID';
