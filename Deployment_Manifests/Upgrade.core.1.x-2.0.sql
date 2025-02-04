SET DEFINE ON
DEFINE APPLICATION_NAME = 'CORE'
DEFINE DEPLOY_VERSION_MAJOR = '2'
DEFINE DEPLOY_VERSION_MINOR = '0'
DEFINE DEPLOY_VERSION_PATCH = '0'

SPOOL deploy.&&APPLICATION_NAME..&1..log

--PRINT BIND VARIABLE VALUES
SET AUTOPRINT ON                    

--DISPLAY DBMS_OUTPUT.PUT_LINE OUTPUT
SET SERVEROUTPUT ON                 

--ALLOW BLANK LINES WITHIN A SQL COMMAND OR SCRIPT
--SET SQLBLANKLINES ON                

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

--Table Alters
Prompt Altering tables
@@../Tables/APPLICATION.alter.2.0.sql 
@@../Tables/APP_DEPENDENCY.alter.2.0.sql
@@../Tables/APP_DEPLOY_HIST.alter.2.0.sql
@@../Tables/APP_OBJECTS.alter.2.0.sql

--Package Specifications
Prompt Creating Package Specifications
@@../Packages/PKG_APPLICATION.pks

--Package Bodies
Prompt Creating Package Bodies
@@../Packages/PKG_APPLICATION.pkb


ALTER TABLE APPLICATION DROP COLUMN VERSION;
--app_dependency: no columns to DROP
ALTER TABLE APP_DEPLOY_HIST DROP COLUMN VERSION;
ALTER TABLE APP_OBJECTS DROP COLUMN VERSION;


--since we just created them, let's do begin and end deployment here, so it is tracked.
SET DEFINE ON
EXEC pkg_application.begin_deployment_p(ip_application_name => '&&APPLICATION_NAME', ip_major_version => &&DEPLOY_VERSION_MAJOR, ip_minor_version => &&DEPLOY_VERSION_MINOR, ip_patch_version => &&DEPLOY_VERSION_PATCH, ip_deployment_type => pkg_application.c_deploy_type_major);
--SEQUENCES
--TABLES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APPLICATION'      , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_DEPENDENCY'   , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_DEPLOY_HIST'      , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_OBJECTS'      , ip_object_type => pkg_application.c_object_type_table);
--
EXEC pkg_application.validate_objects_p(ip_application_name => '&&APPLICATION_NAME');
EXEC pkg_application.validate_sys_privs_p(ip_application_name => '&&APPLICATION_NAME');
--
EXEC pkg_application.set_deployment_complete_p(ip_application_name => '&&APPLICATION_NAME');

SPOOL OFF

