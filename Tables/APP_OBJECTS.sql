CREATE TABLE APP_OBJECTS
(
  APPLICATION_NAME      VARCHAR2(30)  NOT NULL
, OBJECT_TYPE           VARCHAR2(100) NOT NULL
, OBJECT_NAMESPACE      VARCHAR2(30)  NOT NULL
, OBJECT_NAME           VARCHAR2(128) NOT NULL
, VERSION               NUMBER(10,2)  DEFAULT 0.1     NOT NULL  
, IS_VALID              VARCHAR2(1)   DEFAULT 'U'     NOT NULL  --U,Y,N
, LAST_VALIDATED        DATE          DEFAULT SYSDATE NOT NULL
--
, CONSTRAINT APP_OBJECTS_PK 
     PRIMARY KEY (OBJECT_NAME, OBJECT_NAMESPACE)
, CONSTRAINT APP_OBJECTS_FK1 
     FOREIGN KEY (APPLICATION_NAME) 
        REFERENCES APPLICATION (APPLICATION_NAME)
, CONSTRAINT APP_OBJECTS_FK2
     FOREIGN KEY (OBJECT_TYPE, OBJECT_NAMESPACE)
        REFERENCES APP_OBJECT_TYPE (OBJECT_TYPE, OBJECT_NAMESPACE)
, CONSTRAINT APP_OBJECTS_CK4 CHECK (IS_VALID IN ('U','Y','N') ) --UNKNOWN, YES, NO
) 
;

COMMENT ON TABLE  APP_OBJECTS                  IS 'Track application objects';
--
COMMENT ON COLUMN APP_OBJECTS.APPLICATION_NAME IS 'FK to APPLICATION';
COMMENT ON COLUMN APP_OBJECTS.OBJECT_NAME      IS 'PK 1/2';
COMMENT ON COLUMN APP_OBJECTS.OBJECT_NAMESPACE IS 'PK 2/2. FK to APP_OBJECT_TYPE';
COMMENT ON COLUMN APP_OBJECTS.OBJECT_TYPE      IS 'FK to APP_OBJECT_TYPE';
COMMENT ON COLUMN APP_OBJECTS.IS_VALID         IS 'U:Unknown, Y:Yes, N:No';
COMMENT ON COLUMN APP_OBJECTS.VERSION          IS 'Copied from Application.version';
COMMENT ON COLUMN APP_OBJECTS.LAST_VALIDATED   IS 'Default SYSDATE. Last time the dependency was validated against deployed the deployed application';
