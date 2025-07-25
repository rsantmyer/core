CREATE OR REPLACE PACKAGE PKG_APPLICATION
AS
--Usage:
-- This package is intended to help track application dependencies as well as system and object privileges needed.
--
-- For initial deployments:
--   EXEC pkg_application.begin_deployment_p(ip_application_name => ':APPLICATION_NAME:');  --Assumes an initial deployment with version 0.1
--   OR
--   EXEC pkg_application.begin_deployment_p(ip_application_name => ':APPLICATION_NAME:', ip_version => 1, ip_deployment_type => pkg_application.c_deploy_type_initial);
--
--   EXEC pkg_application.add_dependency_p  (ip_application_name => ':APPLICATION_NAME:', ip_depends_on => ':APPLICATION2_NAME:');
--   ...
--   EXEC pkg_application.add_sys_priv_p    (ip_application_name => ':APPLICATION_NAME:', ip_privilege => ':SYS_PRIV:');
--   ...
--   EXEC pkg_application.add_obj_priv_p    (ip_application_name => ':APPLICATION_NAME:', ip_owner => ':OBJECT_OWNER:', ip_type => ':OBJECT_TYPE:', ip_name => ':OBJECT_NAME:', ip_privilege => ':OBJECT_PRIV:');
--   ...
--   EXEC pkg_application.validate_dependencies_p  (ip_application_name => ':APPLICATION_NAME:');
--   EXEC pkg_application.validate_obj_privs_p     (ip_application_name => ':APPLICATION_NAME:');
--   EXEC pkg_application.validate_sys_privs_p     (ip_application_name => ':APPLICATION_NAME:');
--   EXEC pkg_application.set_deployment_complete_p(ip_application_name => ':APPLICATION_NAME:');
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
   TYPE t_application IS RECORD
   ( application_name           application.application_name%TYPE
   , major_version              application.major_version%TYPE    := 0
   , minor_version              application.minor_version%TYPE    := 1
   , patch_version              application.patch_version%TYPE    := 0
   , pre_release                application.pre_release%TYPE
   , build                      application.build%TYPE  
   , deploy_type                application.deploy_type%TYPE
   , deploy_status              application.deploy_status%TYPE
   , deploy_commit_hash         application.deploy_commit_hash%TYPE
   , deploy_begin               application.deploy_begin%TYPE
   , deploy_end                 application.deploy_end%TYPE 
   )
   ;
   TYPE t_app_object_metadata IS RECORD
   ( object_name               app_object_metadata.object_name%TYPE
   , object_namespace          app_object_metadata.object_namespace%TYPE
   , object_type               app_object_metadata.object_type%TYPE
   , application_name          app_object_metadata.application_name%TYPE
   , discriminator_col         app_object_metadata.discriminator_col%TYPE
   , discriminator_val         app_object_metadata.discriminator_val%TYPE
   , last_update               app_object_metadata.last_update%TYPE
   , version                   app_object_metadata.version%TYPE
   , dml_override_proc         app_object_metadata.dml_override_proc%TYPE
   )
   ;
