CREATE OR REPLACE PACKAGE PKG_TRACE
AS
   FUNCTION get_start_time_f
      RETURN TIMESTAMP;

   FUNCTION timestamp_diff_micro_f( ip_timestamp_end   IN TIMESTAMP
                                  , ip_timestamp_begin IN TIMESTAMP )
      RETURN NUMBER
      DETERMINISTIC;

   PROCEDURE log_event_p( ip_object_name     IN trace_log.object_name%TYPE
                        , ip_procedure_name  IN trace_log.procedure_name%TYPE DEFAULT NULL
                        , ip_event           IN trace_log.event%TYPE DEFAULT 'end'
                        , ip_wait_start_time IN TIMESTAMP DEFAULT NULL
                        , ip_context         IN trace_log.context%TYPE DEFAULT NULL
                        , ip_get_load        IN VARCHAR2 DEFAULT 'N' 
                        );

   FUNCTION log_event_f( ip_object_name     IN trace_log.object_name%TYPE
                       , ip_procedure_name  IN trace_log.procedure_name%TYPE DEFAULT NULL
                       , ip_event           IN trace_log.event%TYPE DEFAULT 'end'
                       , ip_wait_start_time IN TIMESTAMP DEFAULT NULL
                       , ip_context         IN trace_log.context%TYPE DEFAULT NULL
                       , ip_get_load        IN VARCHAR2 DEFAULT 'N' 
                       )
      RETURN TIMESTAMP;


   PROCEDURE enable_tracing( ip_object_name IN VARCHAR2
                           , ip_object_type IN VARCHAR2 DEFAULT 'PACKAGE'
                           );


   PROCEDURE disable_tracing( ip_object_name IN VARCHAR2
                            , ip_object_type IN VARCHAR2 DEFAULT 'PACKAGE'
                            );


END PKG_TRACE;
/
