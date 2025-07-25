REM MERGING into APP_OBJ_NAMESPACE
PROMPT MERGING into APP_OBJ_NAMESPACE
SET DEFINE OFF;

DECLARE
   TYPE t_APP_OBJ_NAMESPACE IS TABLE OF APP_OBJ_NAMESPACE%ROWTYPE INDEX BY BINARY_INTEGER;
   l_APP_OBJ_NAMESPACE t_APP_OBJ_NAMESPACE;

   V_I PLS_INTEGER := 0;

BEGIN
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'DEFAULT';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Tables, Views, Sequences, Private synonyms, Stand-alone procedures, Stand-alone functions, Packages, Materialized views, User-defined types';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'INDEX';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Indexes';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'CONSTRAINT';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Constraints';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'CLUSTER';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Clusters';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'TRIGGER';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Triggers';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'TYPE_BODY';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Type bodies';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'PACKAGE_BODY';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Package bodies';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'DATABASE_LINK';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Private Database Links';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'DIMENSION';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Dimensions';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'OTHER';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'catch-all';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'METADATA';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Database metadata - i.e. the data within a table';
-------------------------------------------------------------------------------- 
V_I := V_I + 1;
l_APP_OBJ_NAMESPACE(V_I).OBJECT_NAMESPACE        := 'EXTERNAL';
l_APP_OBJ_NAMESPACE(V_I).DESCRIPTION             := 'Objects external to the database such as scripts';
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
   FORALL i IN l_APP_OBJ_NAMESPACE.FIRST..l_APP_OBJ_NAMESPACE.LAST
      MERGE INTO APP_OBJ_NAMESPACE A
         USING (SELECT NULL FROM dual)
            ON (
                 A.OBJECT_NAMESPACE                   = l_APP_OBJ_NAMESPACE(i).OBJECT_NAMESPACE
               )
      WHEN MATCHED
      THEN
         UPDATE SET
           A.DESCRIPTION                     = l_APP_OBJ_NAMESPACE(i).DESCRIPTION
      WHEN NOT MATCHED
      THEN
         INSERT VALUES l_APP_OBJ_NAMESPACE(I);
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
