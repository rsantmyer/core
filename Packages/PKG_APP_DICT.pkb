CREATE OR REPLACE PACKAGE BODY PKG_APP_DICT
AS

FUNCTION exists_f( ip_application IN app_dictionary.application_name%TYPE
                 , ip_key IN app_dictionary.key%TYPE )
   RETURN BOOLEAN
IS
   l_value app_dictionary.value%TYPE;
BEGIN
   SELECT MAX(value)
     INTO l_value
     FROM app_dictionary
    WHERE application_name = ip_application
      AND key = UPPER(ip_key);

   RETURN CASE WHEN l_value IS NULL THEN FALSE ELSE TRUE END;
END exists_f;



FUNCTION get_val_f( ip_application IN app_dictionary.application_name%TYPE
                  , ip_key IN app_dictionary.key%TYPE )
   RETURN VARCHAR2
IS
   l_value app_dictionary.value%TYPE;
BEGIN
   SELECT value
     INTO l_value
     FROM app_dictionary
    WHERE application_name = ip_application
      AND key = UPPER(ip_key);

   RETURN l_value;
END get_val_f;



PROCEDURE add_val_p( ip_application IN app_dictionary.application_name%TYPE
                   , ip_key IN app_dictionary.key%TYPE
                   , ip_value IN app_dictionary.value%TYPE
                   )
IS
BEGIN
   INSERT
     INTO app_dictionary
        ( application_name
        , key
        , value )
   VALUES
        ( ip_application
        , UPPER(ip_key)
        , ip_value );

   COMMIT;
END add_val_p;



PROCEDURE merge_val_p( ip_application IN app_dictionary.application_name%TYPE
                     , ip_key IN app_dictionary.key%TYPE
                     , ip_value IN app_dictionary.value%TYPE
                     )
IS
BEGIN
   DELETE
     FROM app_dictionary
    WHERE application_name = ip_application
      AND key = UPPER(ip_key);

   add_val_p( ip_application, ip_key, ip_value );
END merge_val_p;



PROCEDURE delete_val_p( ip_application IN app_dictionary.application_name%TYPE
                      , ip_key IN app_dictionary.key%TYPE
                      )
IS
BEGIN
   DELETE
     FROM app_dictionary
    WHERE application_name = ip_application
      AND key = UPPER(ip_key);

   COMMIT;
END delete_val_p;


END PKG_APP_DICT;
/
