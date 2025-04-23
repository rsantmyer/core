--SET LINESIZE 10000
--SET LONGCHUNKSIZE 30000
--SET LONG 30000
--VARIABLE OUT_CLOB CLOB
VARIABLE ip_source_schema VARCHAR2(100)
VARIABLE ip_source_table  VARCHAR2(100)


DECLARE
   v_output_clob         CLOB;
   v_on_clause           VARCHAR2(1000);
   v_update_set_clause   VARCHAR2(4000);
   v_pk_predicate_clause VARCHAR2(1000);
   v_pk_using_clause     VARCHAR2(1000);
   v_order_by_clause     VARCHAR2(1000);
   --
   v_collection_name     VARCHAR2(30);
   v_source_schema       VARCHAR2(30);
   v_source_table        VARCHAR2(30);
   v_source_table_col_count VARCHAR2(10);

--
   PROCEDURE build_clauses (ip_source_schema IN VARCHAR2, ip_source_table IN VARCHAR2)
   IS
      TYPE columns_t IS TABLE OF VARCHAR2(30)
         INDEX BY PLS_INTEGER;
      rec_constraint      USER_CONSTRAINTS%ROWTYPE;
      l_pk_columns        columns_t;
      l_non_pk_columns    columns_t;
      
   BEGIN
      SELECT *
        INTO rec_constraint
        FROM USER_CONSTRAINTS
       WHERE CONSTRAINT_TYPE = 'P' --PRIMARY_KEY
         AND OWNER = ip_source_schema
         AND TABLE_NAME = ip_source_table;
         
      SELECT COLUMN_NAME
        BULK COLLECT INTO l_pk_columns
        FROM USER_CONS_COLUMNS
       WHERE OWNER = ip_source_schema
         AND CONSTRAINT_NAME = rec_constraint.constraint_name
       ORDER BY POSITION;

      SELECT COLUMN_NAME
        BULK COLLECT INTO l_non_pk_columns
        FROM USER_TAB_COLUMNS
       WHERE TABLE_NAME = ip_source_table
         AND COLUMN_NAME 
            NOT IN 
            ( SELECT COLUMN_NAME
                FROM USER_CONS_COLUMNS
               WHERE OWNER = ip_source_schema
                 AND CONSTRAINT_NAME = rec_constraint.constraint_name
            )
       ORDER BY COLUMN_ID;
      
      SELECT COUNT(*)
        INTO v_source_table_col_count
        FROM USER_TAB_COLUMNS
       WHERE TABLE_NAME = ip_source_table;

      --build on_clause and pk_predicate_clause and pk_using_clause and order_by_clause
      FOR indx IN 1..l_pk_columns.COUNT
      LOOP
         IF indx > 1
         THEN
            v_on_clause := v_on_clause ||' AND '||CHR(10);
            v_pk_predicate_clause := v_pk_predicate_clause ||' AND ';
            v_pk_using_clause := v_pk_using_clause||', IN ';
            v_order_by_clause := v_order_by_clause||', ';
         ELSE
            NULL;
         END IF;
         v_on_clause := v_on_clause ||'                 A.'||RPAD(l_pk_columns(indx),30)||' = :collection_name:(i).'||l_pk_columns(indx);
         v_pk_predicate_clause := v_pk_predicate_clause ||l_pk_columns(indx)||' = :'||l_pk_columns(indx);
         v_pk_using_clause := v_pk_using_clause ||'REC.'||l_pk_columns(indx);
         v_order_by_clause := v_order_by_clause || l_pk_columns(indx);
      END LOOP;
      
      --build update_set_clause
      FOR indx IN 1..l_non_pk_columns.COUNT
      LOOP
         IF indx > 1
         THEN
            v_update_set_clause := v_update_set_clause ||CHR(10)||'         , A.';
         ELSE
            v_update_set_clause := v_update_set_clause          ||'           A.';
         END IF;
         v_update_set_clause := v_update_set_clause 
           ||RPAD(l_non_pk_columns(indx),31)||' = :collection_name:(i).'||l_non_pk_columns(indx);
      END LOOP;
      
   END build_clauses;
   
BEGIN
   v_output_clob := 
