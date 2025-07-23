CREATE OR REPLACE PACKAGE BODY PKG_SYSLOG AS

  -- =========================================================================
  -- Public Procedures and Functions
  -- =========================================================================
    
/**
 * @description Procedure to write a generic log message.
 * @param p_message The main information logged. If called from within an exception handler,
 * and no message is provided, populate with DBMS_UTILITY.format_error_stack.
 * @param p_log_level The severity of the log entry. 
 * 0:FATAL, 1:ALERT, 2:CRITICAL, 3:ERROR, 4:WARNING, 5:NOTICE, 6:INFO, 7:DEBUG
 * @param p_module The application, package, or procedure that generated the log.
 * If not provided, defaults to SYS_CONTEXT('USERENV', 'MODULE')).
 * @param p_process_name The name of the application, batch job, or system process 
 * that generated the log entry.
 * @param p_error_code A specific code (e.g., ORA-00942) associated with the error. 
 * If called from within an exception handler, and no value is provided, populate with SQLCODE
 * @param p_run_id If run from a scheduler, the scheduler run_id
 */
  PROCEDURE WRITE(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_log_level    IN SYSTEM_LOG.LOG_LEVEL%TYPE    DEFAULT C_NOTICE
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_sql_code       NUMBER;
    l_error_message  SYSTEM_LOG.MESSAGE%TYPE;
    l_reference_info SYSTEM_LOG.REFERENCE_INFO%TYPE;
  BEGIN
    l_sql_code := SQLCODE;
    l_error_message := NVL(DBMS_UTILITY.format_error_stack, SQLERRM);
    l_reference_info := SUBSTR(DBMS_UTILITY.format_error_backtrace, 1, 1000);
    
    INSERT INTO SYSTEM_LOG (
        LOG_LEVEL
      , MESSAGE
      , REFERENCE_INFO
      , PROCESS_NAME
      , MODULE
      , ERROR_CODE
      , CLIENT_INFO
      , OS_USER
      , IP_ADDRESS
      , HOST
      , SCHEDULER_RUN_ID
    ) VALUES (
        p_log_level
      , NVL(p_message, l_error_message)
      , l_reference_info
      , p_process_name
      , NVL(p_module, SYS_CONTEXT('USERENV', 'MODULE'))
      , NVL(p_error_code, l_sql_code)
      , SYS_CONTEXT('USERENV', 'CLIENT_INFO')
      , SYS_CONTEXT('USERENV', 'OS_USER')
      , SYS_CONTEXT('USERENV', 'IP_ADDRESS')
      , SYS_CONTEXT('USERENV', 'HOST')
      , p_run_id
    );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      -- In case of a logging error, we rollback.
      -- The autonomous transaction ensures we don't affect the parent transaction.
      ROLLBACK;
      -- Optionally, you could use DBMS_OUTPUT to show an error during development,
      -- but avoid it in production code.
      -- DBMS_OUTPUT.PUT_LINE('Error logging message: ' || SQLERRM);
      NULL; -- Suppress the error to prevent the calling program from failing.
  END WRITE;

  -- Convenience procedure for FATAL level (0)
  PROCEDURE FATAL(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_FATAL, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END FATAL;

  -- Convenience procedure for ALERT level (1)
  PROCEDURE ALERT(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_ALERT, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END ALERT;

  -- Convenience procedure for CRITICAL level (2)
  PROCEDURE CRITICAL(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_CRITICAL, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END CRITICAL;

  -- Convenience procedure for ERROR level (3)
  PROCEDURE ERROR(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_ERROR, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END ERROR;

  -- Convenience procedure for WARNING level (4)
  PROCEDURE WARNING(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_WARNING, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END WARNING;

  -- Convenience procedure for NOTICE level (5)
  PROCEDURE NOTICE(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_NOTICE, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END NOTICE;

  -- Convenience procedure for INFO level (6)
  PROCEDURE INFO(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_INFO, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END INFO;

  -- Convenience procedure for DEBUG level (7)
  PROCEDURE DEBUG(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  ) IS
  BEGIN
    WRITE(p_message => p_message, p_log_level => C_DEBUG, p_module => p_module, p_process_name => p_process_name, p_error_code => p_error_code, p_run_id => p_run_id);
  END DEBUG;
  
END PKG_SYSLOG;
/
