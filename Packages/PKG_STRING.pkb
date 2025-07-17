CREATE OR REPLACE PACKAGE BODY PKG_STRING
AS

FUNCTION get_nth(ip_array IN VARCHAR_TAB, n IN INTEGER)
   RETURN VARCHAR
IS
BEGIN
   RETURN ip_array(n);
END get_nth;


FUNCTION split( ip_string IN VARCHAR2, ip_sep IN VARCHAR DEFAULT ' ')
   RETURN VARCHAR_TAB
IS
   l_return_array VARCHAR_TAB;
BEGIN
   WITH a_string 
   AS
   (
      SELECT ip_string AS txt FROM dual
   )
   SELECT TRIM(REGEXP_SUBSTR(a_string.txt, '[^'||ip_sep||']+', 1, LEVEL)) AS token
    BULK COLLECT INTO l_return_array
    FROM a_string
   CONNECT BY LEVEL <= REGEXP_COUNT(a_string.txt, ip_sep) + 1;
   
   RETURN l_return_array;
END split;


END PKG_STRING;
/