--------------------------------------------------------------------------------
   --PACKAGE CONSTANTS
   --
   --APPLICATION.version
   c_core_major_version       CONSTANT APPLICATION.major_version%TYPE     := 2;
   c_version_default_major    CONSTANT APPLICATION.major_version%TYPE     := 0;
   c_version_default_minor    CONSTANT APPLICATION.minor_version%TYPE     := 1;
   c_version_default_patch    CONSTANT APPLICATION.patch_version%TYPE     := 0;
   --APPLICATION.deploy_type
   c_deploy_type_initial      CONSTANT APPLICATION.deploy_type%TYPE := 'I';
   c_deploy_type_major        CONSTANT APPLICATION.deploy_type%TYPE := 'V';
   c_deploy_type_minor        CONSTANT APPLICATION.deploy_type%TYPE := 'M';
   c_deploy_type_patch        CONSTANT APPLICATION.deploy_type%TYPE := 'P';
   --APPLICATION.deploy_commit_hash
   c_deploy_commit_hash_unknown CONSTANT APPLICATION.deploy_commit_hash%TYPE := '0000000000000000000000000000000000000000';
   --APPLICATION.deploy_status
   c_deploy_status_running    CONSTANT APPLICATION.deploy_status%TYPE := 'R';
   c_deploy_status_complete   CONSTANT APPLICATION.deploy_status%TYPE := 'C';
   c_deploy_status_fail       CONSTANT APPLICATION.deploy_status%TYPE := 'F';
   --
   --APP_DEPENDENCY.is_valid
   c_valid_unknown            CONSTANT APP_DEPENDENCY.is_valid%TYPE   := 'U';
   c_valid_yes                CONSTANT APP_DEPENDENCY.is_valid%TYPE   := 'Y';
   c_valid_no                 CONSTANT APP_DEPENDENCY.is_valid%TYPE   := 'N';
   --APP_DEPENDENCY.version_min
   c_version_min_any          CONSTANT APP_DEPENDENCY.version_min%TYPE := 0;
   c_version_max_any          CONSTANT APP_DEPENDENCY.version_max%TYPE := 999999;
   --APP_OBJECT_TYPE.object_type%TYPE
   c_object_type_table        CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'TABLE';
   c_object_type_sequence     CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'SEQUENCE';
   c_object_type_procedure    CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'PROCEDURE';
   c_object_type_function     CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'FUNCTION';
   c_object_type_materialized_view     CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'MATERIALIZED VIEW';
   c_object_type_type         CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'TYPE';
   c_object_type_type_body    CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'TYPE BODY';
   c_object_type_package      CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'PACKAGE';
   c_object_type_package_body CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'PACKAGE BODY';
   c_object_type_view         CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'VIEW';
   c_object_type_db_link      CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'DATABASE LINK';
   c_object_type_synonym      CONSTANT APP_OBJECT_TYPE.object_type%TYPE := 'SYNONYM';
   
   --FUNCTIONS
   FUNCTION get_current_version_f( ip_application_name IN application.application_name%TYPE )
      RETURN VARCHAR;

   --accept a string version in Major.mInor.Patch format and return an integer in the format MMMMIIIIPPPP
   FUNCTION serialize_version_f(ip_version IN VARCHAR)
      RETURN INTEGER;

   --accept an integer version in the format MMMMIIIIPPPP and return a string version in Major.mInor.Patch format
   FUNCTION deserialize_version_f(ip_serialized_version IN INTEGER)
      RETURN VARCHAR;
   
   --PROCEDURES
   --check that application version is at least ip_min_version
   PROCEDURE check_min_app_version_p( ip_application_name  IN application.application_name%TYPE
                                    , ip_min_major_version IN application.major_version%TYPE DEFAULT 0
                                    , ip_min_minor_version IN application.minor_version%TYPE DEFAULT 0
                                    , ip_min_patch_version IN application.patch_version%TYPE DEFAULT 0
                                    );

   --check that application version is less than ip_version
   PROCEDURE check_already_deployed_p( ip_application_name  IN application.application_name%TYPE
                                     , ip_min_major_version IN application.major_version%TYPE DEFAULT 0
                                     , ip_min_minor_version IN application.minor_version%TYPE DEFAULT 0
                                     , ip_min_patch_version IN application.patch_version%TYPE DEFAULT 0 );

   PROCEDURE begin_deployment_p( ip_application_name   IN application.application_name%TYPE
                               , ip_major_version      IN application.major_version%TYPE
                               , ip_minor_version      IN application.minor_version%TYPE
                               , ip_patch_version      IN application.patch_version%TYPE
                               , ip_deployment_type    IN application.deploy_type%TYPE DEFAULT c_deploy_type_initial
                               , ip_deploy_commit_hash IN application.deploy_commit_hash%TYPE DEFAULT c_deploy_commit_hash_unknown
                               , ip_redeploy_okay      IN BOOLEAN DEFAULT FALSE
                               );
   --
   PROCEDURE set_deploy_notes_p( ip_application_name IN application.application_name%TYPE
                               , ip_notes            IN app_deploy_notes.notes%TYPE);
   --
   PROCEDURE set_deployment_complete_p( ip_application_name IN application.application_name%TYPE);
   --
   PROCEDURE set_deployment_fail_p( ip_application_name IN application.application_name%TYPE);
   --
   PROCEDURE add_dependency_p( ip_application_name IN application.application_name%TYPE
                             , ip_depends_on       IN app_dependency.depends_on%TYPE
                             , ip_version_min      IN app_dependency.version_min%TYPE DEFAULT c_version_min_any
                             , ip_version_max      IN app_dependency.version_max%TYPE DEFAULT c_version_max_any
                             );
   --
   PROCEDURE validate_dependencies_p( ip_application_name IN application.application_name%TYPE);
   --
   PROCEDURE add_sys_priv_p( ip_application_name IN application.application_name%TYPE
                           , ip_privilege        IN app_sys_privs.privilege%TYPE);
   --
   PROCEDURE validate_sys_privs_p( ip_application_name IN application.application_name%TYPE);
   --
   PROCEDURE add_obj_priv_p( ip_application_name IN application.application_name%TYPE
                           , ip_owner            IN app_obj_privs.owner%TYPE
                           , ip_type             IN app_obj_privs.type%TYPE
                           , ip_name             IN app_obj_privs.name%TYPE
                           , ip_privilege        IN app_obj_privs.privilege%TYPE);
   --
   PROCEDURE validate_obj_privs_p( ip_application_name IN application.application_name%TYPE);
   --
   PROCEDURE add_object_p( ip_application_name IN application.application_name%TYPE
                         , ip_object_name      IN app_objects.object_name%TYPE
                         , ip_object_type      IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                         );
   --
   PROCEDURE add_object_metadata_p( ip_application_name  IN application.application_name%TYPE
                                  , ip_object_name       IN app_objects.object_name%TYPE
                                  , ip_object_type       IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                                  , ip_discriminator_col IN app_object_metadata.discriminator_col%TYPE DEFAULT 'NONE'
                                  , ip_discriminator_val IN app_object_metadata.discriminator_val%TYPE DEFAULT 'NONE'
                                  , ip_version           IN app_object_metadata.version%TYPE DEFAULT NULL
                                  , ip_dml_override_proc IN app_object_metadata.dml_override_proc%TYPE DEFAULT NULL
                                  );
   --
   PROCEDURE delete_object_metadata_p( ip_application_name  IN application.application_name%TYPE
                                     , ip_object_name       IN app_objects.object_name%TYPE
                                     , ip_object_type       IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                                     , ip_discriminator_col IN app_object_metadata.discriminator_col%TYPE
                                     , ip_discriminator_val IN app_object_metadata.discriminator_val%TYPE
                                     );
   --
   PROCEDURE validate_objects_p( ip_application_name IN application.application_name%TYPE); --bugbug: should we validate object_metadata?
   --
   PROCEDURE delete_application_p( ip_application_name  IN application.application_name%TYPE
                                 , ip_fail_on_not_found IN VARCHAR2 DEFAULT 'Y' );
   --
   PROCEDURE delete_system_p;
   --
   PROCEDURE drop_object_p( ip_object_type IN app_objects.object_type%TYPE
                          , ip_object_name IN app_objects.object_name%TYPE );

   PROCEDURE forget_object_p( ip_object_type IN app_objects.object_type%TYPE
                            , ip_object_name IN app_objects.object_name%TYPE );
   --
   PROCEDURE drop_and_forget_object_p( ip_object_type IN app_objects.object_type%TYPE
                                     , ip_object_name IN app_objects.object_name%TYPE );
   --
   PROCEDURE change_object_application_p( ip_object_name           IN app_objects.object_name%TYPE
                                        , ip_new_application_name  IN application.application_name%TYPE
                                        , ip_object_type           IN app_object_type.object_type%TYPE DEFAULT c_object_type_table
                                        , ip_old_application_name  IN application.application_name%TYPE DEFAULT NULL );
   --
END PKG_APPLICATION;
/