Q'[DECLARE
   TYPE t_all_tab_col IS TABLE OF ALL_TAB_COLUMNS%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE rec_anydata   IS RECORD 
      (DATA_TYPE    VARCHAR2(30),
       VARCHAR_DATA VARCHAR2(2000),
       NUMBER_DATA  NUMBER,
       DATE_DATA    DATE,
       CLOB_DATA    CLOB
      );
   TYPE t_anydata IS TABLE OF rec_anydata INDEX BY VARCHAR2(100);
   --
   l_all_tab_col t_all_tab_col;
   l_anydata     t_anydata;
   --
   v_output_clob CLOB;
   v_collection_name VARCHAR2(30)  := ':collection_name:';
   --
   v_use_this_index INTEGER                      := 1; --:in_index_start_num;
   --
   CURSOR C1_CUR IS
   SELECT *
     FROM :source_schema:.:source_table:
    ORDER BY :order_by_clause:;
   --
   CURSOR C_COLUMN_INFO IS
   SELECT *
     FROM ALL_TAB_COLUMNS
    WHERE OWNER = ':source_schema:'
      AND TABLE_NAME = ':source_table:'
    ORDER BY COLUMN_ID;

   PROCEDURE print_header
   IS
   BEGIN
      v_output_clob :=   'DECLARE'||CHR(10)
                       ||'   TYPE t_:source_table: IS TABLE OF :source_schema:.:source_table:%ROWTYPE INDEX BY BINARY_INTEGER;'
                       ||CHR(10)
                       ||'   :collection_name: t_:source_table:;'
                       ||CHR(10)
                       ||CHR(10)
                       ||'   V_I PLS_INTEGER := 0;'
                       ||CHR(10)
                       ||CHR(10)
                       ||'BEGIN'
                       ||CHR(10);
   END print_header;

   PROCEDURE print_trailer
   IS
      v_current_column_cnt NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_current_column_cnt
        FROM ALL_TAB_COLUMNS
       WHERE OWNER = ':source_schema:'
         AND TABLE_NAME = ':source_table:';

      assert(v_current_column_cnt = :source_table_col_count:, 'Column count differs from expected. Modify the "UPDATE SET" clause and current column count.');
            
      v_output_clob := v_output_clob ||
Q'|-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
   FORALL i IN :collection_name:.FIRST..:collection_name:.LAST
      MERGE INTO :source_schema:.:source_table: A
         USING (SELECT NULL FROM dual)
            ON (
:on_clause:
               )
      WHEN MATCHED
      THEN
         UPDATE SET
