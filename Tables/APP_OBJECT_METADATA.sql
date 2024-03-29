CREATE TABLE APP_OBJECT_METADATA
(
  OBJECT_NAME           VARCHAR2(128) NOT NULL
, OBJECT_NAMESPACE      VARCHAR2(30)  NOT NULL
, OBJECT_TYPE           VARCHAR2(100) NOT NULL
, DISCRIMINATOR         VARCHAR2(30)  DEFAULT 'NONE'     NOT NULL
, KEY                   VARCHAR2(30)  DEFAULT 'VERSION'  NOT NULL
, INSERT_TIME           DATE          DEFAULT SYSDATE NOT NULL
, METADATA_VALUE        VARCHAR2(100) NOT NULL
--
, CONSTRAINT APP_OBJECT_METADATA_PK 
     PRIMARY KEY (OBJECT_NAME, OBJECT_NAMESPACE, DISCRIMINATOR, KEY, INSERT_TIME)
, CONSTRAINT APP_OBJECT_METADATA_FK1 
     FOREIGN KEY (OBJECT_NAME, OBJECT_NAMESPACE) 
        REFERENCES APP_OBJECTS (OBJECT_NAME, OBJECT_NAMESPACE)
           ON DELETE CASCADE
, CONSTRAINT APP_OBJECT_METADATA_CK1 CHECK (KEY = UPPER(KEY) ) 
) 
;

COMMENT ON TABLE  APP_OBJECT_METADATA                  IS 'Track object metadata; specifically VERSION';
--
COMMENT ON COLUMN APP_OBJECT_METADATA.OBJECT_NAME      IS 'PK 1/5. FK to APP_OBJECTS';
COMMENT ON COLUMN APP_OBJECT_METADATA.OBJECT_NAMESPACE IS 'PK 2/5. FK to APP_OBJECTS';
COMMENT ON COLUMN APP_OBJECT_METADATA.OBJECT_TYPE      IS 'Denormalized from APP_OBJECTS';
COMMENT ON COLUMN APP_OBJECT_METADATA.DISCRIMINATOR    IS 'PK 3/5. "NONE" if referring to the main object; Otherwise, the identifier used to break up the deployment of data to OBJECT_NAME';
COMMENT ON COLUMN APP_OBJECT_METADATA.KEY              IS 'PK 4/5. The attribute being tracked, i.e "VERSION"';
COMMENT ON COLUMN APP_OBJECT_METADATA.INSERT_TIME      IS 'PK 5/5. The timestamp the row was inserted';
COMMENT ON COLUMN APP_OBJECT_METADATA.METADATA_VALUE   IS 'The value associated with KEY';
