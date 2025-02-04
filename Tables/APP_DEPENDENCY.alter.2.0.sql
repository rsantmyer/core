ALTER TABLE APP_DEPENDENCY 
MODIFY ( VERSION_MIN NUMBER(12,4)
       , VERSION_MAX NUMBER(12,4) );

COMMENT ON COLUMN APP_DEPENDENCY.VERSION_MIN      IS 'Default 0. Major.Minor with up to 4 digits for minor';
COMMENT ON COLUMN APP_DEPENDENCY.VERSION_MAX      IS 'Default 999999. Major.Minor with up to 4 digits for minor';