:update_set_clause:
      WHEN NOT MATCHED
      THEN
         INSERT VALUES :collection_name:(I);
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
|';
   END print_trailer;

   FUNCTION PRINT_VAL (in_rec_anydata rec_anydata, in_col_name VARCHAR2)
   RETURN VARCHAR2 
   IS
      v_return_val VARCHAR2(32000);
      v_init_char  VARCHAR2(1);
   BEGIN
      CASE in_col_name
      WHEN 'CREATED_DATE'
      THEN
         RETURN 'SYSDATE';
      WHEN 'UPDATED_DATE'
      THEN
         RETURN 'SYSDATE';
      ELSE
         NULL;
      END CASE;
      
      CASE in_rec_anydata.DATA_TYPE
      WHEN 'VARCHAR2'
         THEN
            IF    INSTR(in_rec_anydata.VARCHAR_DATA, CHR(10)) > 0
               OR LENGTH(in_rec_anydata.VARCHAR_DATA) > 70
            THEN
               v_init_char := CHR(10);
            ELSE
               v_init_char := NULL;
            END IF;

            CASE WHEN in_rec_anydata.VARCHAR_DATA IS NULL
            THEN 
               v_return_val := 'NULL';
            WHEN INSTR(in_rec_anydata.VARCHAR_DATA,'''') > 0
              OR INSTR(in_rec_anydata.VARCHAR_DATA, CHR(10)) > 0
              OR LENGTH(in_rec_anydata.VARCHAR_DATA) > 70
            THEN
               v_return_val := v_init_char||'Q''{'||in_rec_anydata.VARCHAR_DATA||'}''';
            ELSE
               v_return_val := v_init_char||Q'{'}'||in_rec_anydata.VARCHAR_DATA||Q'{'}';
            END CASE;
      WHEN 'NUMBER'
         THEN
            IF in_rec_anydata.NUMBER_DATA IS NULL
            THEN 
               v_return_val := 'NULL';
            ELSE
               v_return_val := TO_CHAR(in_rec_anydata.NUMBER_DATA); 
            END IF;
      WHEN 'DATE'
         THEN
            IF in_rec_anydata.DATE_DATA IS NULL
            THEN 
               v_return_val := 'NULL';
            ELSE
               v_return_val := 'TO_DATE('''||TO_CHAR(in_rec_anydata.DATE_DATA,'MM-DD-YYYY')||''',''MM-DD-YYYY'')'; 
            END IF;
      WHEN 'CLOB'
         THEN
            IF in_rec_anydata.CLOB_DATA IS NULL
            THEN 
               v_return_val := 'NULL';
            ELSE
               v_return_val := 'Q''{'||in_rec_anydata.CLOB_DATA||'}'''; 
            END IF;

      END CASE;
      RETURN v_return_val;
   END PRINT_VAL;
   

BEGIN
   OPEN C_COLUMN_INFO;
   LOOP
      FETCH C_COLUMN_INFO BULK COLLECT INTO l_all_tab_col;
      EXIT WHEN C_COLUMN_INFO%NOTFOUND;
   END LOOP;
   CLOSE C_COLUMN_INFO;


   print_header;

   FOR REC IN C1_CUR 
   LOOP
      l_anydata.DELETE;
      v_output_clob := v_output_clob 
--                     ||LPAD(' ',81,'-')||CHR(10)
--                     ||LPAD(' ',5,'-')||REC.DESCRIPTION||CHR(10)
                     ||LPAD(' ',81,'-')||CHR(10);

      IF C1_CUR%ROWCOUNT >= 1 THEN
         v_output_clob := v_output_clob
--                        ||'--V_I := '||TO_CHAR(v_use_this_index)||';'||CHR(10)
                        ||'V_I := V_I + 1;'||CHR(10)
--                        ||'--'||CHR(10)
                        ;
      ELSE
         v_output_clob := v_output_clob
                        ||'V_I := '||TO_CHAR(v_use_this_index)||';'||CHR(10);
      END IF;

      FOR I IN l_all_tab_col.FIRST..l_all_tab_col.LAST
      LOOP
         l_anydata(l_all_tab_col(I).column_name).DATA_TYPE := l_all_tab_col(I).DATA_TYPE;
         
         CASE l_all_tab_col(I).DATA_TYPE
         WHEN 'VARCHAR2' THEN
            EXECUTE IMMEDIATE 'SELECT '||l_all_tab_col(i).column_name||' FROM :source_schema:.:source_table: WHERE :pk_predicate_clause:'
            INTO l_anydata(l_all_tab_col(I).column_name).VARCHAR_DATA 
            USING IN :pk_using_clause:;
         WHEN 'NUMBER' THEN
            EXECUTE IMMEDIATE 'SELECT '||l_all_tab_col(i).column_name||' FROM :source_schema:.:source_table: WHERE :pk_predicate_clause:'
            INTO l_anydata(l_all_tab_col(I).column_name).NUMBER_DATA 
            USING IN :pk_using_clause:;
         WHEN 'DATE' THEN
            EXECUTE IMMEDIATE 'SELECT '||l_all_tab_col(i).column_name||' FROM :source_schema:.:source_table: WHERE :pk_predicate_clause:'
            INTO l_anydata(l_all_tab_col(I).column_name).DATE_DATA 
            USING IN :pk_using_clause:;
         WHEN 'CLOB' THEN
            EXECUTE IMMEDIATE 'SELECT '||l_all_tab_col(i).column_name||' FROM :source_schema:.:source_table: WHERE :pk_predicate_clause:'
            INTO l_anydata(l_all_tab_col(I).column_name).CLOB_DATA 
            USING IN :pk_using_clause:;
         END CASE;
         v_output_clob := v_output_clob
                        ||RPAD(v_collection_name||'(V_I).'||l_all_tab_col(I).column_name,48)||':= '
                        ||PRINT_VAL( l_anydata(l_all_tab_col(I).column_name), l_all_tab_col(I).column_name )
                        ||';'||CHR(10);

      END LOOP;
      v_use_this_index := v_use_this_index + 1;
   END LOOP;
   
   print_trailer;
   
   INSERT INTO TEMP_RS VALUES (SYSDATE, V_OUTPUT_CLOB);
   COMMIT;
   --:OUT_CLOB := v_output_clob;

END;
/]';

   v_source_schema := :ip_source_schema;
   v_source_table  := :ip_source_table;
   --
   v_collection_name := 'l_'||LOWER(v_source_table);

   build_clauses(v_source_schema, v_source_table);

   v_output_clob := REPLACE(v_output_clob, ':on_clause:'          , v_on_clause);
   v_output_clob := REPLACE(v_output_clob, ':update_set_clause:'  , v_update_set_clause);
   v_output_clob := REPLACE(v_output_clob, ':pk_predicate_clause:', v_pk_predicate_clause);
   v_output_clob := REPLACE(v_output_clob, ':pk_using_clause:'    , v_pk_using_clause);
   v_output_clob := REPLACE(v_output_clob, ':order_by_clause:'    , v_order_by_clause);
   --
   v_output_clob := REPLACE(v_output_clob, ':collection_name:'    , v_collection_name);
   v_output_clob := REPLACE(v_output_clob, ':source_schema:'      , v_source_schema);
   v_output_clob := REPLACE(v_output_clob, ':source_table:'       , v_source_table);
   v_output_clob := REPLACE(v_output_clob, ':source_table_col_count:', v_source_table_col_count);

   INSERT INTO TEMP_RS VALUES (SYSDATE, v_output_clob);
   COMMIT;
   --:OUT_CLOB := v_output_clob;
   
END;
/

--PRINT OUT_CLOB