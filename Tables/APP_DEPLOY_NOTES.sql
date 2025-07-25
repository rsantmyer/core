CREATE TABLE APP_DEPLOY_NOTES
(
  APPLICATION_NAME   VARCHAR2(30) NOT NULL
, MAJOR_VERSION      INTEGER      NOT NULL 
, MINOR_VERSION      INTEGER      NOT NULL
, PATCH_VERSION      INTEGER      NOT NULL
, SERIALIZED_VERSION INTEGER      GENERATED ALWAYS AS ( (MAJOR_VERSION * 100000000) + (MINOR_VERSION * 10000) + PATCH_VERSION  )
, NOTE_TS            DATE         NOT NULL
, NOTES              CLOB
, CONSTRAINT APP_DEPLOY_NOTES_PK 
      PRIMARY KEY (APPLICATION_NAME, MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION)
, CONSTRAINT APP_DEPLOY_NOTES_FK1 
      FOREIGN KEY (APPLICATION_NAME) 
         REFERENCES APPLICATION (APPLICATION_NAME)
         ON DELETE CASCADE
, CONSTRAINT APP_DEPLOY_NOTES_CK1 CHECK (MAJOR_VERSION >= 0)
, CONSTRAINT APP_DEPLOY_NOTES_CK2 CHECK (MINOR_VERSION >= 0)
, CONSTRAINT APP_DEPLOY_NOTES_CK3 CHECK (PATCH_VERSION >= 0)
) 
;

COMMENT ON TABLE  APP_DEPLOY_NOTES                  IS 'Notes related to the deploy of a specific version';
--
COMMENT ON COLUMN APP_DEPLOY_NOTES.NOTE_TS IS 'The time begin_deployment was called';
COMMENT ON COLUMN APP_DEPLOY_NOTES.NOTES IS 'A CLOB field containing notes reltated to the deployment';
