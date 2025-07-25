SET DEFINE ON
DEFINE APPLICATION_NAME = 'CORE'

SPOOL reset.&&APPLICATION_NAME..&1..log

--PRINT BIND VARIABLE VALUES
SET AUTOPRINT ON                    

--DISPLAY DBMS_OUTPUT.PUT_LINE OUTPUT
SET SERVEROUTPUT ON                 

--ALLOW BLANK LINES WITHIN A SQL COMMAND OR SCRIPT
SET SQLBLANKLINES ON                

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

--Procedures
Prompt Creating Procedures
@@../Procedures/Assert.prc.sql

--Types
Prompt Creating Types
@@../Types/NUM_TAB.sql
@@../Types/VARCHAR_TAB.sql

--Package Specifications
Prompt Creating Package Specifications
@@../Packages/PKG_APPLICATION.pks
@@../Packages/PKG_APP_DICT.pks
@@../Packages/PKG_TRACE.pks
@@../Packages/PKG_SYSLOG.pks
@@../Packages/PKG_STRING.pks

--Package Bodies
Prompt Creating Package Bodies
@@../Packages/PKG_APPLICATION.pkb
@@../Packages/PKG_APP_DICT.pkb
@@../Packages/PKG_TRACE.pkb
@@../Packages/PKG_SYSLOG.pkb
@@../Packages/PKG_STRING.pkb

--Metadata
Prompt Deploying Metadata
@@../Metadata/APP_OBJ_NAMESPACE
@@../Metadata/APP_OBJECT_TYPE


SPOOL OFF

