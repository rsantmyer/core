CREATE TABLE APP_DEPLOY_HIST
(
  LOG_TS            DATE         NOT NULL
, APPLICATION_NAME  VARCHAR2(30) NOT NULL
, VERSION           NUMBER(10,2)
, DEPLOY_TYPE       VARCHAR2(1)
, DEPLOY_STATUS     VARCHAR2(1)
, DEPLOY_COMMIT_HASH VARCHAR2(40)
, DEPLOY_BEGIN      DATE
, DEPLOY_END        DATE
) 
;

COMMENT ON TABLE  APP_DEPLOY_HIST                  IS 'Archive data from the application table with each new deployment';
--
COMMENT ON COLUMN APP_DEPLOY_HIST.log_ts IS 'The time begin_deployment was called';
