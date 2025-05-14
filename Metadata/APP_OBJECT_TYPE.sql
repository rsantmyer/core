REM INSERTING into APP_OBJECT_TYPE
PROMPT INSERTING into APP_OBJECT_TYPE
SET DEFINE OFF;

DECLARE
   TYPE t_APP_OBJECT_TYPE IS TABLE OF APP_OBJECT_TYPE%ROWTYPE INDEX BY BINARY_INTEGER;
   l_APP_OBJECT_TYPE t_APP_OBJECT_TYPE;

   V_I PLS_INTEGER := 0;

BEGIN
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'METADATA';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'METADATA';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'EXTERNAL';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'EXTERNAL';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'CLUSTER';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'CLUSTER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'CONSTRAINT';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'CONSTRAINT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'CONSUMER GROUP';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'CONTAINER';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'CONTEXT';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'DATABASE LINK';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DATABASE_LINK';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'DESTINATION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'DIRECTORY';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'DIMENSION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DIMENSION';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'EDITION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'EVALUATION CONTEXT';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'FUNCTION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'INDEX';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'INDEX';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'INDEX PARTITION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'INDEXTYPE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'JOB';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'JOB CLASS';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'LIBRARY';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'LOB';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'LOB PARTITION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'MATERIALIZED VIEW';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'Y';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'OPERATOR';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'PACKAGE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'PACKAGE BODY';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'PACKAGE_BODY';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'PROCEDURE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'PROGRAM';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'QUEUE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'RESOURCE PLAN';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'RULE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'RULE SET';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'SCHEDULE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'SCHEDULER GROUP';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'SEQUENCE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'SYNONYM';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'TABLE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'Y';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'TABLE PARTITION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'TABLE SUBPARTITION';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'TRIGGER';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'TRIGGER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'TYPE';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'TYPE BODY';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'TYPE_BODY';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'UNDEFINED';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'UNIFIED AUDIT POLICY';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'VIEW';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'WINDOW';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJECT_TYPE(V_I).OBJECT_TYPE             := 'XML SCHEMA';
l_APP_OBJECT_TYPE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJECT_TYPE(V_I).SUPPORTED               := 'N';
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
   FORALL i IN l_APP_OBJECT_TYPE.FIRST..l_APP_OBJECT_TYPE.LAST
      MERGE INTO APP_OBJECT_TYPE A
         USING (SELECT NULL FROM dual)
            ON (
                 A.OBJECT_TYPE                   = l_APP_OBJECT_TYPE(i).OBJECT_TYPE
               )
      WHEN MATCHED
      THEN
         UPDATE SET
           A.OBJECT_NAMESPACE                    = l_APP_OBJECT_TYPE(i).OBJECT_NAMESPACE
         , A.SUPPORTED                           = l_APP_OBJECT_TYPE(i).SUPPORTED
      WHEN NOT MATCHED
      THEN
         INSERT VALUES l_APP_OBJECT_TYPE(I);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
   COMMIT;
   --ROLLBACK;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      RAISE;
END;
/

SET DEFINE ON;
