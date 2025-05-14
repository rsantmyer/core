CREATE OR REPLACE PACKAGE BODY PKG_APPLICATION
AS
--PRIVATE
PROCEDURE get_application_rec_p( ip_application_name IN application.application_name%TYPE
                               , op_rec_application OUT application%ROWTYPE
                               , ip_fail_on_not_found IN VARCHAR2 DEFAULT 'Y' )
IS
BEGIN
   assert(ip_fail_on_not_found IN ('Y','N'));

   SELECT *
     INTO op_rec_application
     FROM application
    WHERE application_name = ip_application_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF ip_fail_on_not_found = 'Y' THEN
         RAISE;
      END IF;
END get_application_rec_p;



PROCEDURE arch_application_rec_P( ip_rec_application IN application%ROWTYPE )
IS
BEGIN
   INSERT 
     INTO app_deploy_hist
        ( log_ts
        , application_name
        , major_version
        , minor_version
        , patch_version
        , deploy_type
        , deploy_status
        , deploy_begin
        , deploy_end
        , deploy_commit_hash
        )
   SELECT SYSDATE
        , ip_rec_application.application_name
        , ip_rec_application.major_version
        , ip_rec_application.minor_version
        , ip_rec_application.patch_version
        , ip_rec_application.deploy_type
        , ip_rec_application.deploy_status
        , ip_rec_application.deploy_begin
        , ip_rec_application.deploy_end
        , ip_rec_application.deploy_commit_hash
     FROM dual;

   --calling proc commits
END arch_application_rec_P;



PROCEDURE get_object_type_p( ip_object_type      IN app_object_type.object_type%TYPE
                           , op_rec_object_type OUT app_object_type%ROWTYPE )
IS
BEGIN
   SELECT *
     INTO op_rec_object_type
     FROM app_object_type
    WHERE object_type = ip_object_type;
END get_object_type_p;



PROCEDURE get_object_p( ip_object_name      IN app_objects.object_name%TYPE
                      , ip_object_namespace IN app_objects.object_namespace%TYPE
                      , op_rec_object      OUT app_objects%ROWTYPE )
IS
BEGIN
   SELECT *
     INTO op_rec_object
     FROM app_objects
    WHERE object_name = ip_object_name
      AND object_namespace = ip_object_namespace;
END get_object_p;



--PUBLIC
FUNCTION get_current_version_f( ip_application_name IN application.application_name%TYPE )
   RETURN VARCHAR
IS 
   l_retvar VARCHAR(100);
BEGIN
   SELECT major_version||'.'||minor_version||'.'||patch_version AS sem_ver
     INTO l_retvar
     FROM application
    WHERE application_name = ip_application_name;
   
   RETURN l_retvar;
END get_current_version_f;



PROCEDURE check_min_app_version_p( ip_application_name  IN application.application_name%TYPE
                                 , ip_min_major_version IN application.major_version%TYPE DEFAULT 0
                                 , ip_min_minor_version IN application.minor_version%TYPE DEFAULT 0
                                 , ip_min_patch_version IN application.patch_version%TYPE DEFAULT 0
                                 )
IS
   rec_application application%ROWTYPE;
BEGIN
   SELECT *
     INTO rec_application
     FROM application
    WHERE application_name = UPPER(ip_application_name);

--   assert(rec_application.version >= NVL(ip_min_version,0), 'Application version is: '||rec_application.version||'. Minimum required version is: '||ip_min_version);
   assert(rec_application.major_version >= NVL(ip_min_major_version,0), 'Application major_version is: '||rec_application.major_version||'. Minimum required major_version is: '||ip_min_major_version);
   IF rec_application.major_version = ip_min_major_version THEN
      assert(rec_application.minor_version >= NVL(ip_min_minor_version,0), 'Application minor_version is: '||rec_application.minor_version||'. Minimum required minor_version is: '||ip_min_minor_version);
      IF rec_application.minor_version = ip_min_minor_version THEN
         assert(rec_application.patch_version >= NVL(ip_min_patch_version,0), 'Application patch_version is: '||rec_application.patch_version||'. Minimum required patch_version is: '||ip_min_patch_version);
     END IF;
   END IF;
END check_min_app_version_p;



PROCEDURE check_already_deployed_p( ip_application_name  IN application.application_name%TYPE
                                  , ip_min_major_version IN application.major_version%TYPE DEFAULT 0
                                  , ip_min_minor_version IN application.minor_version%TYPE DEFAULT 0
                                  , ip_min_patch_version IN application.patch_version%TYPE DEFAULT 0 )
