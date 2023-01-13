SET DEFINE ON
DEFINE APPLICATION_NAME = 'CORE'
DEFINE DEPLOY_VERSION = '1.21'

SPOOL deploy.&&APPLICATION_NAME..&1..log

--PRINT BIND VARIABLE VALUES
SET AUTOPRINT ON                    

--THE START COMMAND WILL LIST EACH COMMAND IN A SCRIPT
REM SET ECHO ON                         

--DISPLAY DBMS_OUTPUT.PUT_LINE OUTPUT
SET SERVEROUTPUT ON                 

--SHOW THE OLD AND NEW SETTINGS OF A SQLPLUS SYSTEM VARIABLE
REM SET SHOWMODE ON                     

--ALLOW BLANK LINES WITHIN A SQL COMMAND OR SCRIPT
--SET SQLBLANKLINES ON                

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

--Sequences
PROMPT Creating Sequences
@@../Sequences/LOG_UID_SEQ.sql

--Tables
Prompt Creating Tables
@@../Tables/ERROR_LOG.sql
@@../Tables/APP_OBJ_NAMESPACE.sql
@@../Tables/APPLICATION.sql
@@../Tables/APP_DEPENDENCY.sql   --Depends on: APPLICATION
@@../Tables/APP_OBJECT_TYPE.sql  --Depends on: APP_OBJ_NAMESPACE
@@../Tables/APP_OBJECTS.sql      --Depends on: APPLICATION, APP_OBJECT_TYPE
@@../Tables/APP_OBJ_PRIVS.sql    --Depends on: APPLICATION
@@../Tables/APP_SYS_PRIVS.sql    --Depends on: APPLICATION
@@../Tables/APP_OBJECT_METADATA.sql --Depends on: APP_OBJECTS
@@../Tables/APP_DEPLOY_HIST.sql
@@../Tables/APP_DICTIONARY.sql
@@../Tables/TRACE_LOG.sql

--Procedures
Prompt Creating Procedures
@@../Procedures/Assert.prc.sql

--Types
Prompt Creating Types
@@../Types/NUM_TAB.sql

--Package Specifications
Prompt Creating Package Specifications
@@../Packages/PKG_ERROR_UTIL.pks
@@../Packages/PKG_APPLICATION.pks
@@../Packages/PKG_APP_DICT.pks
@@../Packages/PKG_TRACE.pks

--Package Bodies
Prompt Creating Package Bodies
@@../Packages/PKG_ERROR_UTIL.pkb
@@../Packages/PKG_APPLICATION.pkb
@@../Packages/PKG_APP_DICT.pkb
@@../Packages/PKG_TRACE.pkb

--Metadata
Prompt Deploying Metadata
@@../Metadata/APP_OBJ_NAMESPACE
@@../Metadata/APP_OBJECT_TYPE

--since we just created them, let's do begin and end deployment here, so it is tracked.
SET DEFINE ON
EXEC pkg_application.begin_deployment_p(ip_application_name => '&&APPLICATION_NAME', ip_version => &&DEPLOY_VERSION, ip_deployment_type => pkg_application.c_deploy_type_initial);
--SEQUENCES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'LOG_UID_SEQ'      , ip_object_type => pkg_application.c_object_type_sequence);
--TABLES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_DEPENDENCY'   , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_OBJ_NAMESPACE', ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_OBJ_PRIVS'    , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_OBJECT_TYPE'  , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_OBJECTS'      , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_OBJECT_METADATA', ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_SYS_PRIVS'    , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APPLICATION'      , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_DEPLOY_HIST'      , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_DICTIONARY'      , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'ERROR_LOG'        , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'TRACE_LOG'      , ip_object_type => pkg_application.c_object_type_table);
--PROCEDURES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'ASSERT'           , ip_object_type => pkg_application.c_object_type_procedure);
--TYPES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'NUM_TAB'          , ip_object_type => pkg_application.c_object_type_type);
--PACKAGE SPECS / PACKAGE BODIES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_ERROR_UTIL'   , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_ERROR_UTIL'   , ip_object_type => pkg_application.c_object_type_package_body);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_APPLICATION'  , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_APPLICATION'  , ip_object_type => pkg_application.c_object_type_package_body);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_APP_DICT'  , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_APP_DICT'  , ip_object_type => pkg_application.c_object_type_package_body);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_TRACE'  , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_TRACE'  , ip_object_type => pkg_application.c_object_type_package_body);
--
EXEC pkg_application.validate_objects_p(ip_application_name => '&&APPLICATION_NAME');
--
EXEC pkg_application.set_deployment_complete_p(ip_application_name => '&&APPLICATION_NAME');

SPOOL OFF

