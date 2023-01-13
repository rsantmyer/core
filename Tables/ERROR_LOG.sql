--
-- ERROR_LOG  (Table) 
--
CREATE TABLE ERROR_LOG
(
  LOG_UID         NUMBER,
  LOG_DATE        TIMESTAMP(6),
  TASK_QUEUE_ID   NUMBER,
  PROCESS_NAME    VARCHAR2(200 BYTE),
  MODULE_NAME     VARCHAR2(200 BYTE),
  REVISION        VARCHAR2(100 BYTE),
  ERROR_CODE      VARCHAR2(100 BYTE),
  ERROR_MESSAGE   VARCHAR2(1000 BYTE),
  REFERENCE_INFO  VARCHAR2(1000 BYTE),
  SEVERITY_LEVEL  NUMBER
)
;


