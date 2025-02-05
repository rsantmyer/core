SET DEFINE ON
DEFINE APPLICATION_NAME = 'CORE'
DEFINE DEPLOY_VERSION_MAJOR = '2'
DEFINE DEPLOY_VERSION_MINOR = '1'
DEFINE DEPLOY_VERSION_PATCH = '0'

SPOOL deploy.&&APPLICATION_NAME.CURR..&1..log

--PRINT BIND VARIABLE VALUES
SET AUTOPRINT ON                    

--DISPLAY DBMS_OUTPUT.PUT_LINE OUTPUT
SET SERVEROUTPUT ON                 

--ALLOW BLANK LINES WITHIN A SQL COMMAND OR SCRIPT
--SET SQLBLANKLINES ON                

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

--Reason Required: version 2 has semantic versioning. Not compatible with version 1
EXEC pkg_application.check_min_app_version_p( ip_application_name => 'CORE', ip_min_major_version => 2, ip_min_minor_version => 0, ip_min_patch_version => 0 );
--
EXEC pkg_application.begin_deployment_p(ip_application_name => '&&APPLICATION_NAME', ip_major_version => &&DEPLOY_VERSION_MAJOR, ip_minor_version => &&DEPLOY_VERSION_MINOR, ip_patch_version => &&DEPLOY_VERSION_PATCH, ip_deployment_type => pkg_application.c_deploy_type_minor);
--SEQUENCES
--TABLES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'APP_DEPLOY_NOTES'  , ip_object_type => pkg_application.c_object_type_table);
--PROCEDURES
--TYPES
--PACKAGE SPECS / PACKAGE BODIES
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_APPLICATION'  , ip_object_type => pkg_application.c_object_type_package);
EXEC pkg_application.add_object_p(ip_application_name => '&&APPLICATION_NAME', ip_object_name => 'PKG_APPLICATION'  , ip_object_type => pkg_application.c_object_type_package_body);
--SYS PRIVS
--EXEC pkg_application.add_sys_priv_p(ip_application_name => '&&APPLICATION_NAME', ip_privilege => 'SELECT ANY DICTIONARY');
--

--Sequences

--Tables
@@../Tables/APP_DEPLOY_NOTES.sql

--Procedures

--Types

--Package Specifications
Prompt Creating Package Specifications
@@../Packages/PKG_APPLICATION.pks

--Package Bodies
Prompt Creating Package Bodies
@@../Packages/PKG_APPLICATION.pkb

--Metadata

EXEC pkg_application.validate_objects_p(ip_application_name => '&&APPLICATION_NAME');
EXEC pkg_application.validate_sys_privs_p(ip_application_name => '&&APPLICATION_NAME');
--
BEGIN
   pkg_application.set_deploy_notes_p
   ( ip_application_name => '&&APPLICATION_NAME'
   , ip_notes => 
Q'{* Add the table APP_DEPLOY_NOTES
* Add pkg_application.get_current_version_f
* Add pkg_application.set_deploy_notes_p}'
   );
END;
/


EXEC pkg_application.set_deployment_complete_p(ip_application_name => '&&APPLICATION_NAME');

SPOOL OFF

