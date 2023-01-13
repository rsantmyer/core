--
-- PKG_ERROR_UTIL  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY PKG_ERROR_UTIL AS
  
  g_user_error_msg VARCHAR2(500);
  g_procedure_name VARCHAR2(100);

   --Public modules

PROCEDURE LogError_p( 
  in_process_name       IN     VARCHAR2 DEFAULT NULL,
  in_module_name        IN     VARCHAR2 DEFAULT NULL,
  in_revision           IN     VARCHAR2 DEFAULT NULL,
  in_severity_level     IN     NUMBER   DEFAULT NULL,
  in_error_code         IN     NUMBER   DEFAULT NULL,
  in_error_message      IN     VARCHAR2 DEFAULT NULL,
  in_reference_info      IN     VARCHAR2 DEFAULT NULL,
  in_task_queue_id      IN     NUMBER   DEFAULT NULL
) IS
      --Declare autonomous pragma
      PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    --Insert the error log record
    INSERT INTO ERROR_LOG
         ( log_uid
         , log_date
         , task_queue_id
         , process_name
         , module_name
         , revision
         , error_code
         , error_message
         , reference_info
         , severity_level
         )
    VALUES
         ( LOG_UID_SEQ.NEXTVAL
         , SYSTIMESTAMP
         , in_task_queue_id
         , TRIM(SUBSTR(in_process_name, 1, 100))
         , TRIM(SUBSTR(in_module_name, 1, 100))
         , in_revision
         , NVL(in_error_code, 0)
         , TRIM(SUBSTR(in_error_message, 1, 4000))
         , TRIM(SUBSTR(in_reference_info, 1, 4000))
         , in_severity_level
         );

    --Commit the transaction
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

  END LogError_p;
  
END PKG_ERROR_UTIL;
/
