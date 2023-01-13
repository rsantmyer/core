--
-- PKG_ERROR_UTIL  (Package) 
--
CREATE OR REPLACE PACKAGE PKG_ERROR_UTIL 
AS 

C_ERROR   CONSTANT NUMBER := 1;
C_WARNING CONSTANT NUMBER := 2;
C_INFO    CONSTANT NUMBER := 3;

PROCEDURE LogError_p( 
  in_process_name       IN     VARCHAR2 DEFAULT NULL,
  in_module_name        IN     VARCHAR2 DEFAULT NULL,
  in_revision           IN     VARCHAR2 DEFAULT NULL,
  in_severity_level     IN     NUMBER   DEFAULT NULL,
  in_error_code         IN     NUMBER   DEFAULT NULL,
  in_error_message      IN     VARCHAR2 DEFAULT NULL,
  in_reference_info     IN     VARCHAR2 DEFAULT NULL,
  in_task_queue_id      IN     NUMBER   DEFAULT NULL
);

END PKG_ERROR_UTIL;
/