IS
   rec_application application%ROWTYPE;
BEGIN
   SELECT *
     INTO rec_application
     FROM application
    WHERE application_name = UPPER(ip_application_name);

   assert(rec_application.major_version <= NVL(ip_min_major_version,0), 'It appears major_version '||ip_min_major_version||' has already been deployed; application major_version is: '||rec_application.major_version);
   IF rec_application.major_version = ip_min_major_version THEN
      assert(rec_application.minor_version <= NVL(ip_min_minor_version,0), 'It appears minor_version '||ip_min_minor_version||' has already been deployed; application minor_version is: '||rec_application.minor_version);
      IF rec_application.minor_version = ip_min_minor_version THEN
         assert(rec_application.patch_version <  NVL(ip_min_minor_version,0), 'It appears patch_version '||ip_min_patch_version||' has already been deployed; application patch_version is: '||rec_application.patch_version);
      END IF;
   END IF;
END check_already_deployed_p;



PROCEDURE begin_deployment_p( ip_application_name   IN application.application_name%TYPE
                            , ip_major_version      IN application.major_version%TYPE
                            , ip_minor_version      IN application.minor_version%TYPE
                            , ip_patch_version      IN application.patch_version%TYPE
                            , ip_deployment_type    IN application.deploy_type%TYPE DEFAULT c_deploy_type_initial
                            , ip_deploy_commit_hash IN application.deploy_commit_hash%TYPE DEFAULT c_deploy_commit_hash_unknown
                            )
IS
   rec_application         application%ROWTYPE;
   l_exists                BOOLEAN := FALSE;
   l_restart_failed_deploy BOOLEAN := FALSE;
BEGIN
   assert(ip_application_name = UPPER(ip_application_name));
   
   CASE ip_deployment_type
   WHEN c_deploy_type_initial THEN
      BEGIN
         get_application_rec_p( ip_application_name => ip_application_name
                              , op_rec_application  => rec_application );
         l_exists := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_exists := FALSE;
      END;
      
      IF l_exists = FALSE THEN
         INSERT 
           INTO application 
              ( application_name, major_version , minor_version, patch_version, deploy_commit_hash )
         VALUES 
              ( ip_application_name, ip_major_version, ip_minor_version, ip_patch_version, ip_deploy_commit_hash );

         get_application_rec_p( ip_application_name => ip_application_name
                              , op_rec_application  => rec_application );
      ELSE
         assert(rec_application.deploy_status != c_deploy_status_complete, 'Initial application deployment already marked complete');
         assert(rec_application.deploy_status IN (c_deploy_status_running, c_deploy_status_fail), 'Application record exists; deploy_status must be one of: '||c_deploy_status_running||','||c_deploy_status_fail||'; found: '||rec_application.deploy_status);

         assert(    ip_major_version = rec_application.major_version 
               AND ip_minor_version = rec_application.minor_version 
               AND ip_patch_version = rec_application.patch_version 
               , 'Application record exists; version must match: '
               ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);

         assert(rec_application.deploy_type = c_deploy_type_initial, 'Application record exists; deploy_type must be c_deploy_type_initial');
      
         IF rec_application.deploy_status = c_deploy_status_fail THEN
            UPDATE application
               SET deploy_status = c_deploy_status_running
                 , deploy_commit_hash = ip_deploy_commit_hash
                 , deploy_begin = SYSDATE;
         END IF;
      END IF;
   ELSE --not initial deploy 
      get_application_rec_p( ip_application_name => ip_application_name
                           , op_rec_application  => rec_application );

      IF rec_application.deploy_status IN (c_deploy_status_running, c_deploy_status_fail) THEN
         assert(    ip_major_version = rec_application.major_version 
                AND ip_minor_version = rec_application.minor_version 
                AND ip_patch_version = rec_application.patch_version 
               , 'deployment already in-progress; version must equal in-flight deployment version: '
               ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);
         l_restart_failed_deploy := TRUE;
      END IF;

      CASE ip_deployment_type
      WHEN c_deploy_type_major THEN
         IF l_restart_failed_deploy = FALSE THEN
            assert( ip_major_version > rec_application.major_version 
                  , 'major version must be greater than deployed major version; deployed version is: '
                  ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);
         END IF;
      WHEN c_deploy_type_minor THEN
         IF l_restart_failed_deploy = FALSE THEN
            assert(    ip_major_version = rec_application.major_version 
                  , 'Major version must match that already deployed; deployed version is: '
                  ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);

            assert( ip_minor_version > rec_application.minor_version 
                  , 'minor version must be greater than deployed minor version; deployed version is: '
                  ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);
         END IF;
      WHEN c_deploy_type_patch THEN
         IF l_restart_failed_deploy = FALSE THEN
            assert(    ip_major_version = rec_application.major_version 
                   AND ip_minor_version = rec_application.minor_version
                  , 'Major and Minor version must match those already deployed; deployed version is: '
                  ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);

            assert( ip_patch_version > rec_application.patch_version 
                  , 'patch version must be greater than deployed patch version; deployed version is: '
                  ||rec_application.major_version||'.'||rec_application.minor_version||'.'||rec_application.patch_version);
         END IF;
      ELSE
         assert(FALSE, 'logic error: ip_deployment_type = '||ip_deployment_type);
      END CASE;
      
      UPDATE application
         SET major_version = ip_major_version
           , minor_version = ip_minor_version
           , patch_version = ip_patch_version
           , deploy_type = ip_deployment_type
           , deploy_status = c_deploy_status_running
           , deploy_commit_hash = ip_deploy_commit_hash
           , deploy_begin = SYSDATE
           , deploy_end = NULL
       WHERE application_name = ip_application_name;
   END CASE;

   arch_application_rec_P( ip_rec_application => rec_application );

   COMMIT;
