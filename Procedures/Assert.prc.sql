CREATE OR REPLACE PROCEDURE ASSERT(
  ip_expression IN BOOLEAN,
  ip_message    IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
   IF (NOT NVL(ip_expression, FALSE)) THEN
      raise_application_error(-20000, 'Assertion Error: '||ip_message);
   END IF;
END ASSERT;
/