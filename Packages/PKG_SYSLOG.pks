--
-- PKG_SYSLOG  (Package) 
--
CREATE OR REPLACE PACKAGE PKG_SYSLOG 
AS 

C_FATAL    CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 0;      -- Emergency: System is unusable.
C_ALERT    CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 1;      -- Alert: Action must be taken immediately.
C_CRITICAL CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 2;      -- Critical: Critical conditions. While not immediately catastrophic, needs prompt attention to prevent system failure or further problems.
C_ERROR    CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 3;      -- Error: Error conditions.
C_WARNING  CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 4;      -- Warning: Warning conditions.
C_NOTICE   CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 5;      -- Notice: Normal but significant conditions.
C_INFO     CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 6;      -- Informational: Informational messages.
C_DEBUG    CONSTANT SYSTEM_LOG.LOG_LEVEL%TYPE := 7;      -- Debug: Debugging messages.


  -- Procedure to write a generic log message
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
  );

  -- Convenience procedure for FATAL level (0)
  PROCEDURE FATAL(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for ALERT level (1)
  PROCEDURE ALERT(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for CRITICAL level (2)
  PROCEDURE CRITICAL(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for ERROR level (3)
  PROCEDURE ERROR(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for WARNING level (4)
  PROCEDURE WARNING(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for NOTICE level (5)
  PROCEDURE NOTICE(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for INFO level (6)
  PROCEDURE INFO(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );

  -- Convenience procedure for DEBUG level (7)
  PROCEDURE DEBUG(
      p_message      IN SYSTEM_LOG.MESSAGE%TYPE      DEFAULT NULL
    , p_module       IN SYSTEM_LOG.MODULE%TYPE       DEFAULT NULL
    , p_process_name IN SYSTEM_LOG.PROCESS_NAME%TYPE DEFAULT NULL
    , p_error_code   IN SYSTEM_LOG.ERROR_CODE%TYPE   DEFAULT NULL
    , p_run_id       IN NUMBER                       DEFAULT NULL
  );


END PKG_SYSLOG;
/
