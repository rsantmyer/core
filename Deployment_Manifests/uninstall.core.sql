SET DEFINE ON
DEFINE APPLICATION_NAME = 'CORE'

PROMPT
PROMPT *******************************************************************
PROMPT WARNING: This uninstall will permanently delete all objects created
PROMPT          by the CORE deployment and lose any registered metadata.
PROMPT          This is not recoverable unless you have a backup.
PROMPT *******************************************************************
PROMPT
ACCEPT confirm CHAR PROMPT 'Type YES to proceed with uninstall, or anything else to abort: '

BEGIN
   IF UPPER('&confirm') != 'YES' THEN
      RAISE_APPLICATION_ERROR(-20000,'Uninstall aborted by user.');
   END IF;
END;
/

COLUMN CURRENT_SCHEMA       new_value CURRENT_SCHEMA      
SELECT sys_context('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA FROM DUAL;

SPOOL uninstall.&&APPLICATION_NAME..&&CURRENT_SCHEMA..log

SET AUTOPRINT ON
SET SERVEROUTPUT ON
SET SQLBLANKLINES ON

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

PROMPT
PROMPT Starting uninstall of CORE deployment objects...
PROMPT

DECLARE
   table_does_not_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT(table_does_not_exist, -942);
   object_does_not_exist  EXCEPTION;
   PRAGMA EXCEPTION_INIT(object_does_not_exist, -4043);
   sequence_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(sequence_does_not_exist, -2289);
   type_does_not_exist    EXCEPTION;
   PRAGMA EXCEPTION_INIT(type_does_not_exist, -4087);
   stmt VARCHAR2(4000);

   PROCEDURE drop_object(p_stmt IN VARCHAR2) IS
   BEGIN
      EXECUTE IMMEDIATE p_stmt;
   EXCEPTION
      WHEN table_does_not_exist
        OR object_does_not_exist
        OR sequence_does_not_exist
        OR type_does_not_exist THEN
         NULL;
      WHEN OTHERS THEN
         RAISE;
   END drop_object;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Dropping package bodies...');
   drop_object('DROP PACKAGE BODY "PKG_APPLICATION"');
   drop_object('DROP PACKAGE BODY "PKG_APP_DICT"');
   drop_object('DROP PACKAGE BODY "PKG_SYSLOG"');
   drop_object('DROP PACKAGE BODY "PKG_STRING"');
   drop_object('DROP PACKAGE BODY "PKG_TRACE"');

   DBMS_OUTPUT.PUT_LINE('Dropping packages...');
   drop_object('DROP PACKAGE "PKG_APPLICATION"');
   drop_object('DROP PACKAGE "PKG_APP_DICT"');
   drop_object('DROP PACKAGE "PKG_SYSLOG"');
   drop_object('DROP PACKAGE "PKG_STRING"');
   drop_object('DROP PACKAGE "PKG_TRACE"');

   DBMS_OUTPUT.PUT_LINE('Dropping standalone procedure...');
   drop_object('DROP PROCEDURE "ASSERT"');

   DBMS_OUTPUT.PUT_LINE('Dropping types...');
   drop_object('DROP TYPE "VARCHAR_TAB" FORCE');
   drop_object('DROP TYPE "NUM_TAB" FORCE');

   DBMS_OUTPUT.PUT_LINE('Dropping tables...');
   drop_object('DROP TABLE "TRACE_LOG" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "SYSTEM_LOG" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_DICTIONARY" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_DEPLOY_PROVENANCE" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_DEPLOY_HIST" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_OBJECT_METADATA" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_SYS_PRIVS" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_OBJ_PRIVS" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_OBJECTS" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_OBJECT_TYPE" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_DEPENDENCY" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_DEPLOY_NOTES" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APPLICATION" CASCADE CONSTRAINTS PURGE');
   drop_object('DROP TABLE "APP_OBJ_NAMESPACE" CASCADE CONSTRAINTS PURGE');

   DBMS_OUTPUT.PUT_LINE('Uninstall complete.');
END;
/

SPOOL OFF
