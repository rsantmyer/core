CREATE TABLE SYSTEM_LOG
(
  LOG_ID           NUMBER(*,0)     GENERATED ALWAYS AS IDENTITY ( START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE CACHE 20 ORDER )
, LOG_LEVEL        NUMBER(1,0)     DEFAULT 5 NOT NULL
, CREATED_AT       TIMESTAMP(6)    DEFAULT SYSTIMESTAMP NOT NULL
, PROCESS_NAME     VARCHAR2(200)
, MODULE           VARCHAR2(100)
, ERROR_CODE       VARCHAR2(100)
, SCHEDULER_RUN_ID NUMBER(*,0)
, MESSAGE          VARCHAR2(4000)
, REFERENCE_INFO   VARCHAR2(1000)
, CLIENT_INFO      VARCHAR2(100)
, OS_USER          VARCHAR2(100)
, IP_ADDRESS       VARCHAR2(50)
, HOST             VARCHAR2(100)
, CONSTRAINT SYSTEM_LOG_CK1 CHECK ( LOG_LEVEL >= 0 AND LOG_LEVEL <= 7 )
)
;

COMMENT ON TABLE SYSTEM_LOG IS 'Stores detailed information about errors, warnings, and other notable events that occur within system or application processes to facilitate monitoring and troubleshooting.';
--
COMMENT ON COLUMN SYSTEM_LOG.LOG_ID IS 'Primary key, auto-generated identity column';
COMMENT ON COLUMN SYSTEM_LOG.LOG_LEVEL IS Q'{A numeric code indicating the severity level of the log message. 
Allowable values are:
 * 0 - Emergency: System is unusable
 * 1 - Alert: Action must be taken immediately
 * 2 - Critical: Critical conditions. While not immediately catastrophic, needs prompt attention to prevent system failure or further problems.
 * 3 - Error: Error conditions
 * 4 - Warning: Warning conditions
 * 5 - Notice: Normal but significant conditions
 * 6 - Informational: Informational messages
 * 7 - Debug: Debugging messages.
}';
COMMENT ON COLUMN SYSTEM_LOG.CREATED_AT IS 'The timestamp indicating precisely when the log entry was recorded.';
COMMENT ON COLUMN SYSTEM_LOG.PROCESS_NAME IS 'The name of the application, batch job, or system process that generated the log entry.';
COMMENT ON COLUMN SYSTEM_LOG.MODULE IS Q'{The application, package, or procedure that generated the log. SYS_CONTEXT('USERENV', 'MODULE') unless overridden.}';
COMMENT ON COLUMN SYSTEM_LOG.ERROR_CODE IS 'A specific code (e.g., ORA-00942) associated with the error, used for precise identification of the issue.';
COMMENT ON COLUMN SYSTEM_LOG.SCHEDULER_RUN_ID IS 'Identifier for a specific task instance in a scheduler that the log entry is associated with, if applicable.';
COMMENT ON COLUMN SYSTEM_LOG.MESSAGE IS 'The detailed, human-readable message describing the error or event.';
COMMENT ON COLUMN SYSTEM_LOG.REFERENCE_INFO IS 'Additional contextual information to aid in diagnostics, such as key record IDs, parameters, or state information.';
COMMENT ON COLUMN SYSTEM_LOG.CLIENT_INFO IS Q'{Information about the client session. SYS_CONTEXT('USERENV', 'CLIENT_INFO') }';
COMMENT ON COLUMN SYSTEM_LOG.OS_USER IS Q'{The operating system user of the client session. SYS_CONTEXT('USERENV', 'OS_USER') }';
COMMENT ON COLUMN SYSTEM_LOG.IP_ADDRESS IS Q'{The IP address of the client machine. SYS_CONTEXT('USERENV', 'IP_ADDRESS') }';
COMMENT ON COLUMN SYSTEM_LOG.HOST IS Q'{The host name of the client machine. SYS_CONTEXT('USERENV', 'HOST')}';