END begin_deployment_p;



PROCEDURE set_deploy_notes_p( ip_application_name IN application.application_name%TYPE
                            , ip_notes            IN app_deploy_notes.notes%TYPE)
IS
   rec_application   application%ROWTYPE;
BEGIN
   assert(ip_application_name = UPPER(ip_application_name));
   
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   assert(rec_application.deploy_status IN (c_deploy_status_running), 'Deploy status must be "'||c_deploy_status_running||'" in order to set deploy notes');

   DELETE 
     FROM app_deploy_notes
    WHERE application_name = ip_application_name
      AND major_version = rec_application.major_version
      AND minor_version = rec_application.minor_version
      AND patch_version = rec_application.patch_version
   ;
   INSERT 
     INTO app_deploy_notes
        ( application_name
        , major_version
        , minor_version
        , patch_version
        , note_ts
        , notes
        )
   VALUES
        ( ip_application_name
        , rec_application.major_version
        , rec_application.minor_version
        , rec_application.patch_version
        , SYSDATE
        , ip_notes
        )
   ;
   COMMIT;
END set_deploy_notes_p;



PROCEDURE end_deployment_p( ip_application_name IN application.application_name%TYPE
                          , ip_status           IN application.deploy_status%TYPE
                          )
IS
   rec_application   application%ROWTYPE;
BEGIN
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   assert(ip_status IN (c_deploy_status_complete, c_deploy_status_fail), 'Bad value for ip_status: '||ip_status);
   assert(rec_application.deploy_status != c_deploy_status_complete, 'Deploy status is already Complete');
   assert(rec_application.deploy_status IN (c_deploy_status_running, c_deploy_status_fail), 'Deploy status must be "'||c_deploy_status_running||'" or "'||c_deploy_status_fail||'"');
   
   UPDATE application
      SET deploy_status = ip_status
        , deploy_end = SYSDATE
    WHERE application_name = ip_application_name;
    
   COMMIT;
END end_deployment_p;



PROCEDURE set_deployment_complete_p( ip_application_name IN application.application_name%TYPE)
IS
BEGIN
   end_deployment_p( ip_application_name => ip_application_name
                   , ip_status           => c_deploy_status_complete );
END set_deployment_complete_p;



PROCEDURE set_deployment_fail_p( ip_application_name IN application.application_name%TYPE)
IS
BEGIN
   end_deployment_p( ip_application_name => ip_application_name
                   , ip_status           => c_deploy_status_fail );
END set_deployment_fail_p;



PROCEDURE add_dependency_p( ip_application_name IN application.application_name%TYPE
                          , ip_depends_on       IN app_dependency.depends_on%TYPE
                          , ip_version_min      IN app_dependency.version_min%TYPE DEFAULT c_version_min_any
                          , ip_version_max      IN app_dependency.version_max%TYPE DEFAULT c_version_max_any
                          )
IS
   rec_application application%ROWTYPE;
BEGIN
   assert(ip_depends_on = UPPER(ip_depends_on), 'ip_depends_on should be all upper case');
   
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );
   
   DELETE 
     FROM app_dependency 
    WHERE application_name = ip_application_name
      AND depends_on = ip_depends_on;
      
   INSERT
     INTO app_dependency
        ( application_name
        , depends_on
        , version_min
        , version_max )
   VALUES 
        ( ip_application_name
        , ip_depends_on
        , ip_version_min
        , ip_version_max );
     
   COMMIT;
