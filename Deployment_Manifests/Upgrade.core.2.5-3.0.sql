SET DEFINE ON
DEFINE APPLICATION_NAME = 'CORE'
DEFINE DEPLOY_VERSION_MAJOR = '3'
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

EXEC pkg_application.check_min_app_version_p( ip_application_name => 'CORE', ip_min_major_version => 2, ip_min_minor_version => 5, ip_min_patch_version => 0 );
--
EXEC pkg_application.begin_deployment_p(ip_application_name => '&&APPLICATION_NAME', ip_major_version => &&DEPLOY_VERSION_MAJOR, ip_minor_version => &&DEPLOY_VERSION_MINOR, ip_patch_version => &&DEPLOY_VERSION_PATCH, ip_deployment_type => pkg_application.c_deploy_type_major);
--
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'SYSTEM_LOG'  , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_SYSLOG'  , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_SYSLOG'  , ip_object_type => pkg_application.c_object_type_package_body);

BEGIN
   pkg_application.set_deploy_notes_p
   ( ip_application_name => '&&APPLICATION_NAME'
   , ip_notes => 
Q'{3.0.0
* Add table SYSTEM_LOG
* Add pkg_syslog
* drop pkg_error_util
* drop table error_log
}'
   );
END;
/


--Tables
Prompt Deploying tables
@@../Tables/SYSTEM_LOG.sql 

--Package Specifications
Prompt Creating Package Specifications
@@../Packages/PKG_SYSLOG.pks

--Package Bodies
Prompt Creating Package Bodies
@@../Packages/PKG_SYSLOG.pkb

EXEC pkg_application.drop_and_forget_object_p(ip_object_name => 'PKG_ERROR_UTIL'  , ip_object_type => pkg_application.c_object_type_package_body);
EXEC pkg_application.drop_and_forget_object_p(ip_object_name => 'PKG_ERROR_UTIL'  , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.drop_and_forget_object_p(ip_object_name => 'ERROR_LOG'       , ip_object_type => pkg_application.c_object_type_table);
EXEC pkg_application.drop_and_forget_object_p(ip_object_name => 'LOG_UID_SEQ'     , ip_object_type => pkg_application.c_object_type_sequence);


EXEC DBMS_UTILITY.COMPILE_SCHEMA(SCHEMA => SYS_CONTEXT('USERENV','CURRENT_SCHEMA'), COMPILE_ALL => FALSE);
--
EXEC pkg_application.validate_objects_p(ip_application_name => '&&APPLICATION_NAME');
EXEC pkg_application.validate_sys_privs_p(ip_application_name => '&&APPLICATION_NAME');
--
EXEC pkg_application.set_deployment_complete_p(ip_application_name => '&&APPLICATION_NAME');

SPOOL OFF

