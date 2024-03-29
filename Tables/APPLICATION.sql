CREATE TABLE APPLICATION
(
  APPLICATION_NAME  VARCHAR2(30) NOT NULL
, VERSION           NUMBER(10,2) DEFAULT 0.1     NOT NULL
, DEPLOY_TYPE       VARCHAR2(1)  DEFAULT 'I'     NOT NULL
, DEPLOY_STATUS     VARCHAR2(1)  DEFAULT 'R'     NOT NULL
, DEPLOY_COMMIT_HASH VARCHAR2(40) DEFAULT '0000000000000000000000000000000000000000' NOT NULL
, DEPLOY_BEGIN      DATE         DEFAULT SYSDATE NOT NULL
, DEPLOY_END        DATE         DEFAULT NULL
, CONSTRAINT APPLICATION_PK 
      PRIMARY KEY (APPLICATION_NAME)
, CONSTRAINT APPLICATION_CK1 CHECK (APPLICATION_NAME = UPPER(APPLICATION_NAME) )
, CONSTRAINT APPLICATION_CK2 CHECK (VERSION >= 0)
, CONSTRAINT APPLICATION_CK3 CHECK (DEPLOY_TYPE IN ('I','P') )       --INITIAL, PATCH
, CONSTRAINT APPLICATION_CK4 CHECK (DEPLOY_STATUS IN ('R','C','F') ) --RUNNING, COMPLETE, FAIL
, CONSTRAINT APPLICATION_CK5 CHECK (   (DEPLOY_END IS NULL) 
                                    OR (DEPLOY_END IS NOT NULL AND DEPLOY_STATUS != 'R') )
) 
;

COMMENT ON TABLE  APPLICATION                  IS 'Keep track of deployed applications';
--
COMMENT ON COLUMN APPLICATION.APPLICATION_NAME IS 'PK 1/1';
COMMENT ON COLUMN APPLICATION.VERSION          IS 'Default 0.1';
COMMENT ON COLUMN APPLICATION.DEPLOY_TYPE      IS 'I:Initial; P:Patch';
COMMENT ON COLUMN APPLICATION.DEPLOY_STATUS    IS 'R:Running; C:Complete; F:Fail';
COMMENT ON COLUMN APPLICATION.DEPLOY_COMMIT_HASH IS 'Repository commit hash at application root at time of deploy';
COMMENT ON COLUMN APPLICATION.DEPLOY_BEGIN     IS 'Default SYSDATE';
COMMENT ON COLUMN APPLICATION.DEPLOY_END       IS 'The time the status changes from R to C or F';