END add_dependency_p;



PROCEDURE validate_dependencies_p( ip_application_name IN application.application_name%TYPE)
IS
   rec_application   application%ROWTYPE;
   l_not_valid_cnt   NUMBER;
   l_not_valid_lst   VARCHAR2(4000);
BEGIN
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   UPDATE app_dependency
      SET is_valid         = CASE ( SELECT COUNT(*) 
                                      FROM application 
                                     WHERE application.application_name = app_dependency.depends_on
                                       AND application.major_version BETWEEN TRUNC(app_dependency.version_min)
                                                                         AND TRUNC(app_dependency.version_max)  --BUGBUG - NEED TO LOOK AT minor_version ALSO
                                  ) WHEN 0 THEN c_valid_no ELSE c_valid_yes END
        , last_validated   = SYSDATE
    WHERE application_name = ip_application_name;
   
   COMMIT;

   SELECT COUNT(*)
        , LISTAGG(depends_on, ', ') WITHIN GROUP (ORDER BY depends_on)
     INTO l_not_valid_cnt
        , l_not_valid_lst
     FROM app_dependency
    WHERE application_name = ip_application_name
      AND is_valid != c_valid_yes;
   
   assert(l_not_valid_cnt = 0, 'Dependency check failed for the following: '||l_not_valid_lst);
END validate_dependencies_p;



PROCEDURE add_sys_priv_p( ip_application_name IN application.application_name%TYPE
                        , ip_privilege        IN app_sys_privs.privilege%TYPE)
IS
   rec_application application%ROWTYPE;
BEGIN
   assert(ip_privilege = UPPER(ip_privilege), 'ip_privilege should be all upper case');
   
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );
   
   DELETE 
     FROM app_sys_privs 
    WHERE application_name = ip_application_name
      AND privilege = ip_privilege;
      
   INSERT
     INTO app_sys_privs
        ( application_name
        , privilege )
   VALUES 
        ( ip_application_name
        , ip_privilege );
     
   COMMIT;

END add_sys_priv_p;



PROCEDURE validate_sys_privs_p( ip_application_name IN application.application_name%TYPE)
IS
   rec_application   application%ROWTYPE;
   l_not_valid_cnt   NUMBER;
   l_not_valid_lst   VARCHAR2(4000);
BEGIN
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   UPDATE app_sys_privs
      SET is_valid         = CASE ( SELECT COUNT(*) 
                                      FROM user_sys_privs 
                                     WHERE user_sys_privs.privilege = app_sys_privs.privilege
                                  ) WHEN 0 THEN c_valid_no ELSE c_valid_yes END
        , last_validated   = SYSDATE
    WHERE application_name = ip_application_name;
   
   COMMIT;

   SELECT COUNT(*)
        , LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege)
     INTO l_not_valid_cnt
        , l_not_valid_lst
     FROM app_sys_privs
    WHERE application_name = ip_application_name
      AND is_valid != c_valid_yes;
   
   assert(l_not_valid_cnt = 0, 'System-Privilege check failed for the following: '||l_not_valid_lst);
END validate_sys_privs_p;



PROCEDURE add_obj_priv_p( ip_application_name IN application.application_name%TYPE
                        , ip_owner            IN app_obj_privs.owner%TYPE
                        , ip_type             IN app_obj_privs.type%TYPE
                        , ip_name             IN app_obj_privs.name%TYPE
                        , ip_privilege        IN app_obj_privs.privilege%TYPE)
IS
   rec_application application%ROWTYPE;
BEGIN
   assert(ip_owner = UPPER(ip_owner), 'ip_owner should be all upper case');
   assert(ip_type = UPPER(ip_type), 'ip_type should be all upper case');
   assert(ip_name = UPPER(ip_name), 'ip_name should be all upper case');
   assert(ip_privilege = UPPER(ip_privilege), 'ip_privilege should be all upper case');
   
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );
   
   DELETE 
     FROM app_obj_privs 
    WHERE application_name = ip_application_name
      AND owner = ip_owner
      AND type = ip_type
      AND name = ip_name
      AND privilege = ip_privilege;
      
   INSERT
     INTO app_obj_privs
        ( application_name
        , owner
        , type
        , name
        , privilege )
   VALUES 
        ( ip_application_name
        , ip_owner
        , ip_type
        , ip_name
        , ip_privilege );
     
   COMMIT;

END add_obj_priv_p;



