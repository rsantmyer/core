ALTER TABLE APP_DEPLOY_HIST 
ADD ( MAJOR_VERSION      INTEGER      DEFAULT 0       NOT NULL 
    , MINOR_VERSION      INTEGER      DEFAULT 1       NOT NULL
    , PATCH_VERSION      INTEGER      DEFAULT 0       NOT NULL
    , PRE_RELEASE        VARCHAR(30)
    , BUILD              VARCHAR(30) 
    );


BEGIN
UPDATE APP_DEPLOY_HIST
SET MAJOR_VERSION = TRUNC(VERSION)
  , MINOR_VERSION = TRUNC((VERSION - TRUNC(VERSION) )*10)
;
COMMIT;
END;
/
