SET DEFINE ON
SET SHOWMODE OFF
COLUMN CURRENT_SCHEMA       new_value CURRENT_SCHEMA      

SELECT sys_context('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA FROM DUAL;

PAUSE !!!ALL Existing objects will be dropped from this schema!!! If this is correct, press RETURN to continue.

@./_Drop_All_Objects_In_arg1.sql "&&CURRENT_SCHEMA"
@./deploy.core.sql "&&CURRENT_SCHEMA"