PROCEDURE validate_obj_privs_p( ip_application_name IN application.application_name%TYPE)
IS
   rec_application   application%ROWTYPE;
   l_not_valid_cnt   NUMBER;
   l_not_valid_lst   VARCHAR2(4000);
BEGIN
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   UPDATE app_obj_privs
      SET is_valid         = CASE ( SELECT COUNT(*) 
                                      FROM user_tab_privs 
                                     WHERE user_tab_privs.owner = app_obj_privs.owner
                                       --AND user_tab_privs.type = app_obj_privs.type                 --everything here shares the same namespace
                                       AND user_tab_privs.table_name = app_obj_privs.name
                                       AND user_tab_privs.privilege = app_obj_privs.privilege
                                  ) WHEN 0 THEN c_valid_no ELSE c_valid_yes END
        , last_validated   = SYSDATE
    WHERE application_name = ip_application_name;
   
   COMMIT;

   SELECT COUNT(*)
        , LISTAGG(privilege||' on '||name, ', ') WITHIN GROUP (ORDER BY privilege, name)
     INTO l_not_valid_cnt
        , l_not_valid_lst
     FROM app_obj_privs
    WHERE application_name = ip_application_name
      AND is_valid != c_valid_yes;
   
   assert(l_not_valid_cnt = 0, 'Object-Privilege check failed for the following: '||l_not_valid_lst);
END validate_obj_privs_p;



PROCEDURE add_object_p( ip_application_name IN application.application_name%TYPE
                      , ip_object_name      IN app_objects.object_name%TYPE
                      , ip_object_type      IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                      )
IS
   rec_application      application%ROWTYPE;
   rec_app_object_type  app_object_type%ROWTYPE;
BEGIN
   assert(ip_object_name = UPPER(ip_object_name), 'ip_object_name should be all upper case');
   assert(ip_object_type = UPPER(ip_object_type), 'ip_object_type should be all upper case');

   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   assert(rec_application.deploy_status NOT IN (c_deploy_status_complete), 'Application deployment status is not in progress: '||ip_application_name);

   get_object_type_p( ip_object_type     => ip_object_type
                    , op_rec_object_type => rec_app_object_type );

   DELETE 
     FROM app_objects 
    WHERE application_name = ip_application_name
      AND object_name = ip_object_name
      AND object_type = ip_object_type;

   BEGIN
      INSERT
        INTO app_objects 
           ( application_name
           , object_type
           , object_namespace
           , object_name
           , major_version
           , minor_version
           )
      VALUES 
           ( ip_application_name
           , rec_app_object_type.object_type
           , rec_app_object_type.object_namespace
           , ip_object_name
           , rec_application.major_version
           , rec_application.minor_version
           );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN 
         ROLLBACK;
         assert(FALSE, 'An object with the same name and object-namespace already exists in app_objects.');
   END;
        
   COMMIT;
END add_object_p;



PROCEDURE add_object_metadata_p( ip_application_name  IN application.application_name%TYPE
                               , ip_object_name       IN app_objects.object_name%TYPE
                               , ip_object_type       IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                               , ip_discriminator_col IN app_object_metadata.discriminator_col%TYPE DEFAULT 'NONE'
                               , ip_discriminator_val IN app_object_metadata.discriminator_val%TYPE DEFAULT 'NONE'
                               , ip_version           IN app_object_metadata.version%TYPE DEFAULT NULL
                               , ip_dml_override_proc IN app_object_metadata.dml_override_proc%TYPE DEFAULT NULL
                               )
IS
   rec_application         application%ROWTYPE;
   rec_app_object_type     app_object_type%ROWTYPE;
   rec_app_object          app_objects%ROWTYPE;
   rec_app_object_metadata app_object_metadata%ROWTYPE;
