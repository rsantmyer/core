CREATE OR REPLACE PACKAGE BODY PKG_TRACE
AS

FUNCTION get_start_time_f
   RETURN TIMESTAMP
IS
BEGIN
   RETURN CAST(SYSTIMESTAMP AS TIMESTAMP );
END get_start_time_f;



FUNCTION timestamp_diff_micro_f( ip_timestamp_end   IN TIMESTAMP
                               , ip_timestamp_begin IN TIMESTAMP )
   RETURN NUMBER
IS
BEGIN
   RETURN
     EXTRACT( DAY    FROM ip_timestamp_end - ip_timestamp_begin ) *24*60*60*1000
   + EXTRACT( HOUR   FROM ip_timestamp_end - ip_timestamp_begin )    *60*60*1000
   + EXTRACT( MINUTE FROM ip_timestamp_end - ip_timestamp_begin )       *60*1000
   + EXTRACT( SECOND FROM ip_timestamp_end - ip_timestamp_begin )          *1000;
END timestamp_diff_micro_f;



FUNCTION  log_event_f( ip_object_name     IN trace_log.object_name%TYPE
                     , ip_procedure_name  IN trace_log.procedure_name%TYPE DEFAULT NULL
                     , ip_event           IN trace_log.event%TYPE DEFAULT 'end'
                     , ip_wait_start_time IN TIMESTAMP DEFAULT NULL
                     , ip_context         IN trace_log.context%TYPE DEFAULT NULL
                     , ip_get_load        IN VARCHAR2 DEFAULT 'N' 
                     )
   RETURN TIMESTAMP
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT
     INTO trace_log
        ( instance_id
        , object_name
        , procedure_name
        , event
        , event_timestamp
        , time_waited_micro
        , load
        , context
        )
   SELECT TO_NUMBER(SYS_CONTEXT('USERENV','INSTANCE')) AS instance_id
        , ip_object_name
        , ip_procedure_name
        , ip_event
        , CAST(SYSTIMESTAMP AS TIMESTAMP(6) ) AS event_timestamp
        , CASE WHEN ip_wait_start_time IS NOT NULL THEN 
                   EXTRACT( DAY    FROM CAST(SYSTIMESTAMP AS TIMESTAMP(6) ) - ip_wait_start_time ) *24*60*60*1000
                 + EXTRACT( HOUR   FROM CAST(SYSTIMESTAMP AS TIMESTAMP(6) ) - ip_wait_start_time )    *60*60*1000
                 + EXTRACT( MINUTE FROM CAST(SYSTIMESTAMP AS TIMESTAMP(6) ) - ip_wait_start_time )       *60*1000
                 + EXTRACT( SECOND FROM CAST(SYSTIMESTAMP AS TIMESTAMP(6) ) - ip_wait_start_time )          *1000
               ELSE 0 
          END AS time_waited_micro
        , CASE WHEN ip_get_load NOT IN ('N','n') THEN
                 ( SELECT VALUE FROM V$OSSTAT WHERE STAT_NAME = 'LOAD' )
               ELSE NULL 
          END AS load
        , ip_context AS context
     FROM DUAL
     ;

   COMMIT;
   
   RETURN CAST(SYSTIMESTAMP AS TIMESTAMP);
END log_event_f;



PROCEDURE log_event_p( ip_object_name     IN trace_log.object_name%TYPE
                     , ip_procedure_name  IN trace_log.procedure_name%TYPE DEFAULT NULL
                     , ip_event           IN trace_log.event%TYPE DEFAULT 'end'
                     , ip_wait_start_time IN TIMESTAMP DEFAULT NULL
                     , ip_context         IN trace_log.context%TYPE DEFAULT NULL
                     , ip_get_load        IN VARCHAR2 DEFAULT 'N' 
                     )
IS
   l_dev_null TIMESTAMP;
BEGIN
   l_dev_null := 
   log_event_f( ip_object_name     => ip_object_name
              , ip_procedure_name  => ip_procedure_name
              , ip_event           => ip_event
              , ip_wait_start_time => ip_wait_start_time
              , ip_context         => ip_context
              , ip_get_load        => ip_get_load
              );
END log_event_p;



PROCEDURE enable_tracing( ip_object_name IN VARCHAR2
                        , ip_object_type IN VARCHAR2 DEFAULT 'PACKAGE' )
IS
BEGIN
   EXECUTE IMMEDIATE Q'{ALTER SESSION SET PLSQL_CCFLAGS = 'trace:TRUE' }';
   
   CASE UPPER(ip_object_type)
   WHEN 'PACKAGE' THEN 
      EXECUTE IMMEDIATE 'ALTER PACKAGE '||ip_object_name||' COMPILE';
   ELSE
      ASSERT(FALSE,'tracing for ip_object_type: '||ip_object_type||' not implemented yet');
   END CASE;
END enable_tracing;



PROCEDURE disable_tracing( ip_object_name IN VARCHAR2
                         , ip_object_type IN VARCHAR2 DEFAULT 'PACKAGE' )
IS
BEGIN
   EXECUTE IMMEDIATE Q'{ALTER SESSION SET PLSQL_CCFLAGS = 'trace:FALSE' }';
   
   CASE UPPER(ip_object_type)
   WHEN 'PACKAGE' THEN 
      EXECUTE IMMEDIATE 'ALTER PACKAGE '||ip_object_name||' COMPILE';
   ELSE
      ASSERT(FALSE,'tracing for ip_object_type: '||ip_object_type||' not implemented yet');
   END CASE;
END disable_tracing;

END PKG_TRACE;
/
