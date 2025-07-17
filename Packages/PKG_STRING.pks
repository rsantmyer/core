CREATE OR REPLACE PACKAGE PKG_STRING
AS
--get_nth: accept an array and return the nth element
FUNCTION get_nth(ip_array IN VARCHAR_TAB, n IN INTEGER)
   RETURN VARCHAR;

--split a string into a collection
FUNCTION split( ip_string IN VARCHAR2, ip_sep IN VARCHAR DEFAULT ' ')
   RETURN VARCHAR_TAB;

END PKG_STRING;
/