BEGIN
   assert(ip_object_name = UPPER(ip_object_name), 'ip_object_name should be all upper case');
   assert(ip_object_type = UPPER(ip_object_type), 'ip_object_type should be all upper case');
   assert(ip_discriminator_col = UPPER(ip_discriminator_col), 'ip_discriminator_col should be all upper case');
   assert(ip_object_type = 'TABLE', 'add_object_metadata_p is only supported for object_type "TABLE"');
   get_object_type_p( ip_object_type     => ip_object_type
                    , op_rec_object_type => rec_app_object_type )
   ;
   get_object_p( ip_object_name          => ip_object_name
               , ip_object_namespace     => rec_app_object_type.object_namespace
               , op_rec_object           => rec_app_object )
   ;
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application )
   ;
   rec_app_object_metadata := t_app_object_metadata
      ( object_name         => ip_object_name
      , object_namespace    => rec_app_object.object_namespace
      , object_type         => ip_object_type
      , application_name    => rec_application.application_name
      , discriminator_col   => ip_discriminator_col
      , discriminator_val   => ip_discriminator_val
      , last_update         => SYSDATE
      , version             => ip_version
      , dml_override_proc   => ip_dml_override_proc
      );
   
   MERGE INTO APP_OBJECT_METADATA t
      USING (SELECT NULL FROM dual)
        ON (    t.object_name              = rec_app_object_metadata.object_name
            AND t.object_namespace         = rec_app_object_metadata.object_namespace
            AND t.discriminator_col        = rec_app_object_metadata.discriminator_col
            AND t.discriminator_val        = rec_app_object_metadata.discriminator_val
           )
      WHEN MATCHED
      THEN
         UPDATE SET
           t.last_update                 = rec_app_object_metadata.last_update      
         , t.version                     = rec_app_object_metadata.version          
         , t.dml_override_proc           = rec_app_object_metadata.dml_override_proc
      WHEN NOT MATCHED
      THEN
         INSERT VALUES rec_app_object_metadata;

   COMMIT;
END add_object_metadata_p;



PROCEDURE delete_object_metadata_p( ip_application_name  IN application.application_name%TYPE
                                  , ip_object_name       IN app_objects.object_name%TYPE
                                  , ip_object_type       IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                                  , ip_discriminator_col IN app_object_metadata.discriminator_col%TYPE
                                  , ip_discriminator_val IN app_object_metadata.discriminator_val%TYPE
                                  )
IS
   rec_application         application%ROWTYPE;
   rec_app_object_type     app_object_type%ROWTYPE;
   rec_app_object          app_objects%ROWTYPE;
   rec_app_object_metadata app_object_metadata%ROWTYPE;
BEGIN
   assert(ip_object_name = UPPER(ip_object_name), 'ip_object_name should be all upper case');
   assert(ip_object_type = UPPER(ip_object_type), 'ip_object_type should be all upper case');
   assert(ip_discriminator_col = UPPER(ip_discriminator_col), 'ip_discriminator_col should be all upper case');

   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application )
   ;
   get_object_type_p( ip_object_type     => ip_object_type
                    , op_rec_object_type => rec_app_object_type );

   get_object_p( ip_object_name          => ip_object_name
               , ip_object_namespace     => rec_app_object_type.object_namespace
               , op_rec_object           => rec_app_object );
   SELECT *
     INTO rec_app_object_metadata
    FROM app_object_metadata
   WHERE object_name = ip_object_name
     AND object_namespace = rec_app_object.object_namespace
     AND discriminator_col = ip_discriminator_col
     AND discriminator_val = ip_discriminator_val
   ;
   assert(rec_application.application_name = rec_app_object_metadata.application_name, 'ip_application_name does not match application associated with metadata record')
   ;
   IF rec_app_object_metadata.dml_override_proc IS NULL THEN
      assert(rec_app_object_metadata.discriminator_col != 'NONE', 'Do not call this procedure for discriminator values of "NONE" unless dml_override_proc is populated')
      ;
      EXECUTE IMMEDIATE 'DELETE FROM '||ip_object_name
        ||' WHERE '||rec_app_object_metadata.discriminator_col||' = :discriminator_val' USING rec_app_object_metadata.discriminator_val;
   ELSE
      EXECUTE IMMEDIATE 'BEGIN '||rec_app_object_metadata.dml_override_proc||'; END;';
   END IF;

   DELETE 
     FROM app_object_metadata
   WHERE object_name       = rec_app_object_metadata.object_name
     AND object_type       = rec_app_object_metadata.object_type
     AND discriminator_col = rec_app_object_metadata.discriminator_col
     AND discriminator_val = rec_app_object_metadata.discriminator_val
   ;
   COMMIT;
END delete_object_metadata_p;



PROCEDURE validate_objects_p( ip_application_name IN application.application_name%TYPE)
IS
   rec_application   application%ROWTYPE;
   l_not_valid_cnt   NUMBER;
   l_not_valid_lst   VARCHAR2(4000);
BEGIN
   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application );

   UPDATE app_objects
      SET is_valid         = CASE ( SELECT COUNT(*) 
                                      FROM user_objects 
                                     WHERE object_name = app_objects.object_name
                                       AND object_type = app_objects.object_type
                                  ) WHEN 0 THEN c_valid_no ELSE c_valid_yes END
        , last_validated   = SYSDATE
    WHERE application_name = ip_application_name;
   
   COMMIT;

   SELECT COUNT(*)
        , LISTAGG(object_name, ', ') WITHIN GROUP (ORDER BY object_name)
     INTO l_not_valid_cnt
        , l_not_valid_lst
     FROM app_objects
    WHERE application_name = ip_application_name
      AND is_valid != c_valid_yes;
   
   assert(l_not_valid_cnt = 0, 'Object check failed for the following: '||l_not_valid_lst);
END validate_objects_p;



PROCEDURE drop_object_p( ip_object_type IN app_objects.object_type%TYPE
                       , ip_object_name IN app_objects.object_name%TYPE )
IS
   table_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(table_does_not_exist, -942);
   sequence_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(sequence_does_not_exist, -2289);
   object_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(object_does_not_exist, -4043);
   db_link_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(db_link_does_not_exist, -2024);
   synonym_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(synonym_does_not_exist, -1434);
   --
   l_stmt VARCHAR2(4000);
BEGIN
   CASE ip_object_type
   WHEN c_object_type_table        THEN
      l_stmt := 'DROP TABLE "'||ip_object_name||'" CASCADE CONSTRAINTS PURGE';
   WHEN c_object_type_sequence     THEN
         l_stmt := 'DROP SEQUENCE "'||ip_object_name||'"';
   WHEN c_object_type_type_body    THEN
         l_stmt := 'DROP TYPE BODY "'||ip_object_name||'"';
   WHEN c_object_type_type         THEN
         l_stmt := 'DROP TYPE "'||ip_object_name||'"';
   WHEN c_object_type_procedure     THEN
         l_stmt := 'DROP PROCEDURE "'||ip_object_name||'"';
   WHEN c_object_type_function     THEN
         l_stmt := 'DROP FUNCTION "'||ip_object_name||'"';
   WHEN c_object_type_package      THEN
         l_stmt := 'DROP PACKAGE "'||ip_object_name||'"';
   WHEN c_object_type_package_body THEN
         l_stmt := 'DROP PACKAGE BODY "'||ip_object_name||'"';
   WHEN c_object_type_view         THEN
         l_stmt := 'DROP VIEW "'||ip_object_name||'"';
   WHEN c_object_type_materialized_view         THEN
         l_stmt := 'DROP MATERIALIZED VIEW "'||ip_object_name||'"';
   WHEN c_object_type_db_link      THEN
         l_stmt := 'DROP DATABASE LINK "'||ip_object_name||'"';
   WHEN c_object_type_synonym      THEN
         l_stmt := 'DROP SYNONYM "'||ip_object_name||'"';
   ELSE
      assert(FALSE, ip_object_type||' not yet supported. ');
   END CASE;
   
   EXECUTE IMMEDIATE l_stmt;
   
EXCEPTION
   WHEN table_does_not_exist THEN
      NULL; --IGNORE IF THE TABLE HAS ALREADY BEEN DROPPED
   WHEN sequence_does_not_exist THEN
      NULL; --IGNORE IF THE SEQUENCE HAS ALREADY BEEN DROPPED
   WHEN object_does_not_exist THEN
      NULL; --IGNORE IF THE TYPE/TYPE BODY/FUNCTION HAS ALREADY BEEN DROPPED
   WHEN db_link_does_not_exist THEN
      NULL; --IGNORE IF THE DATABASE LINK HAS ALREADY BEEN DROPPED
   WHEN synonym_does_not_exist THEN
      NULL; --IGNORE IF THE SYNONYM HAS ALREADY BEEN DROPPED
   WHEN OTHERS THEN
      assert(FALSE,'***'||l_stmt||'*** failed with:'||SQLERRM);
END drop_object_p;



PROCEDURE forget_object_p( ip_object_type IN app_objects.object_type%TYPE
                         , ip_object_name IN app_objects.object_name%TYPE )
IS
   rec_app_object_type app_object_type%ROWTYPE;
BEGIN
   SELECT *
     INTO rec_app_object_type
     FROM app_object_type
    WHERE object_type = UPPER(ip_object_type);

   DELETE 
     FROM app_objects 
    WHERE object_name = ip_object_name
      AND object_namespace = rec_app_object_type.object_namespace;

   COMMIT;
END forget_object_p;



PROCEDURE drop_and_forget_object_p( ip_object_type IN app_objects.object_type%TYPE
                                  , ip_object_name IN app_objects.object_name%TYPE )
IS
   rec_app_object_type app_object_type%ROWTYPE;
BEGIN
   drop_object_p( ip_object_type, ip_object_name);
   forget_object_p( ip_object_type, ip_object_name);
END drop_and_forget_object_p;



PROCEDURE change_object_application_p( ip_object_name           IN app_objects.object_name%TYPE
                                     , ip_new_application_name  IN application.application_name%TYPE
                                     , ip_object_type           IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                                     , ip_old_application_name  IN application.application_name%TYPE DEFAULT NULL )
IS
   rec_app_object_type  app_object_type%ROWTYPE;
BEGIN
   get_object_type_p( ip_object_type     => ip_object_type
                    , op_rec_object_type => rec_app_object_type );

   UPDATE app_objects
      SET application_name = ip_new_application_name
    WHERE object_namespace = rec_app_object_type.object_namespace
      AND object_name = ip_object_name
      AND application_name = NVL(ip_old_application_name, application_name)
      AND application_name != ip_new_application_name
   ;
   assert(SQL%ROWCOUNT = 1, SQL%ROWCOUNT||' records modified. Expecting 1.')
   ;
END change_object_application_p;



PROCEDURE delete_application_p( ip_application_name  IN application.application_name%TYPE
                              , ip_fail_on_not_found IN VARCHAR2 DEFAULT 'Y' )
IS
   l_dependent_app_cnt  NUMBER;
   l_dependent_app_lst  VARCHAR2(4000);
   rec_application      application%ROWTYPE;
BEGIN
   assert(ip_fail_on_not_found IN ('Y','N'), 'ip_fail_on_not_found must be "Y" or "N"; found: '||ip_fail_on_not_found);

   get_application_rec_p( ip_application_name => ip_application_name
                        , op_rec_application  => rec_application
                        , ip_fail_on_not_found => ip_fail_on_not_found );

   IF rec_application.application_name IS NULL THEN
      GOTO end_now;
   END IF;
   
   assert(ip_application_name != 'CORE', 'All applications depend on CORE; drop everything in the schema and re-deploy. :)');

   SELECT COUNT(*)
        , LISTAGG(application_name, ', ') WITHIN GROUP (ORDER BY application_name)
     INTO l_dependent_app_cnt
        , l_dependent_app_lst
     FROM app_dependency
    WHERE depends_on = ip_application_name;
   
   assert(l_dependent_app_cnt = 0, 'Application cannot be deleted; the following applications depend on it: '||l_dependent_app_lst);
   
   --delete object metadata associated with the application
   FOR rec_app_object_metadata
    IN
    (
      SELECT *
        FROM app_object_metadata
       WHERE application_name = ip_application_name
       ORDER
          BY object_name
   )
   LOOP
      IF NOT (    rec_app_object_metadata.discriminator_col = 'NONE'
              AND rec_app_object_metadata.dml_override_proc IS NULL ) 
      THEN
         delete_object_metadata_p
           ( ip_application_name  => ip_application_name
           , ip_object_name       => rec_app_object_metadata.object_name
           , ip_object_type       => rec_app_object_metadata.object_type
           , ip_discriminator_col => rec_app_object_metadata.discriminator_col
           , ip_discriminator_val => rec_app_object_metadata.discriminator_val );
      END IF;
   END LOOP
   ;
   FOR rec_app_object
    IN 
    (
       SELECT *
         FROM app_objects
        WHERE application_name = ip_application_name
    )
   LOOP
      drop_object_p( ip_object_type => rec_app_object.object_type
                   , ip_object_name => rec_app_object.object_name );
         
      DELETE 
        FROM app_objects 
       WHERE object_name = rec_app_object.object_name 
         AND object_namespace = rec_app_object.object_namespace;
   END LOOP;
   
   DELETE FROM app_dictionary WHERE application_name = ip_application_name;
   DELETE FROM application WHERE application_name = ip_application_name;
   
   COMMIT;
   <<end_now>>
   NULL;
END delete_application_p;



PROCEDURE delete_system_p
IS
   l_notfound BOOLEAN := FALSE;
BEGIN
   LOOP
      EXIT WHEN l_notfound;
      
      l_notfound := TRUE;
      
      FOR rec_application
       IN 
       (
         SELECT *
           FROM APPLICATION
          WHERE APPLICATION_NAME != 'CORE'
            AND APPLICATION_NAME 
               NOT IN 
               ( SELECT DEPENDS_ON
                  FROM APP_DEPENDENCY
               )
       )
      LOOP
         delete_application_p( ip_application_name => rec_application.application_name);
         l_notfound := FALSE;
      END LOOP;
   END LOOP;

END delete_system_p;


END PKG_APPLICATION;
/
